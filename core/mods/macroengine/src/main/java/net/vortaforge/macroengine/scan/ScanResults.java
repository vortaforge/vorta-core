package net.vortaforge.macroengine.scan;

import net.vortaforge.macroengine.validate.PackScanner;

import java.util.concurrent.atomic.AtomicReference;

/**
 * The most recent scan, shared between the code that runs it and the code that
 * reports on it.
 *
 * <p>Holding it in one place keeps the report honest: the screen, the log line and
 * the datapack module all read the same object, so they cannot disagree about
 * what was found. A missing scan is represented explicitly rather than as an
 * empty clean report, because "we have not looked" and "we looked and found
 * nothing" are different statements and must not render the same way.
 */
public final class ScanResults {
    private static final AtomicReference<PackScanner.Report> CURRENT = new AtomicReference<>(null);

    private ScanResults() {
    }

    public static void publish(PackScanner.Report report) {
        CURRENT.set(report);
    }

    /**
     * The latest report, or an explicit "never scanned" report.
     *
     * <p>The fallback has {@code packsInspected == 0}, so everything downstream
     * that checks {@code inspectedAnything()} treats it as a failure to scan
     * rather than as a clean result.
     */
    public static PackScanner.Report current() {
        PackScanner.Report report = CURRENT.get();
        if (report != null) {
            return report;
        }
        return new PackScanner.Report(0, 0, java.util.List.of(), java.util.List.of(),
                java.util.List.of("no scan has run yet"), java.util.List.of());
    }

    public static boolean hasRun() {
        return CURRENT.get() != null;
    }

    public static void clear() {
        CURRENT.set(null);
    }
}
