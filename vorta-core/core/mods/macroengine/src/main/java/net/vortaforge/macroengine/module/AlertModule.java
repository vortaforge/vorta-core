package net.vortaforge.macroengine.module;

import net.vortaforge.macroengine.scan.ScanResults;
import net.vortaforge.macroengine.validate.PackScanner;

/**
 * {@code macroengine:module/vf_alert} - report the current verdict to the caller.
 *
 * <p>Where {@code vf_log} writes a message, this answers a question: is the
 * content loaded on this world currently clean, warned, or flagged? A datapack
 * function can branch on the answer, so a pack can refuse to open its own menu
 * while an unresolved finding exists, instead of pretending nothing happened.
 *
 * <p>Arguments: none. Returns {@code clean}, {@code warnings} or {@code flagged}.
 */
public final class AlertModule implements MacroModule {

    /** How bad the current world's scan looks, from the reader's point of view. */
    public enum Verdict {
        /** Nothing found. */
        CLEAN("clean"),
        /** Findings that a human should read, but nothing that hands data away. */
        WARNINGS("warnings"),
        /** At least one high-severity finding. */
        FLAGGED("flagged");

        private final String token;

        Verdict(String token) {
            this.token = token;
        }

        public String token() {
            return token;
        }

        public static Verdict of(PackScanner.Report report) {
            if (!report.inspectedAnything()) {
                // A scan that examined nothing is not a pass. Reporting "clean"
                // here is the exact overclaim this project keeps having to correct.
                return FLAGGED;
            }
            if (report.count(net.vortaforge.macroengine.validate.SuspiciousText.Severity.HIGH) > 0
                    || !report.metaProblems().isEmpty()) {
                return FLAGGED;
            }
            if (!report.findings().isEmpty() || !report.scanErrors().isEmpty()) {
                return WARNINGS;
            }
            return CLEAN;
        }
    }

    @Override
    public String id() {
        return "vf_alert";
    }

    @Override
    public String description() {
        return "Return the current content verdict: clean, warnings or flagged";
    }

    @Override
    public String run(Context ctx) {
        Verdict verdict = Verdict.of(ScanResults.current());
        ctx.log("macrolengine verdict: " + verdict.token());
        return verdict.token();
    }
}
