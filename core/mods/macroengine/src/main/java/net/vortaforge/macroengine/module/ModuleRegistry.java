package net.vortaforge.macroengine.module;

import net.vortaforge.macroengine.MacroEngine;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

/**
 * The module registry, and the only place a module name becomes a module.
 *
 * <p>Lookups are exact and case-sensitive on the id. This is deliberate: an
 * identifier that quietly falls back to a "close enough" module is how a typo
 * turns into an unexpected action. An unknown id is an error the caller sees.
 */
public final class ModuleRegistry {
    private static final Map<String, MacroModule> MODULES = new LinkedHashMap<>();

    private ModuleRegistry() {
    }

    public static synchronized void register(MacroModule module) {
        String id = module.id().toLowerCase(Locale.ROOT);
        MacroModule previous = MODULES.putIfAbsent(id, module);
        if (previous != null) {
            // Two modules claiming one id is a programming error, and silently
            // keeping the first would make the second unreachable with no signal.
            MacroEngine.LOG.error("macroEngine: duplicate module id '{}' ignored (already provided by {})",
                    id, previous.getClass().getSimpleName());
            return;
        }
        MacroEngine.LOG.debug("macroEngine: registered module '{}' - {}", id, module.description());
    }

    public static Optional<MacroModule> find(String id) {
        if (id == null) {
            return Optional.empty();
        }
        return Optional.ofNullable(MODULES.get(id.toLowerCase(Locale.ROOT)));
    }

    public static List<MacroModule> all() {
        return new ArrayList<>(MODULES.values());
    }

    public static int size() {
        return MODULES.size();
    }
}
