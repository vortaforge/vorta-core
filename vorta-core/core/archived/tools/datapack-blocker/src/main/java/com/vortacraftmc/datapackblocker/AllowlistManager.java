package com.vortacraftmc.datapackblocker;

import org.slf4j.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.DirectoryStream;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.PosixFilePermission;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Stream;

/**
 * Enforces a "lock the datapacks folder" policy for a single world.
 *
 * <ol>
 *   <li><b>First run:</b> every pack candidate in {@code datapacks/} (a directory or a {@code .zip}) is recorded in
 *       the allowlist together with a SHA-256 fingerprint of its contents. Nothing is blocked yet.</li>
 *   <li><b>Every later run:</b> a pack is accepted only if its name is on the allowlist <em>and</em> its fingerprint
 *       still matches. Anything else (new pack, or an approved pack whose contents changed) is moved to
 *       {@code <world>/datapack_blocker/quarantine/<timestamp>/}. Nothing is deleted.</li>
 *   <li>Accepted packs get their write bits stripped, so they cannot be edited in place without
 *       {@code /datapackblocker unlock}.</li>
 * </ol>
 *
 * <h2>When enforcement can actually block loading</h2>
 * The server reads {@code datapacks/} <em>before</em> {@code ServerLifecycleEvents.SERVER_STARTING} fires. Moving packs
 * at that point (what version 1.0.0 did) cannot stop them from loading in the current run and can break lazily loaded
 * resources (structures) of a running server. Therefore:
 * <ul>
 *   <li>{@link Phase#EARLY} (dedicated server, from the Fabric {@code preLaunch} entrypoint, before any Minecraft
 *       code runs) quarantines.</li>
 *   <li>{@link Phase#LATE} (SERVER_STARTING) only records the baseline, re-locks and <em>reports</em> violations; it
 *       never moves anything.</li>
 * </ul>
 *
 * <h2>Limits</h2>
 * Tamper deterrent, not a security boundary: anyone with shell/FTP access to the host (or root) can edit the
 * allowlist or the packs. A pack present on the very first run is trusted as-is (trust on first use). Packs added
 * while the server runs and picked up by {@code /reload} are only caught by {@code /datapackblocker verify} or the
 * next restart.
 */
public final class AllowlistManager {

    /** Which startup hook is running this pass; see class doc. */
    public enum Phase { EARLY, LATE }

    private static final String STATE_DIR_NAME = "datapack_blocker";
    private static final String ALLOWLIST_FILE_NAME = "allowlist.txt";
    private static final String QUARANTINE_DIR_NAME = "quarantine";
    private static final String ALLOWLIST_HEADER = "# datapack-blocker allowlist v2: <name><TAB><sha256 of contents>";
    private static final DateTimeFormatter BATCH_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH-mm-ss'Z'").withZone(ZoneOffset.UTC);

    private final Path datapacksDir;
    private final Path stateDir;
    private final Path allowlistFile;
    private final Logger logger;

    public AllowlistManager(Path datapacksDir, Path worldSaveRoot, Logger logger) {
        this.datapacksDir = datapacksDir;
        this.stateDir = worldSaveRoot.resolve(STATE_DIR_NAME);
        this.allowlistFile = stateDir.resolve(ALLOWLIST_FILE_NAME);
        this.logger = logger;
    }

    /** Result of one enforcement pass. {@code unreviewedPacks} is only filled in {@link Phase#LATE}. */
    public record Result(boolean firstRun, List<String> protectedPacks, List<String> quarantinedPacks, List<String> unreviewedPacks) {}

    /** Read-only comparison of the folder against the allowlist. */
    public record Audit(List<String> unreviewed, List<String> modified, List<String> unverified, List<String> missing, int ok) {
        public boolean clean() {
            return unreviewed.isEmpty() && modified.isEmpty() && missing.isEmpty();
        }
    }

    public record QuarantineEntry(String name, String batch) {}

    public Result enforce() throws IOException {
        return enforce(Phase.EARLY);
    }

