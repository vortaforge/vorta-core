package net.vortaforge.macroengine.validate;

import java.util.ArrayList;
import java.util.List;

/**
 * Structural validation of {@code pack.mcmeta}.
 *
 * <h2>Why this exists at all</h2>
 *
 * Since 25w31a, packs declare {@code min_format} and {@code max_format} instead
 * of the single {@code pack_format} integer, and since 1.21.9 those bounds carry
 * a <em>minor</em> component: {@code [121, 0]} is "26.3, minor 0". The game
 * accepts a pack that declares only {@code pack_format} if it targets formats
 * below 82, and rejects or mis-loads one that gets this wrong above that. A pack
 * that quietly claims 121.0 when it was built for 121.0 but uses a 122 field
 * fails at world load with an unhelpful message, or worse, loads and does
 * nothing.
 *
 * So the rules here are about the difference between "the JSON parsed" and "this
 * metadata is true". A pack that says it supports 26.3 must actually be a 26.3
 * pack, and the bounds must be internally consistent.
 */
public final class PackMetaValidator {
    private PackMetaValidator() {
    }

    /** The data pack format this build targets. 26.3 release = 121.0. */
    public static final int MACROENGINE_MAX_FORMAT_MAJOR = 121;
    public static final int MACROENGINE_MAX_FORMAT_MINOR = 0;

    /** Formats below this use {@code pack_format}; at or above it, min/max. */
    public static final int MIN_FORMAT_FIELD_THRESHOLD = 82;

    public record Problem(String where, String message) {
        @Override
        public String toString() {
            return where + ": " + message;
        }
    }

    /**
     * Validate the parsed root object of a {@code pack.mcmeta}.
     *
     * @param root   the parsed JSON (a {@link com.google.gson.JsonObject} in
     *               practice, passed as Object to keep this class free of a
     *               compile-time Gson dependency for tests)
     * @param where  a human-readable location for messages
     */
    public static List<Problem> validate(Object root, String where) {
        List<Problem> problems = new ArrayList<>();
        if (!(root instanceof com.google.gson.JsonObject obj)) {
            problems.add(new Problem(where, "pack.mcmeta root is not a JSON object"));
            return problems;
        }
        if (!obj.has("pack") || !obj.get("pack").isJsonObject()) {
            problems.add(new Problem(where, "missing the mandatory \"pack\" object"));
            return problems;
        }
        com.google.gson.JsonObject pack = obj.getAsJsonObject("pack");

        if (!pack.has("description") || pack.get("description").isJsonNull()) {
            problems.add(new Problem(where, "missing \"description\"; the pack list shows a blank entry"));
        } else if (!(pack.get("description").isJsonPrimitive() || pack.get("description").isJsonArray())) {
            problems.add(new Problem(where, "\"description\" must be a string or a text component array"));
        }

        boolean hasMin = pack.has("min_format");
        boolean hasMax = pack.has("max_format");
        boolean hasSingle = pack.has("pack_format");

        if (!hasMin && !hasMax && !hasSingle) {
            problems.add(new Problem(where,
                    "no format declared: need \"min_format\" and \"max_format\" (or \"pack_format\" for formats below "
                            + MIN_FORMAT_FIELD_THRESHOLD + ")"));
            return problems;
        }

        // Declaring both schemes is ambiguous: the game and every third-party tool
        // disagree about which wins, so the pack's real support range is unknowable.
        if (hasSingle && (hasMin || hasMax)) {
            problems.add(new Problem(where,
                    "\"pack_format\" must not be combined with \"min_format\"/\"max_format\"; declare one scheme"));
        }

        int[] min = hasMin ? readVersion(pack.get("min_format"), where, "min_format", problems) : null;
        int[] max = hasMax ? readVersion(pack.get("max_format"), where, "max_format", problems) : null;

        if (hasMin != hasMax) {
            problems.add(new Problem(where,
                    "\"min_format\" and \"max_format\" must be declared together"));
        }

        if (min != null && max != null && compare(min, max) > 0) {
            problems.add(new Problem(where,
                    "\"min_format\" " + show(min) + " is greater than \"max_format\" " + show(max)
                            + "; the pack declares an empty version range"));
        }

        // A pack that claims a range extending past what it can possibly support is
        // a support claim, not a fact. For this pack we know the ceiling: it is
        // built against 121.0 and nothing above it has been tested.
        if (max != null && compare(max, new int[]{MACROENGINE_MAX_FORMAT_MAJOR, MACROENGINE_MAX_FORMAT_MINOR}) > 0) {
            problems.add(new Problem(where,
                    "\"max_format\" " + show(max) + " claims support beyond "
                            + show(new int[]{MACROENGINE_MAX_FORMAT_MAJOR, MACROENGINE_MAX_FORMAT_MINOR})
                            + " (26.3), which this pack has never been tested against"));
        }

        if (hasSingle) {
            int single = readSingle(pack.get("pack_format"), where, problems);
            if (single >= 0 && single >= MIN_FORMAT_FIELD_THRESHOLD) {
                problems.add(new Problem(where,
                        "\"pack_format\" " + single + " is not enough above " + MIN_FORMAT_FIELD_THRESHOLD
                                + "; use \"min_format\"/\"max_format\" so the minor version can be expressed"));
            }
        }

        return problems;
    }

    private static int readSingle(com.google.gson.JsonElement el, String where, List<Problem> problems) {
        if (el == null || !el.isJsonPrimitive() || !el.getAsJsonPrimitive().isNumber()) {
            problems.add(new Problem(where, "\"pack_format\" must be a number"));
            return -1;
        }
        return el.getAsInt();
    }

    /** Reads either the integer form or the {@code [major, minor]} form. */
    private static int[] readVersion(com.google.gson.JsonElement el, String where, String field,
                                     List<Problem> problems) {
        if (el == null) {
            return null;
        }
        if (el.isJsonPrimitive() && el.getAsJsonPrimitive().isNumber()) {
            return new int[]{el.getAsInt(), 0};
        }
        if (el.isJsonArray()) {
            com.google.gson.JsonArray arr = el.getAsJsonArray();
            if (arr.isEmpty() || arr.size() > 2) {
                problems.add(new Problem(where, "\"" + field + "\" array must be [major] or [major, minor]"));
                return null;
            }
            for (com.google.gson.JsonElement e : arr) {
                if (!e.isJsonPrimitive() || !e.getAsJsonPrimitive().isNumber()) {
                    problems.add(new Problem(where, "\"" + field + "\" entries must be numbers"));
                    return null;
                }
            }
            int major = arr.get(0).getAsInt();
            int minor = arr.size() > 1 ? arr.get(1).getAsInt() : 0;
            if (major < 0 || minor < 0) {
                problems.add(new Problem(where, "\"" + field + "\" must not be negative"));
                return null;
            }
            return new int[]{major, minor};
        }
        problems.add(new Problem(where, "\"" + field + "\" must be a number or an array of numbers"));
        return null;
    }

    private static int compare(int[] a, int[] b) {
        if (a[0] != b[0]) {
            return Integer.compare(a[0], b[0]);
        }
        return Integer.compare(a[1], b[1]);
    }

    private static String show(int[] v) {
        return v[0] + "." + v[1];
    }
}
