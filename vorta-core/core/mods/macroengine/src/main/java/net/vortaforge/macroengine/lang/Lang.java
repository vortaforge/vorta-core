package net.vortaforge.macroengine.lang;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import net.minecraft.server.packs.resources.Resource;
import net.minecraft.server.packs.resources.ResourceManager;
import net.minecraft.resources.Identifier;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Translations for the messages macroEngine itself emits.
 *
 * <h2>Why not use the vanilla {@code Component.translatable} path</h2>
 *
 * Vanilla resolves a translation key on the <em>client</em> that receives it, and
 * falls back to printing the raw key when the client has no entry. For a message
 * this mod puts in a server log, there is no client to resolve it, and the raw key
 * is not a useful log line. So the mod ships its own small table, loaded from
 * {@code assets/macroengine/lang/*.json} in the pack, and resolves against the
 * server's configured language with English as the guaranteed fallback.
 *
 * <p>Missing keys are reported as missing. A silently-rendered raw key that looks
 * like {@code macroengine.log.foo} in a log is worse than an honest error: it
 * reads like a bug in the game rather than a gap in the pack.
 */
public final class Lang {
    /** Always present. Every other language falls back to this. */
    private static final Map<String, String> EN = new HashMap<>();
    private static final Map<String, Map<String, String>> BY_LANGUAGE = new HashMap<>();
    private static String activeLanguage = "en_us";

    private Lang() {
    }

    /**
     * Replace the table from the packs currently loaded.
     *
     * <p>English is loaded first and unconditionally; a failure to read any other
     * language is logged and skipped rather than allowed to take the table down,
     * because a broken translation file must not remove the mod's ability to speak.
     */
    public static synchronized void reload(ResourceManager manager, java.util.function.BiConsumer<String, String> warnings) {
        EN.clear();
        BY_LANGUAGE.clear();

        loadInto(manager, "en_us", EN, warnings);
        if (EN.isEmpty()) {
            warnings.accept("lang", "assets/macroengine/lang/en_us.json is missing or empty; "
                    + "every macroEngine message will report a missing key");
        }
        for (String language : manager.getNamespaces()) {
            // getNamespaces lists pack namespaces, not languages; the language list
            // is discovered from the files themselves below.
            break;
        }
        Map<Identifier, Resource> langFiles = manager.listResources("lang", id -> id.getPath().endsWith(".json"));
        for (Map.Entry<Identifier, Resource> entry : langFiles.entrySet()) {
            String path = entry.getKey().getPath();
            String language = path.substring(path.lastIndexOf('/') + 1, path.length() - ".json".length());
            if (language.equals("en_us")) {
                continue; // already loaded as the fallback
            }
            Map<String, String> table = new HashMap<>();
            loadInto(manager, language, table, warnings);
            if (!table.isEmpty()) {
                BY_LANGUAGE.put(language.toLowerCase(Locale.ROOT), table);
            }
        }
    }

    private static void loadInto(ResourceManager manager, String language, Map<String, String> target,
                                 java.util.function.BiConsumer<String, String> warnings) {
        Identifier id = Identifier.fromNamespaceAndPath("macroengine", "lang/" + language + ".json");
        java.util.Optional<Resource> resource = manager.getResource(id);
        if (resource.isEmpty()) {
            return;
        }
        try (InputStream in = resource.get().open();
             Reader reader = new InputStreamReader(in, StandardCharsets.UTF_8)) {
            JsonElement root = JsonParser.parseReader(reader);
            if (!root.isJsonObject()) {
                warnings.accept(language, "lang/" + language + ".json is not a JSON object; ignored");
                return;
            }
            JsonObject obj = root.getAsJsonObject();
            for (Map.Entry<String, JsonElement> e : obj.entrySet()) {
                if (e.getValue().isJsonPrimitive()) {
                    target.put(e.getKey(), e.getValue().getAsString());
                } else {
                    warnings.accept(language, "key '" + e.getKey() + "' is not a string; ignored");
                }
            }
        } catch (IOException | RuntimeException e) {
            warnings.accept(language, "lang/" + language + ".json is unreadable (" + e.getMessage() + "); ignored");
        }
    }

    /** Set the language used for server-side resolution, e.g. "tr_tr". */
    public static synchronized void setLanguage(String language) {
        activeLanguage = language == null ? "en_us" : language.toLowerCase(Locale.ROOT);
    }

    public static synchronized String activeLanguage() {
        return activeLanguage;
    }

    public static synchronized boolean has(String key) {
        Map<String, String> table = BY_LANGUAGE.get(activeLanguage);
        return (table != null && table.containsKey(key)) || EN.containsKey(key);
    }

    /**
     * Resolve a key with positional placeholders {@code %1$s}, {@code %2$s}.
     *
     * <p>A key present in the active language but missing from English is still
     * used: the active language is the more specific answer. A key in neither
     * returns a visible marker rather than the bare key, so a missing translation
     * cannot be mistaken for a message that intentionally reads that way.
     */
    public static synchronized String format(String key, Object... args) {
        Map<String, String> table = BY_LANGUAGE.get(activeLanguage);
        String pattern = table == null ? null : table.get(key);
        if (pattern == null) {
            pattern = EN.get(key);
        }
        if (pattern == null) {
            return "«missing translation: " + key + "»";
        }
        try {
            return String.format(pattern, args);
        } catch (RuntimeException e) {
            // A translation with a malformed placeholder must not take the caller
            // down; the message is the point, not the formatting.
            return pattern;
        }
    }

    /** How many keys are loaded, for {@code /function macroengine:module/vf_log} diagnostics. */
    public static synchronized int size() {
        return EN.size();
    }
}