    public Result enforce(Phase phase) throws IOException {
        Files.createDirectories(stateDir);

        boolean firstRun = !Files.exists(allowlistFile);
        List<String> entries = listPackEntries(datapacksDir);
        Map<String, String> fingerprints = new LinkedHashMap<>();

        Map<String, String> allowlist;
        if (firstRun) {
            allowlist = new TreeMap<>();
            for (String entry : entries) {
                if (!isStorableName(entry)) {
                    logger.warn("Datapack Blocker: '{}' has control characters in its name and cannot be allowlisted.", entry);
                    continue;
                }
                allowlist.put(entry, fingerprint(entry, fingerprints));
            }
            writeAllowlist(allowlist);
            logger.info("Datapack Blocker: first run for this world - captured {} existing datapack(s) as the baseline allowlist (trusted as-is).",
                    allowlist.size());
        } else {
            allowlist = readAllowlist();
            boolean migrated = false;
            for (String entry : entries) {
                if (allowlist.containsKey(entry) && allowlist.get(entry) == null) {
                    allowlist.put(entry, fingerprint(entry, fingerprints));
                    migrated = true;
                    logger.warn("Datapack Blocker: '{}' came from a v1 allowlist without a fingerprint; its current contents are now trusted.", entry);
                }
            }
            if (migrated) writeAllowlist(allowlist);
        }

        Map<String, String> violations = new LinkedHashMap<>(); // name -> reason
        for (String entry : entries) {
            if (!allowlist.containsKey(entry)) {
                violations.put(entry, "not on the allowlist");
            } else if (!firstRun && !allowlist.get(entry).equals(fingerprint(entry, fingerprints))) {
                violations.put(entry, "contents changed since it was approved");
            }
        }

        List<String> quarantined = new ArrayList<>();
        List<String> unreviewed = new ArrayList<>();
        if (phase == Phase.EARLY) {
            if (!violations.isEmpty()) {
                Path batch = newBatchDir();
                for (Map.Entry<String, String> violation : violations.entrySet()) {
                    quarantineEntry(violation.getKey(), batch);
                    quarantined.add(violation.getKey());
                    logger.warn("Datapack Blocker: quarantined '{}' ({}).", violation.getKey(), violation.getValue());
                }
            }
        } else {
            unreviewed.addAll(violations.keySet());
        }

        List<String> protectedPacks = new ArrayList<>();
        for (String entry : listPackEntries(datapacksDir)) {
            if (allowlist.containsKey(entry) && !violations.containsKey(entry)) {
                try {
                    lockEntry(entry);
                    protectedPacks.add(entry);
                } catch (IOException exception) {
                    logger.warn("Datapack Blocker: could not lock '{}': {}", entry, exception.getMessage());
                }
            }
        }

        if (!quarantined.isEmpty()) {
            logger.warn("Datapack Blocker: {} datapack(s) were moved to quarantine before the server read them: {}. " +
                    "Use /datapackblocker approve <name> to allow one after review.", quarantined.size(), quarantined);
        }
        if (!unreviewed.isEmpty()) {
            logger.error("Datapack Blocker: {} datapack(s) violate the allowlist but were ALREADY LOADED by this server start: {}. " +
                    "They are moved to quarantine on the next restart (dedicated server). Review them now.", unreviewed.size(), unreviewed);
        }
        logger.info("Datapack Blocker: {} allowlisted datapack(s) locked read-only.", protectedPacks.size());
        return new Result(firstRun, protectedPacks, quarantined, unreviewed);
    }

    /** Read-only report; never moves, locks or writes anything. Useful between restarts (e.g. before a /reload). */
    public Audit audit() throws IOException {
        Map<String, String> allowlist = readAllowlist();
        Map<String, String> fingerprints = new LinkedHashMap<>();
        List<String> entries = listPackEntries(datapacksDir);
        List<String> unreviewed = new ArrayList<>(), modified = new ArrayList<>(), unverified = new ArrayList<>();
        int ok = 0;
        for (String entry : entries) {
            if (!allowlist.containsKey(entry)) unreviewed.add(entry);
            else if (allowlist.get(entry) == null) unverified.add(entry);
            else if (!allowlist.get(entry).equals(fingerprint(entry, fingerprints))) modified.add(entry);
            else ok++;
        }
        List<String> missing = new ArrayList<>();
        for (String name : allowlist.keySet()) if (!entries.contains(name)) missing.add(name);
        return new Audit(unreviewed, modified, unverified, missing, ok);
    }

    /** Restores write permission (owner only) on every allowlisted pack, for maintenance. */
    public List<String> unlock() throws IOException {
        Map<String, String> allowlist = readAllowlist();
        List<String> unlocked = new ArrayList<>();
        for (String entry : listPackEntries(datapacksDir)) {
            if (allowlist.containsKey(entry)) {
                setWritableTree(safeEntryPath(entry), true);
                unlocked.add(entry);
            }
        }
        logger.info("Datapack Blocker: unlocked {} datapack(s) for editing. Run /datapackblocker lock when done.", unlocked.size());
        return unlocked;
    }

