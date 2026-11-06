package net.vortaforge.macroengine.validate;

import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import net.minecraft.resources.Identifier;
import net.minecraft.server.packs.PackResources;
import net.minecraft.server.packs.PackType;
import net.minecraft.server.packs.resources.IoSupplier;
import net.minecraft.server.packs.resources.Resource;
import net.minecraft.server.packs.resources.ResourceManager;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeSet;

/**
 * Walks every data pack the game has loaded and runs the validators over it.
 *
 * <h2>Why scan the loaded packs instead of a folder on disk</h2>
 *
 * A pack a player installs can be a folder, a zip, or a built-in pack, and the
 * paths on disk differ per launcher and per server. The {@link ResourceManager}
 * is the one view that already knows about all of them and has already resolved
 * which files actually win when two packs collide. Scanning anything else would
 * either miss zipped packs or re-implement pack ordering badly.
 *
 * <h2>What this scanner reports on itself</h2>
 *
 * A scan that silently examines nothing looks identical to a scan that found
 * nothing wrong. Every scan therefore carries a count of what it actually looked
 * at, and a scan that examined zero packs is reported as a failure to scan
 * rather than as a clean result.
 */
public final class PackScanner {
    private PackScanner() {
    }

    /** What a single scan did and what it found. */
    public record Report(
            int packsInspected,
            int filesScanned,
            List<SuspiciousText.Finding> findings,
            List<PackMetaValidator.Problem> metaProblems,
            List<String> scanErrors,
            List<String> packsSeen
    ) {
        public boolean isClean() {
            return findings.isEmpty() && metaProblems.isEmpty() && scanErrors.isEmpty();
        }

        /** A scan that inspected nothing cannot claim to be clean. */
        public boolean inspectedAnything() {
            return packsInspected > 0;
        }

        public long count(SuspiciousText.Severity severity) {
            return findings.stream().filter(f -> f.severity() == severity).count();
        }

        /** One-line verdict for the log, never overstating what was checked. */
        public String summaryLine() {
            if (!inspectedAnything()) {
                return "macroEngine: scan examined 0 packs - cannot report a result";
            }
            StringBuilder sb = new StringBuilder();
            sb.append("macroEngine: inspected ").append(packsInspected).append(" data pack(s), ")
                    .append(filesScanned).append(" file(s); ")
                    .append(count(SuspiciousText.Severity.HIGH)).append(" high, ")
                    .append(count(SuspiciousText.Severity.WARN)).append(" warn, ")
                    .append(metaProblems.size()).append(" metadata problem(s)");
            if (!scanErrors.isEmpty()) {
                sb.append(", ").append(scanErrors.size()).append(" scan error(s)");
            }
            return sb.toString();
        }
    }

    /**
     * Scan the data packs currently visible through {@code manager}.
     *
     * @param manager  the game's reloadable resource manager
     * @param maxFiles a hard cap so a pathological pack cannot stall world load
     */
    public static Report scan(ResourceManager manager, int maxFiles) {
        List<SuspiciousText.Finding> findings = new ArrayList<>();
        List<PackMetaValidator.Problem> metaProblems = new ArrayList<>();
        List<String> errors = new ArrayList<>();
        TreeSet<String> packsSeen = new TreeSet<>();
        int files = 0;

        // 1. pack.mcmeta for every pack, not just the winner.
        //
        // `getResourceStack` returns every pack that provides a file, not only the
        // top one. Using the winner alone would hide a broken pack that is being
        // shadowed by a working one - and that broken pack becomes the winner the
        // moment the other is removed.
        try {
            for (Resource resource : manager.getResourceStack(Identifier.parse("pack.mcmeta"))) {
                String id = safePackId(resource);
                packsSeen.add(id);
                try (InputStream in = resource.open()) {
                    JsonElement parsed = JsonParser.parseString(readAll(in));
                    metaProblems.addAll(PackMetaValidator.validate(parsed, "pack.mcmeta [" + id + "]"));
                } catch (RuntimeException | IOException e) {
                    errors.add("pack.mcmeta [" + id + "]: unreadable (" + e.getMessage() + ")");
                }
            }
        } catch (RuntimeException e) {
            errors.add("could not enumerate pack.mcmeta: " + e.getMessage());
        }

        // 2. Every data file: functions, advancements, dialogs, loot tables, tags.
        Map<String, String> roots = new LinkedHashMap<>();
        roots.put("function", "data/*/function");
        roots.put("advancement", "data/*/advancement");
        roots.put("dialog", "data/*/dialog");
        roots.put("loot_table", "data/*/loot_table");
        roots.put("predicate", "data/*/predicate");
        roots.put("item_modifier", "data/*/item_modifier");
        roots.put("recipe", "data/*/recipe");
        roots.put("tags", "data/*/tags");

        for (Map.Entry<String, String> root : roots.entrySet()) {
            try {
                Map<Identifier, Resource> listed = manager.listResources(
                        root.getKey(), id -> id.getPath().endsWith(".json") || id.getPath().endsWith(".mcfunction"));
                for (Map.Entry<Identifier, Resource> entry : listed.entrySet()) {
                    if (files >= maxFiles) {
                        errors.add("stopped after " + maxFiles + " files; remaining packs were not fully scanned");
                        break;
                    }
                    files++;
                    String where = entry.getKey().toString();
                    packsSeen.add(safePackId(entry.getValue()));
                    try (InputStream in = entry.getValue().open()) {
                        findings.addAll(SuspiciousText.scan(readAll(in), where));
                    } catch (RuntimeException | IOException e) {
                        errors.add(where + ": unreadable (" + e.getMessage() + ")");
                    }
                }
            } catch (RuntimeException e) {
                errors.add("could not list " + root.getValue() + ": " + e.getMessage());
            }
        }

        return new Report(packsSeen.size(), files, List.copyOf(findings), List.copyOf(metaProblems),
                List.copyOf(errors), List.copyOf(packsSeen));
    }

    /**
     * Root resources of one pack, used to read a pack's own pack.mcmeta when the
     * caller already has the {@link PackResources} in hand.
     */
    public static String packMetaOf(PackResources pack) {
        IoSupplier<InputStream> supplier = pack.getRootResource("pack.mcmeta");
        if (supplier == null) {
            return null;
        }
        try (InputStream in = supplier.get()) {
            return readAll(in);
        } catch (IOException e) {
            return null;
        }
    }

    /** Namespaces a pack declares, for a sanity check that data/ actually matches. */
    public static void namespaces(PackResources pack, PackType type, java.util.Set<String> into) {
        into.addAll(pack.getNamespaces(type));
    }

    private static String safePackId(Resource resource) {
        try {
            String id = resource.sourcePackId();
            return id == null || id.isBlank() ? "unknown-pack" : id.toLowerCase(Locale.ROOT);
        } catch (RuntimeException e) {
            return "unknown-pack";
        }
    }

    private static String readAll(InputStream in) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            char[] buf = new char[4096];
            int n;
            while ((n = reader.read(buf)) > 0) {
                sb.append(buf, 0, n);
                if (sb.length() > 2_000_000) {
                    // A single data file this size is already a finding, not a file
                    // worth fully buffering.
                    sb.append("\n[macroEngine: file truncated at 2 MB]");
                    break;
                }
            }
        }
        return sb.toString();
    }
}
