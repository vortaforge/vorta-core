package com.vortacraftmc.datapackblocker;

import static org.junit.jupiter.api.Assertions.*;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.PosixFilePermission;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.helpers.NOPLogger;

class AllowlistManagerTest {
    private Path world;
    private Path datapacks;

    @BeforeEach void setUp() throws Exception {
        world = Files.createTempDirectory("dpb-world");
        datapacks = Files.createDirectories(world.resolve("datapacks"));
    }

    private AllowlistManager manager() {
        return new AllowlistManager(datapacks, world, NOPLogger.NOP_LOGGER);
    }

    private Path pack(String name, String content) throws Exception {
        Path dir = Files.createDirectories(datapacks.resolve(name).resolve("data/x/function"));
        Files.writeString(datapacks.resolve(name).resolve("pack.mcmeta"), "{}");
        Files.writeString(dir.resolve("a.mcfunction"), content);
        return datapacks.resolve(name);
    }

    @Test void firstRunBaselinesEverythingAndBlocksNothing() throws Exception {
        pack("one", "say 1");
        var result = manager().enforce();
        assertTrue(result.firstRun());
        assertTrue(result.quarantinedPacks().isEmpty());
        assertEquals(List.of("one"), result.protectedPacks());
        assertTrue(Files.exists(datapacks.resolve("one")));
    }

    @Test void newPackIsQuarantinedInEarlyPhase() throws Exception {
        pack("one", "say 1");
        manager().enforce();
        pack("evil", "say pwn");
        var result = manager().enforce(AllowlistManager.Phase.EARLY);
        assertEquals(List.of("evil"), result.quarantinedPacks());
        assertFalse(Files.exists(datapacks.resolve("evil")));
        assertEquals(List.of("evil"), manager().listQuarantined());
    }

    @Test void latePhaseReportsButNeverMoves() throws Exception {
        pack("one", "say 1");
        manager().enforce();
        pack("evil", "say pwn");
        var result = manager().enforce(AllowlistManager.Phase.LATE);
        assertTrue(result.quarantinedPacks().isEmpty());
        assertEquals(List.of("evil"), result.unreviewedPacks());
        assertTrue(Files.exists(datapacks.resolve("evil")), "moving after the server loaded the pack would be misleading and can break lazy loads");
    }

    @Test void modifiedAllowlistedPackIsQuarantinedEvenThoughItsNameIsKnown() throws Exception {
        Path one = pack("one", "say 1");
        manager().enforce();
        manager().unlock();
        Files.writeString(one.resolve("data/x/function/a.mcfunction"), "say backdoor");
        // forgot /datapackblocker lock -> restart
        var result = manager().enforce();
        assertEquals(List.of("one"), result.quarantinedPacks());
        assertFalse(Files.exists(one));
    }

    @Test void lockRecordsEditedContentsAsTrusted() throws Exception {
        Path one = pack("one", "say 1");
        manager().enforce();
        manager().unlock();
        Files.writeString(one.resolve("data/x/function/a.mcfunction"), "say edited by operator");
        manager().lock();
        var result = manager().enforce();
        assertTrue(result.quarantinedPacks().isEmpty());
        assertEquals(List.of("one"), result.protectedPacks());
    }

    @Test void replacingAnApprovedPackUnderTheSameNameIsCaught() throws Exception {
        Path one = pack("one", "say 1");
        manager().enforce();
        manager().unlock();
        Files.delete(one.resolve("data/x/function/a.mcfunction"));
        Files.writeString(one.resolve("data/x/function/a.mcfunction"), "say swapped");
        assertEquals(List.of("one"), manager().audit().modified());
    }

    @Test void lockAndUnlockNeverMakeFilesWorldWritable() throws Exception {
        Path one = pack("one", "say 1");
        Path file = one.resolve("data/x/function/a.mcfunction");
        try {
            Files.getPosixFilePermissions(file);
        } catch (UnsupportedOperationException skip) {
            return;
        }
        manager().enforce();
        assertTrue(Files.getPosixFilePermissions(file).stream().noneMatch(p -> p.name().endsWith("_WRITE")), "locked");
        manager().unlock();
        Set<PosixFilePermission> unlocked = Files.getPosixFilePermissions(file);
        assertTrue(unlocked.contains(PosixFilePermission.OWNER_WRITE));
        assertFalse(unlocked.contains(PosixFilePermission.OTHERS_WRITE), "1.0.0 used setWritable(true,false) == chmod a+w");
        assertFalse(unlocked.contains(PosixFilePermission.GROUP_WRITE));
    }

