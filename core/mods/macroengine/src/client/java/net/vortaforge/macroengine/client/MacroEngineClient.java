package net.vortaforge.macroengine.client;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientLifecycleEvents;
import net.fabricmc.fabric.api.client.screen.v1.ScreenEvents;
import net.fabricmc.fabric.api.client.screen.v1.Screens;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.client.gui.screens.TitleScreen;
import net.minecraft.client.server.IntegratedServer;
import net.vortaforge.macroengine.validate.PackScanner;
import net.vortaforge.macroengine.validate.SuspiciousText;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Client half: the warning that appears before a world is created or opened.
 *
 * <h2>Two different moments, one message</h2>
 *
 * <ul>
 *   <li><b>The title screen.</b> On the client the world's data pack stack is not
 *       final until the integrated server has started. So the title screen cannot
 *       scan the packs - it can only say that a check will happen and that it can
 *       be run now.</li>
 *   <li><b>World load.</b> The client resource manager is the authoritative view of
 *       what will load, and it is available before the integrated server is up.</li>
 * </ul>
 *
 * The scan the player sees therefore runs against the client resource manager,
 * which is the same manager the game uses to load pack contents. It is not a
 * re-implementation of pack discovery, and it is not a scan of a guess about
 * where packs live on disk.
 *
 * <h2>What this deliberately does not do</h2>
 *
 * It does not block world creation. A player who has read the warning can
 * continue; a scan that cannot be argued with is a scan people disable. The
 * "Continue anyway" button is only relabelled more plainly when a high-severity
 * finding exists - it is never removed.
 */
public final class MacroEngineClient implements ClientModInitializer {
    private static final Logger LOG = LoggerFactory.getLogger("macroengine-client");

    /** How long to wait after the title screen appears before scanning, in ticks. */
    private static final int SCAN_DELAY_TICKS = 20;

    @Override
    public void onInitializeClient() {
        ClientLifecycleEvents.CLIENT_STARTED.register(client -> scheduleScan(client));
        registerTitleScreenNotice();
        LOG.info("macroEngine client ready");
    }

    /**
     * Scan once the client is up, then keep the result for whatever screen asks
     * for it next.
     */
    private static void scheduleScan(Minecraft client) {
        // No scheduler is exposed for "after N ticks" through a stable API here, so
        // the scan runs on the first world-less frame where the resource manager is
        // populated. A failure is logged and skipped: a broken scan must not stop
        // the game from starting.
        try {
            PackScanner.Report report = PackScanner.scan(client.getResourceManager(), 2000);
            ClientScanResults.publish(report);
            LOG.info(report.summaryLine());
            for (SuspiciousText.Finding finding : report.findings()) {
                LOG.warn("macroEngine client: {}", finding);
            }
            for (var problem : report.metaProblems()) {
                LOG.warn("macroEngine client: {}", problem);
            }
        } catch (RuntimeException e) {
            LOG.warn("macroEngine client: scan failed and was skipped - {}", e.toString());
            ClientScanResults.publishFailure(e.toString());
        }
    }

    /**
     * Put a "Content check" button on the title screen.
     *
     * <p>Added as an extra widget rather than by replacing the screen: a mod that
     * replaces the title screen is one of the most common sources of "this mod
     * breaks with that mod", and it is not necessary for a button.
     */
    private static void registerTitleScreenNotice() {
        ScreenEvents.AFTER_INIT.register((client, screen, scaledWidth, scaledHeight) -> {
            if (!(screen instanceof TitleScreen)) {
                return;
            }
            var button = net.minecraft.client.gui.components.Button.builder(
                            net.minecraft.network.chat.Component.literal("Content check"),
                            b -> openWarning(client, screen))
                    .bounds(scaledWidth - 108, 6, 104, 20)
                    .build();
            if (ClientScanResults.hasProblems()) {
                // A quiet button is easy to ignore; re-labelling it is the whole
                // point of having computed the result.
                button.setMessage(net.minecraft.network.chat.Component.literal("⚠ Content check"));
            }
            Screens.getWidgets(screen).add(button);
        });
    }

    private static void openWarning(Minecraft client, Screen parent) {
        PackScanner.Report report = ClientScanResults.current();
        boolean high = report.count(SuspiciousText.Severity.HIGH) > 0 || !report.metaProblems().isEmpty();

        // The button is always clickable. A player who presses it with a clean pack
        // should get "nothing found", not nothing at all.
        client.setScreenAndShow(new ContentWarningScreen(parent, report.findings(),
                report.metaProblems(), high));
    }

    /** Exposed so the world-open path can show the warning before the world loads. */
    public static void showWorldWarningIfNeeded(Minecraft client, Screen parent, IntegratedServer server) {
        PackScanner.Report report = ClientScanResults.current();
        if (report.findings().isEmpty() && report.metaProblems().isEmpty()) {
            return;
        }
        boolean high = report.count(SuspiciousText.Severity.HIGH) > 0 || !report.metaProblems().isEmpty();
        client.setScreenAndShow(new ContentWarningScreen(parent, report.findings(),
                report.metaProblems(), high));
    }
}
