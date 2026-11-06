package net.vortaforge.macroengine.module;

import net.vortaforge.macroengine.lang.Lang;
import net.vortaforge.macroengine.scan.ScanResults;
import net.vortaforge.macroengine.validate.PackMetaValidator;
import net.vortaforge.macroengine.validate.PackScanner;
import net.vortaforge.macroengine.validate.SuspiciousText;

import java.util.List;

/**
 * {@code macroengine:module/vf_report} - a structural report of the last scan.
 *
 * <p>Prints counts and the first few concrete findings. Used by the in-game
 * "Content check" screen and by {@code macroengine:module/vf_report} from a pack
 * function. It reports the scan's own limits too: if the scan was capped before
 * finishing, that is stated, because "0 findings" from a truncated scan means
 * nothing.
 */
public final class ReportModule implements MacroModule {

    /** How many individual findings to print before summarising the rest. */
    private static final int MAX_DETAIL = 5;

    @Override
    public String id() {
        return "vf_report";
    }

    @Override
    public String description() {
        return "Print a structural report of the last content scan";
    }

    @Override
    public String run(Context ctx) {
        PackScanner.Report report = ScanResults.current();

        ctx.log(Lang.format("macroengine.log.report_header", report.packsInspected(), report.filesScanned()));

        if (!report.inspectedAnything()) {
            ctx.log(Lang.format("macroengine.log.scanned_nothing"));
            return "no-scan";
        }

        for (PackMetaValidator.Problem problem : report.metaProblems()) {
            ctx.log(Lang.format("macroengine.log.meta_problem", problem.where(), problem.message()));
        }

        List<SuspiciousText.Finding> findings = report.findings();
        int shown = 0;
        for (SuspiciousText.Finding finding : findings) {
            if (shown++ >= MAX_DETAIL) {
                ctx.log(Lang.format("macroengine.log.more_findings", findings.size() - MAX_DETAIL));
                break;
            }
            ctx.log(Lang.format("macroengine.log.finding",
                    finding.severity(), finding.kind(), finding.where()));
        }

        for (String error : report.scanErrors()) {
            ctx.log(Lang.format("macroengine.log.scan_error", error));
        }

        return AlertModule.Verdict.of(report).token();
    }
}