    @Test void lockingNeverTouchesSymlinkTargetsOutsideThePack() throws Exception {
        Path outside = Files.createTempFile("dpb-outside", ".dat");
        Path one = pack("one", "say 1");
        try {
            Files.createSymbolicLink(one.resolve("link.dat"), outside);
        } catch (UnsupportedOperationException | java.io.IOException skip) {
            return;
        }
        var before = Files.getPosixFilePermissions(outside);
        manager().enforce();
        assertEquals(before, Files.getPosixFilePermissions(outside), "File#setWritable would have chmod'ed the link target");
    }

    @Test void approveRestoresNewestBatchRefusesOverwriteAndFingerprints() throws Exception {
        pack("one", "say 1");
        manager().enforce();
        pack("evil", "say pwn");
        manager().enforce();
        assertTrue(manager().approve("evil"));
        assertTrue(Files.exists(datapacks.resolve("evil")));
        assertTrue(manager().listQuarantined().isEmpty());
        assertTrue(manager().audit().clean());
        assertTrue(manager().enforce().quarantinedPacks().isEmpty(), "approved pack must survive the next start");

        // second evil copy, then try to approve while another one is in place
        manager().unlock();
        Path moved = datapacks.resolve("evil");
        deleteTree(moved);
        pack("evil", "say again");
        manager().enforce(); // modified -> quarantined
        pack("evil", "say third");
        assertThrows(java.nio.file.FileAlreadyExistsException.class, () -> manager().approve("evil"));
    }

    @Test void approveRejectsPathTraversal() throws Exception {
        pack("one", "say 1");
        manager().enforce();
        assertThrows(IllegalArgumentException.class, () -> manager().approve("../one"));
        assertThrows(IllegalArgumentException.class, () -> manager().approve("a/b"));
        assertThrows(IllegalArgumentException.class, () -> manager().approve(".."));
    }

    @Test void v1NamesOnlyAllowlistIsMigratedInPlace() throws Exception {
        pack("one", "say 1");
        Files.createDirectories(world.resolve("datapack_blocker"));
        Files.writeString(world.resolve("datapack_blocker/allowlist.txt"), "one\n");
        var result = manager().enforce();
        assertFalse(result.firstRun());
        assertTrue(result.quarantinedPacks().isEmpty());
        assertTrue(Files.readString(world.resolve("datapack_blocker/allowlist.txt")).contains("one\t"));
    }

    @Test void hiddenDirsWithoutMcmetaAreIgnoredButHiddenPacksAreNot() throws Exception {
        pack("one", "say 1");
        manager().enforce();
        Files.createDirectories(datapacks.resolve(".git"));
        pack(".sneaky", "say hidden");
        Files.writeString(datapacks.resolve("notes.txt"), "hi");
        var result = manager().enforce();
        assertEquals(List.of(".sneaky"), result.quarantinedPacks());
        assertTrue(Files.exists(datapacks.resolve(".git")));
        assertTrue(Files.exists(datapacks.resolve("notes.txt")));
    }

    @Test void zipPacksAreFingerprintedToo() throws Exception {
        Path zip = datapacks.resolve("pack.zip");
        Files.write(zip, new byte[] {1, 2, 3});
        manager().enforce();
        manager().unlock();
        Files.write(zip, new byte[] {1, 2, 4});
        assertEquals(List.of("pack.zip"), manager().audit().modified());
    }

    @Test void auditIsReadOnly() throws Exception {
        pack("one", "say 1");
        manager().enforce();
        pack("evil", "say pwn");
        var audit = manager().audit();
        assertEquals(List.of("evil"), audit.unreviewed());
        assertEquals(1, audit.ok());
        assertTrue(Files.exists(datapacks.resolve("evil")));
    }

    @Test void removedPackShowsUpAsMissing() throws Exception {
        Path one = pack("one", "say 1");
        manager().enforce();
        manager().unlock();
        deleteTree(one);
        assertEquals(List.of("one"), manager().audit().missing());
    }

    private static void deleteTree(Path root) throws Exception {
        try (var paths = Files.walk(root)) {
            for (Path p : paths.sorted(java.util.Comparator.reverseOrder()).toList()) Files.delete(p);
        }
    }
}