    /**
     * Re-locks every allowlisted pack after a maintenance window <b>and records their current contents as the new
     * trusted fingerprint</b>: running this command is the operator vouching for the edits made while unlocked.
     */
    public List<String> lock() throws IOException {
        Map<String, String> allowlist = readAllowlist();
        Map<String, String> fingerprints = new LinkedHashMap<>();
        List<String> locked = new ArrayList<>();
        for (String entry : listPackEntries(datapacksDir)) {
            if (allowlist.containsKey(entry)) {
                lockEntry(entry);
                allowlist.put(entry, fingerprint(entry, fingerprints));
                locked.add(entry);
            }
        }
        writeAllowlist(allowlist);
        return locked;
    }

    /**
     * Approves a quarantined pack by name: moves the newest quarantined copy back into the datapacks folder,
     * fingerprints and allowlists it, and locks it. Returns false if no quarantined entry with that name exists.
     * Refuses (FileAlreadyExistsException) to overwrite a pack that is currently in the folder.
     */
    public boolean approve(String name) throws IOException {
        name = requireSafeEntryName(name);
        Path quarantineRoot = stateDir.resolve(QUARANTINE_DIR_NAME);
        if (!Files.isDirectory(quarantineRoot)) {
            return false;
        }
        for (Path batch : batchesNewestFirst(quarantineRoot)) {
            Path candidate = batch.resolve(name).normalize();
            if (!candidate.startsWith(batch.toAbsolutePath().normalize()) && !candidate.startsWith(batch.normalize())) {
                continue;
            }
            if (!Files.exists(candidate, LinkOption.NOFOLLOW_LINKS)) {
                continue;
            }
            Path destination = safeEntryPath(name);
            if (Files.exists(destination, LinkOption.NOFOLLOW_LINKS)) {
                throw new FileAlreadyExistsException(destination.toString(), null,
                        "a pack named '" + name + "' is already in the datapacks folder");
            }
            Files.move(candidate, destination);
            Map<String, String> allowlist = readAllowlist();
            allowlist.put(name, fingerprint(name, new LinkedHashMap<>()));
            writeAllowlist(allowlist);
            lockEntry(name);
            deleteIfEmpty(batch);
            logger.info("Datapack Blocker: '{}' approved, restored, and locked. Run /reload to load it.", name);
            return true;
        }
        return false;
    }

    /** Names currently sitting in quarantine, newest batch first, without duplicates. */
    public List<String> listQuarantined() throws IOException {
        Set<String> names = new java.util.LinkedHashSet<>();
        for (QuarantineEntry entry : listQuarantineEntries()) names.add(entry.name());
        return new ArrayList<>(names);
    }

    public List<QuarantineEntry> listQuarantineEntries() throws IOException {
        Path quarantineRoot = stateDir.resolve(QUARANTINE_DIR_NAME);
        if (!Files.isDirectory(quarantineRoot)) {
            return List.of();
        }
        List<QuarantineEntry> result = new ArrayList<>();
        for (Path batch : batchesNewestFirst(quarantineRoot)) {
            try (DirectoryStream<Path> stream = Files.newDirectoryStream(batch)) {
                List<String> names = new ArrayList<>();
                for (Path path : stream) names.add(path.getFileName().toString());
                names.sort(String::compareTo);
                for (String name : names) result.add(new QuarantineEntry(name, batch.getFileName().toString()));
            }
        }
        return result;
    }

    public int allowlistSize() throws IOException {
        return readAllowlist().size();
    }

    // -- name / path safety ------------------------------------------------

