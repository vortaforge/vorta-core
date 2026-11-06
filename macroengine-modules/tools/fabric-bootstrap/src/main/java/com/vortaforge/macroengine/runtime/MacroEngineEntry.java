package com.vortaforge.macroengine.runtime;

import net.fabricmc.api.ModInitializer;

/**
 * The entry point every macroEngine mod declares.
 *
 * <p>It does nothing, and that is the correct amount for it to do. macroEngine is
 * a data pack: the behaviour lives in {@code data/} inside the mod jar, and what
 * makes the game read that tree is Fabric's resource loader, which scans every mod
 * jar for a {@code data/} directory. Nothing needs to be registered, no callback
 * needs to be scheduled, and the server and the client want the same no-op.
 *
 * <p>It exists because Fabric requires it to. A mod whose
 * {@code fabric.mod.json} declares a {@code main} entry point has that class
 * constructed and cast to {@link ModInitializer}; a class that does not implement
 * this interface fails the launch with
 * {@code LanguageAdapterException: Class ... cannot be cast to
 * net.fabricmc.api.ModInitializer} - and that stops the entire server, not just
 * the offending mod. That is exactly what happened before this class existed.
 *
 * <p>One class serves all twenty-six mods. Each declares this same name, and each
 * carries this jar nested in {@code META-INF/jars/}; Fabric loads the first copy
 * it resolves and every mod's cast then succeeds against the same {@code Class}
 * object. A class per mod would be twenty-six copies of this file for a
 * classloader to disambiguate, for no gain.
 */
public final class MacroEngineEntry implements ModInitializer {

    @Override
    public void onInitialize() {
        // Nothing to do. The data pack is the mod.
    }
}
