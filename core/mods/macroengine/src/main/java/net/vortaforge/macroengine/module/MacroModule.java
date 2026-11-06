package net.vortaforge.macroengine.module;

import net.minecraft.commands.CommandSourceStack;

/**
 * A macroEngine unit of behaviour that the datapack can invoke.
 *
 * <h2>The boundary this interface enforces</h2>
 *
 * Every module receives a {@link Context} and nothing else. It has no handle on
 * the network, on files outside the loaded packs, or on the host process. That is
 * not a stylistic choice: the point of this mod is to sit next to untrusted
 * content, and a module that could open a socket or read {@code ~/.ssh} would
 * make the whole exercise theatre. A module is a pure function of the world state
 * it is handed plus its own arguments.
 *
 * <h2>Why modules are registered instead of hard-coded</h2>
 *
 * The datapack calls them by name ({@code macroengine:module/vf_log} and friends),
 * so adding one must not mean editing a switch statement and hoping no branch was
 * missed. Registration also makes the module list inspectable at runtime, which is
 * what {@code macroengine:module/list} reports.
 */
public interface MacroModule {

    /** Stable id, used in logs and in error messages. Never localised. */
    String id();

    /** One line describing what it does, for the in-game debug output. */
    String description();

    /**
     * Run the module.
     *
     * @return a short result string for the caller's {@code /execute ... run}
     *         feedback; never null
     * @throws ModuleException when the arguments are wrong. Deliberately not a
     *                         RuntimeException subclass: a bad argument is an
     *                         expected condition and should be reported, not
     *                         stack-traced into the server log every tick.
     */
    String run(Context ctx) throws ModuleException;

    /** Everything a module is allowed to touch. */
    interface Context {
        /** The command source that triggered the call, or the server console. */
        CommandSourceStack source();

        /** Raw arguments after the module id. */
        String[] args();

        /** Write to the macroEngine log channel (server log + players, per config). */
        void log(String message);

        /** Current game tick, for modules that need a stable ordering. */
        long tick();
    }

    /** Bad arguments. Expected, reported, not fatal. */
    class ModuleException extends Exception {
        public ModuleException(String message) {
            super(message);
        }
    }
}