    private static String requireSafeEntryName(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Datapack entry name must not be empty");
        }
        if (name.indexOf('/') >= 0 || name.indexOf('\\') >= 0 || name.equals(".") || name.equals("..")) {
            throw new IllegalArgumentException("Invalid datapack entry name (path traversal rejected): " + name);
        }
        Path asPath = Path.of(name);
        if (asPath.getNameCount() != 1 || asPath.isAbsolute()) {
            throw new IllegalArgumentException("Invalid datapack entry name (must be a single segment): " + name);
        }
        return name;
    }

    private static boolean isStorableName(String name) {
        for (int i = 0; i < name.length(); i++) if (name.charAt(i) < 0x20 || name.charAt(i) == 0x7f) return false;
        return true;
    }

    private Path safeEntryPath(String name) {
        name = requireSafeEntryName(name);
        Path root = datapacksDir.toAbsolutePath().normalize();
        Path target = datapacksDir.resolve(name).toAbsolutePath().normalize();
        if (!target.startsWith(root)) {
            throw new IllegalArgumentException("Path escapes datapacks directory: " + name);
        }
        return target;
    }

    // -- internals ---------------------------------------------------------

    private Path newBatchDir() throws IOException {
        Path quarantineRoot = stateDir.resolve(QUARANTINE_DIR_NAME);
        Files.createDirectories(quarantineRoot);
        String stamp = BATCH_FORMAT.format(Instant.now());
        for (int attempt = 0; ; attempt++) {
            try {
                return Files.createDirectory(quarantineRoot.resolve(attempt == 0 ? stamp : stamp + "-" + attempt));
            } catch (FileAlreadyExistsException exception) {
                if (attempt > 100) throw exception;
            }
        }
    }

    private void quarantineEntry(String name, Path batchDir) throws IOException {
        Path source = safeEntryPath(name);
        // A locked pack's directory must be writable to be renamed into another parent (POSIX updates its '..').
        setWritableTree(source, true);
        Files.move(source, batchDir.resolve(name));
    }

    private void lockEntry(String name) throws IOException {
        setWritableTree(safeEntryPath(name), false);
    }

    /** Never follows symlinks (File#setWritable would chmod the link TARGET, possibly outside the datapacks folder). */
    private static void setWritableTree(Path root, boolean writable) throws IOException {
        if (!Files.exists(root, LinkOption.NOFOLLOW_LINKS)) {
            return;
        }
        if (Files.isDirectory(root, LinkOption.NOFOLLOW_LINKS)) {
            try (Stream<Path> stream = Files.walk(root)) {
                for (Path path : (Iterable<Path>) stream::iterator) applyWritable(path, writable);
            }
        } else {
            applyWritable(root, writable);
        }
    }

    private static void applyWritable(Path path, boolean writable) throws IOException {
        if (Files.isSymbolicLink(path)) {
            return;
        }
        try {
            Set<PosixFilePermission> permissions = new HashSet<>(Files.getPosixFilePermissions(path, LinkOption.NOFOLLOW_LINKS));
            if (writable) {
                // Owner only: version 1.0.0 used setWritable(true, false), i.e. chmod a+w - world-writable packs.
                permissions.add(PosixFilePermission.OWNER_WRITE);
            } else {
                permissions.remove(PosixFilePermission.OWNER_WRITE);
                permissions.remove(PosixFilePermission.GROUP_WRITE);
                permissions.remove(PosixFilePermission.OTHERS_WRITE);
            }
            Files.setPosixFilePermissions(path, permissions);
        } catch (UnsupportedOperationException nonPosix) {
            path.toFile().setWritable(writable, true);
        }
    }

    /**
     * Pack candidates the vanilla loader would consider: directories and .zip files. Hidden directories are only
     * candidates if they contain a pack.mcmeta (so a ".git" folder is left alone, but a hidden pack cannot slip by).
     */
    private List<String> listPackEntries(Path dir) throws IOException {
        if (!Files.isDirectory(dir)) {
            return List.of();
        }
        List<String> names = new ArrayList<>();
        try (DirectoryStream<Path> stream = Files.newDirectoryStream(dir)) {
            for (Path path : stream) {
                String name = path.getFileName().toString();
                boolean isDirectory = Files.isDirectory(path);
                boolean isZip = !isDirectory && Files.isRegularFile(path) && name.toLowerCase(Locale.ROOT).endsWith(".zip");
                if (isZip || (isDirectory && (!name.startsWith(".") || Files.exists(path.resolve("pack.mcmeta"))))) {
                    names.add(name);
                }
            }
        }
        names.sort(String::compareTo);
        return names;
    }

    private static List<Path> batchesNewestFirst(Path quarantineRoot) throws IOException {
        List<Path> batches = new ArrayList<>();
        try (DirectoryStream<Path> stream = Files.newDirectoryStream(quarantineRoot, Files::isDirectory)) {
            stream.forEach(batches::add);
        }
        batches.sort(Comparator.comparing((Path path) -> path.getFileName().toString()).reversed());
        return batches;
    }

    private static void deleteIfEmpty(Path directory) {
        try (DirectoryStream<Path> stream = Files.newDirectoryStream(directory)) {
            if (!stream.iterator().hasNext()) Files.delete(directory);
        } catch (IOException ignored) {
            // leaving an empty batch directory behind is harmless
        }
    }

    // -- fingerprints --------------------------------------------------------

    private String fingerprint(String name, Map<String, String> cache) throws IOException {
        String cached = cache.get(name);
        if (cached != null) return cached;
        String value = fingerprintOf(safeEntryPath(name));
        cache.put(name, value);
        return value;
    }

    /** SHA-256 over relative paths, entry kinds and file bytes. Ignores permissions and mtimes (locking changes them). */
    static String fingerprintOf(Path root) throws IOException {
        MessageDigest digest;
        try {
            digest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException impossible) {
            throw new IllegalStateException(impossible);
        }
        if (Files.isDirectory(root, LinkOption.NOFOLLOW_LINKS)) {
            List<Path> all;
            try (Stream<Path> stream = Files.walk(root)) {
                all = stream.sorted(Comparator.comparing((Path path) -> relative(root, path))).toList();
            }
            for (Path path : all) {
                String rel = relative(root, path);
                if (Files.isSymbolicLink(path)) {
                    digest.update(("L:" + rel + "->" + Files.readSymbolicLink(path) + "\0").getBytes(StandardCharsets.UTF_8));
                } else if (Files.isDirectory(path, LinkOption.NOFOLLOW_LINKS)) {
                    digest.update(("D:" + rel + "\0").getBytes(StandardCharsets.UTF_8));
                } else if (Files.isRegularFile(path, LinkOption.NOFOLLOW_LINKS)) {
                    digest.update(("F:" + rel + ":" + Files.size(path) + "\0").getBytes(StandardCharsets.UTF_8));
                    feed(digest, path);
                } else {
                    digest.update(("O:" + rel + "\0").getBytes(StandardCharsets.UTF_8));
                }
            }
        } else if (Files.isSymbolicLink(root)) {
            digest.update(("L:" + Files.readSymbolicLink(root)).getBytes(StandardCharsets.UTF_8));
        } else {
            digest.update(("F:" + Files.size(root) + "\0").getBytes(StandardCharsets.UTF_8));
            feed(digest, root);
        }
        return HexFormat.of().formatHex(digest.digest());
    }

    private static String relative(Path root, Path path) {
        return root.relativize(path).toString().replace('\\', '/');
    }

    private static void feed(MessageDigest digest, Path file) throws IOException {
        byte[] buffer = new byte[64 * 1024];
        try (InputStream in = Files.newInputStream(file)) {
            int read;
            while ((read = in.read(buffer)) > 0) digest.update(buffer, 0, read);
        }
    }

    // -- allowlist file ------------------------------------------------------

    /** name -> fingerprint; fingerprint is null for a v1 (names-only) line. */
    private Map<String, String> readAllowlist() throws IOException {
        Map<String, String> allowlist = new TreeMap<>();
        if (!Files.exists(allowlistFile)) {
            return allowlist;
        }
        for (String raw : Files.readAllLines(allowlistFile, StandardCharsets.UTF_8)) {
            String line = raw.strip();
            if (line.isEmpty() || line.startsWith("#")) continue;
            int tab = line.indexOf('\t');
            if (tab < 0) {
                allowlist.put(line, null);
            } else {
                String hash = line.substring(tab + 1).strip();
                allowlist.put(line.substring(0, tab).strip(), hash.isEmpty() ? null : hash.toLowerCase(Locale.ROOT));
            }
        }
        return allowlist;
    }

    private void writeAllowlist(Map<String, String> allowlist) throws IOException {
        List<String> lines = new ArrayList<>();
        lines.add(ALLOWLIST_HEADER);
        for (Map.Entry<String, String> entry : new TreeMap<>(allowlist).entrySet()) {
            lines.add(entry.getValue() == null ? entry.getKey() : entry.getKey() + "\t" + entry.getValue());
        }
        Path temporary = allowlistFile.resolveSibling(ALLOWLIST_FILE_NAME + ".tmp");
        Files.write(temporary, lines, StandardCharsets.UTF_8);
        try {
            Files.move(temporary, allowlistFile, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
        } catch (AtomicMoveNotSupportedException exception) {
            Files.move(temporary, allowlistFile, StandardCopyOption.REPLACE_EXISTING);
        }
    }
}
