package net.vortaforge.macroengine.module;

import net.vortaforge.macroengine.lang.Lang;
import net.vortaforge.macroengine.scan.ScanResults;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * {@code macroengine:module/vf_quarantine} - a per-player self-restriction.
 *
 * <h2>What this is</h2>
 *
 * A player can ask to be held back from macroEngine features while the content
 * scan has unresolved findings, and lift it again afterwards. State lives in
 * memory for the session; it is a convenience, not a punishment, and it is never
 * written to disk or to any external system.
 *
 * <h2>What this is emphatically not</h2>
 *
 * It is not an account block. It cannot be applied to another player, it cannot
 * outlive the server process, and no keyword match can trigger it automatically.
 * A finding informs the player; it does not act on their behalf. Anything that
 * blocks a real person on a heuristic is how a security feature becomes a way to
 * lose players, and the audit that produced this mod was explicit about that.
 *
 * <pre>
 *   /function macroengine:module/vf_quarantine {action:"on"}
 *   /function macroengine:module/vf_quarantine {action:"off"}
 *   /function macroengine:module/vf_quarantine {action:"status"}
 * </pre>
 */
public final class QuarantineModule implements MacroModule {

    /** Session-scoped, per player. Lost on restart by design. */
    private static final Map<UUID, Long> HELD = new ConcurrentHashMap<>();

    @Override
    public String id() {
        return "vf_quarantine";
    }

    @Override
    public String description() {
        return "Opt yourself out of macroEngine features while findings are unresolved";
    }

    @Override
    public String run(Context ctx) throws ModuleException {
        UUID player;
        try {
            player = ctx.source().getPlayerOrException().getUUID();
        } catch (Exception e) {
            // The console has no UUID and cannot be held; saying so is clearer
            // than a NullPointerException in a log nobody reads.
            throw new ModuleException("vf_quarantine must be run by a player");
        }

        String action = ctx.args().length > 0 ? ctx.args()[0].trim().toLowerCase(java.util.Locale.ROOT) : "status";
        switch (action) {
            case "on" -> {
                // Refuse to hold someone with nothing to hold them for: an
                // unexplained restriction is indistinguishable from a bug.
                if (ScanResults.current().isClean()) {
                    ctx.log(Lang.format("macroengine.log.quarantine_not_needed"));
                    return "not-needed";
                }
                HELD.put(player, ctx.tick());
                ctx.log(Lang.format("macroengine.log.quarantine_on"));
                return "on";
            }
            case "off" -> {
                boolean was = HELD.remove(player) != null;
                ctx.log(Lang.format(was ? "macroengine.log.quarantine_off" : "macroengine.log.quarantine_was_off"));
                return was ? "off" : "was-off";
            }
            case "status" -> {
                boolean held = HELD.containsKey(player);
                ctx.log(Lang.format(held ? "macroengine.log.quarantine_status_on" : "macroengine.log.quarantine_status_off"));
                return held ? "on" : "off";
            }
            default -> throw new ModuleException(
                    "vf_quarantine: unknown action '" + action + "'; expected on, off or status");
        }
    }

    /** True when this player has asked to be held back. */
    public static boolean isHeld(UUID player) {
        return HELD.containsKey(player);
    }

    /** Drop every hold; called when the server stops so state does not leak across worlds. */
    public static void clearAll() {
        HELD.clear();
    }
}
