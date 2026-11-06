package net.vortaforge.macroengine;

import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerLifecycleEvents;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.packs.resources.ResourceManager;
import net.vortaforge.macroengine.command.MacroCommand;
import net.vortaforge.macroengine.lang.Lang;
import net.vortaforge.macroengine.module.AlertModule;
import net.vortaforge.macroengine.module.LangModule;
import net.vortaforge.macroengine.module.ModuleRegistry;
import net.vortaforge.macroengine.module.QuarantineModule;
import net.vortaforge.macroengine.module.ReportModule;
import net.vortaforge.macroengine.validate.PackScanner;
import net.vortaforge.macroengine.validate.SuspiciousText;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

/**
 * macroEngine - server-side validation for the macroEngine datapack.
 *
 * <h2>What problem this solves</h2>
 *
 * The datapack this mod is paired with is a scripting layer built out of
 * functions, advancements, dialogs and tags. A vanilla datapack has no type
 * checking and no error surface: a wrong field name, a format number that lies,
 * or a string that is really an instruction aimed at whatever reads the files
 * next all fail silently or fail late. The pack has no way to tell its operator
 * that it saw something it did not like.
 *
 * <p>This mod adds that missing surface. It reads the packs the game has actually
 * loaded - not a folder on disk, which would miss zips and built-in packs - and
 * reports structural problems and content problems at world load, in the server
 * log, and in a warning the player sees before they press "Create New World".
 *
 * <h2>The one rule this mod is built around</h2>
 *
 * It reports. It does not punish. Nothing here can block a player account, contact
 * another service, or act on a keyword match by itself. A finding is a sentence
 * for a human to read; anything more would make a heuristic into a weapon, and the
 * substring-matching bug fixed earlier in this repository ("claude" matching
 * "claudette") is the small version of exactly that mistake.
 */
public final class MacroEngine implements ModInitializer {
    public static final String MOD_ID = "macroengine";
    public static final Logger LOG = LoggerFactory.getLogger(MOD_ID);

    /** Hard cap on files per scan, so a pathological pack cannot stall world load. */
    public static final int MAX_SCAN_FILES = 6000;

    private static MinecraftServer currentServer;

    @Override
    public void onInitialize() {
        LOG.info("macroEngine starting - validator for loaded data packs");

        registerModules();

        ServerLifecycleEvents.SERVER_STARTED.register(MacroEngine::onServerStarted);
        ServerLifecycleEvents.SERVER_STOPPING.register(MacroEngine::onServerStopping);

        MacroCommand.register();

        LOG.info("macroEngine ready: {} module(s), {} translation key(s)",
                ModuleRegistry.size(), Lang.size());
    }

    private static void registerModules() {
        // The module list is the datapack's public API surface. Keeping it in one
        // place makes it reviewable at a glance, and the registry's duplicate check
        // makes a collision loud instead of silent.
        List.of(
                new LangModule(),
                new ReportModule(),
                new AlertModule(),
                new QuarantineModule()
        ).forEach(ModuleRegistry::register);
    }

    /**
     * Runs once the world is fully loaded, which is the first moment the data pack
     * stack is final. Doing this earlier would scan a set of packs that is still
     * being assembled and report on content that is not what the player will play.
     */
    private static void onServerStarted(MinecraftServer server) {
        currentServer = server;
        scanAndReport("server start", server.getResourceManager());
    }

    private static void onServerStopping(MinecraftServer server) {
        QuarantineModule.clearAll();
        currentServer = null;
    }

    /**
     * Scan, publish, log, and warn. Used by both the startup hook and the
     * {@code /macroengine rescan} command, so the two cannot drift apart.
     *
     * @return the published report
     */
    public static PackScanner.Report scanAndReport(String trigger, ResourceManager manager) {
        long startedAt = System.nanoTime();

        List<String> langWarnings = new ArrayList<>();
        Lang.reload(manager, (where, message) -> langWarnings.add(where + ": " + message));

        PackScanner.Report report = PackScanner.scan(manager, MAX_SCAN_FILES);
        net.vortaforge.macroengine.scan.ScanResults.publish(report);

        long millis = Math.max(0, (System.nanoTime() - startedAt) / 1_000_000);

        // The summary line always states what was inspected. A "clean" claim that
        // does not say how much was looked at is unfalsifiable, and this project
        // has already had to correct one enforcement claim that worked that way.
        LOG.info("{} ({}, {} ms)", report.summaryLine(), trigger, millis);

        for (String warning : langWarnings) {
            LOG.warn("macroEngine: language file problem - {}", warning);
        }

        for (var problem : report.metaProblems()) {
            LOG.warn("macroEngine: pack.mcmeta problem - {}", problem);
        }
        for (String error : report.scanErrors()) {
            LOG.warn("macroEngine: scan error - {}", error);
        }
        for (SuspiciousText.Finding finding : report.findings()) {
            logFinding(finding);
        }

        if (report.inspectedAnything() && report.isClean()) {
            LOG.info("macroEngine: no findings in {} pack(s)", report.packsInspected());
        }
        return report;
    }

    private static void logFinding(SuspiciousText.Finding finding) {
        // Severity decides the log level, not the author's intent. HIGH means
        // "someone should look at this before it ships", and a DEBUG line for that
        // would be invisible on every default server.
        switch (finding.severity()) {
            case HIGH -> LOG.warn("macroEngine: [HIGH] {} at {}: \"{}\" - {}",
                    finding.kind(), finding.where(), finding.snippet(), finding.why());
            case WARN -> LOG.warn("macroEngine: [warn] {} at {}: \"{}\" - {}",
                    finding.kind(), finding.where(), finding.snippet(), finding.why());
            case INFO -> LOG.info("macroEngine: [info] {} at {}: \"{}\" - {}",
                    finding.kind(), finding.where(), finding.snippet(), finding.why());
        }
    }

    public static MinecraftServer server() {
        return currentServer;
    }

    /** True when this build is running against a development workspace. */
    public static boolean isDevelopment() {
        return FabricLoader.getInstance().isDevelopmentEnvironment();
    }
}
