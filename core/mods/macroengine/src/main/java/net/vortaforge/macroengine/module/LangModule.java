package net.vortaforge.macroengine.module;

import net.vortaforge.macroengine.lang.Lang;

/**
 * {@code macroengine:module/vf_log} - log a localised message from the datapack.
 *
 * <p>The datapack's functions already have a log system ({@code systems/log} in
 * the pack). It writes plain strings. This module exists so a function can log a
 * message that is translated: the argument is a translation key plus optional
 * placeholders, resolved against the player's own language on the client and the
 * server's configured language on a dedicated server.
 *
 * <pre>
 *   /function macroengine:module/vf_log {key:"macroengine.msg.gate_open", with:["Player1"]}
 * </pre>
 */
public final class LangModule implements MacroModule {

    @Override
    public String id() {
        return "vf_log";
    }

    @Override
    public String description() {
        return "Log a localised message via a translation key";
    }

    @Override
    public String run(Context ctx) throws ModuleException {
        String[] args = ctx.args();
        if (args.length == 0 || args[0].isBlank()) {
            throw new ModuleException("vf_log needs a translation key as its first argument");
        }
        String key = args[0].trim();
        if (!Lang.has(key)) {
            // Report the miss rather than logging a raw key at a player. A missing
            // key in a released pack is a defect worth seeing in the log.
            throw new ModuleException("vf_log: no translation for key '" + key + "'");
        }
        String[] placeholders = new String[Math.max(0, args.length - 1)];
        System.arraycopy(args, 1, placeholders, 0, placeholders.length);

        String rendered = Lang.format(key, (Object[]) placeholders);
        ctx.log(rendered);
        return rendered;
    }
}
