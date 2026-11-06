package net.vortaforge.macroengine.client;

import net.vortaforge.macroengine.validate.PackScanner;
import net.vortaforge.macroengine.validate.SuspiciousText;

import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

/**
 * The client's copy of the last scan.
 *
 * <p>Kept separate from the server-side holder on purpose: on a multiplayer client
 * the server's scan is not visible, and merging the two would let a single-player
 * result leak into a multiplayer session or the other way round.
 */
public final class ClientScanResults {
    private static final AtomicReference<PackScanner.Report> CURRENT = new AtomicReference<>(null);

    private ClientScanResults() {
    }

    public static void publish(PackScanner.Report report) {
        CURRENT.set(report);
    }

    /** Record a scan that could not run, without pretending it was clean. */
    public static void publishFailure(String reason) {
        CURRENT.set(new PackScanner.Report(0, 0, List.of(), List.of(), List.of(reason), List.of()));
    }

    public static PackScanner.Report current() {
        PackScanner.Report report = CURRENT.get();
        if (report != null) {
            return report;
        }
        return new PackScanner.Report(0, 0, List.of(), List.of(),
                List.of("the content check has not run yet"), List.of());
    }

    public static boolean hasProblems() {
        PackScanner.Report report = current();
        return !report.findings().isEmpty()
                || !report.metaProblems().isEmpty()
                || report.count(SuspiciousText.Severity.HIGH) > 0;
    }
}
