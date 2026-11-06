package net.vortaforge.macroengine.validate;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Text scanners for the two things a datapack can carry that are not syntax
 * errors but are still dangerous: instructions aimed at a reader (prompt
 * injection), and links that lead somewhere unexpected.
 *
 * <h2>What this class does not do</h2>
 *
 * It does not decide guilt. It produces findings for a human to read. Nothing
 * here blocks a player, kicks anyone, or writes to the blocklist: the audit that
 * preceded this mod was explicit that a keyword match must never turn into an
 * automatic account block, because "claude" is a substring of "claudette" and a
 * real person pays for that mistake.
 *
 * <h2>Why a false positive is cheaper than a false negative here</h2>
 *
 * The opposite is true for a blocklist. Here, a warning that turns out to be
 * harmless costs a maintainer ten seconds of reading. A missed injection attempt
 * in a pack that ships to players is a different order of problem. The patterns
 * are therefore written to over-report slightly and are always reported with the
 * exact matched text so the reader can judge it themselves.
 */
public final class SuspiciousText {
    private SuspiciousText() {
    }

    /** Severity is about how a reader should react, not how bad the author is. */
    public enum Severity {
        /** Worth a look; commonly benign. */
        INFO,
        /** A real indicator of an injection attempt or a bad redirect. */
        WARN,
        /** Should not appear in a pack at all: hands data to an external tool. */
        HIGH
    }

    /** One match, with enough context that a human can judge it unaided. */
    public record Finding(Severity severity, String kind, String where, String snippet, String why) {
        @Override
        public String toString() {
            return "[" + severity + "] " + kind + " in " + where + ": " + snippet + " (" + why + ")";
        }
    }

    /**
     * Phrases that only make sense when addressed to a language model or an
     * automated reviewer. Written as regexes so spacing and casing do not matter.
     *
     * Deliberately included: the indirect forms ("ignore the above", "you are
     * now", "system prompt") that a naive keyword list misses, because those are
     * the ones that actually work on modern models.
     */
    private static final List<Pattern> INJECTION = List.of(
            // Direct instructions to disregard prior context.
            Pattern.compile("\\bignore\\s+(?:all\\s+|any\\s+)?(?:the\\s+|your\\s+)?(?:previous|prior|above|preceding|earlier)\\b",
                    Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\bdisregard\\s+(?:all\\s+|any\\s+)?(?:the\\s+|your\\s+)?(?:previous|prior|above|preceding|earlier|instructions?|rules?)\\b",
                    Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\bforget\\s+(?:everything|all|your|the)\\b.{0,20}\\b(?:instructions?|rules?|above|prompt)\\b",
                    Pattern.CASE_INSENSITIVE),
            // Role reassignment. Narrow on purpose: "you are now level 5" is
            // ordinary game text and this pattern used to fire on it. What matters
            // is reassignment to an identity that is not a game concept.
            Pattern.compile("\\byou\\s+are\\s+(?:now|no\\s+longer)\\s+(?:an?\\s+|the\\s+)?"
                    + "(?:unrestricted|unfiltered|jailbroken|uncensored|liberated|dan\\b|"
                    + "admin(?:istrator)?\\b|root\\b|assistant\\b|ai\\b|language\\s+model\\b|"
                    + "free\\s+from|bound\\s+by|subject\\s+to\\s+no)",
                    Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(?:act|behave)\\s+as\\s+(?:if\\s+you\\s+(?:are|were)\\s+)?(?:a\\s+|an\\s+)?(?:admin|administrator|root|system|developer|ai|assistant)\\b",
                    Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\bnew\\s+(?:system\\s+)?(?:instructions?|rules?|prompt)\\b", Pattern.CASE_INSENSITIVE),
            // Talking about the model's own machinery.
            Pattern.compile("\\bsystem\\s*prompt\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(?:reveal|print|show|repeat|output)\\s+(?:me\\s+)?(?:your|the)\\s+(?:system\\s+)?(?:prompt|instructions?|rules?)\\b",
                    Pattern.CASE_INSENSITIVE),
            // Coercion of the reviewing tool.
            Pattern.compile("\\b(?:ai|llm|language\\s+model|assistant|agent|chatgpt|claude|copilot|gemini)\\s+(?:must|should|shall|will|needs?\\s+to)\\b",
                    Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\bif\\s+you\\s+are\\s+(?:an?\\s+)?(?:ai|llm|language\\s+model|bot|assistant|agent)\\b",
                    Pattern.CASE_INSENSITIVE),
            // Attempts to smuggle instructions past a scanner.
            Pattern.compile("\\b(?:base64|rot13|hex)\\s*(?:-|:)?\\s*(?:decode|encoded|encode)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("</?(?:system|instruction|prompt|assistant|user)>", Pattern.CASE_INSENSITIVE),
            // The classic delimiter trick used to break out of a quoted context.
            Pattern.compile("(?:^|\\s)(?:###|===|---)\\s*(?:system|instruction|prompt)\\b", Pattern.CASE_INSENSITIVE)
    );

    /**
     * Links. The point is not "any URL is bad": a pack may legitimately point at
     * its own documentation. The point is to surface the ones that either lead
     * off-site, hide where they go, or ask the reader to run something.
     */
    private static final List<Pattern> LINKS = List.of(
            Pattern.compile("https?://[^\\s\"'<>)\\]]+", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\bwww\\.[a-z0-9-]+(?:\\.[a-z0-9-]+)+", Pattern.CASE_INSENSITIVE)
    );

    /** Hosts that are fine in a pack, and why. Everything else is off-site. */
    private static final Set<String> KNOWN_HOSTS = Set.of(
            "vortaforge.github.io",
            "github.com",
            "raw.githubusercontent.com",
            "minecraft.wiki",
            "minecraft.net"
    );

    /** Link shapes that hide their destination or invite the reader to run code. */
    private static final List<Pattern> BAD_LINK_SHAPE = List.of(
            Pattern.compile("https?://\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}", Pattern.CASE_INSENSITIVE),
            Pattern.compile("https?://[^\\s/]*(?:bit\\.ly|tinyurl|t\\.co|goo\\.gl|is\\.gd|shorturl|rebrand\\.ly)",
                    Pattern.CASE_INSENSITIVE),
            Pattern.compile("https?://[^\\s/]*(?:pastebin|hastebin|ghostbin|termbin|transfer\\.sh)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("https?://[^\\s/]*xn--", Pattern.CASE_INSENSITIVE) // punycode homograph
    );

    /** Words that turn a link into an instruction to execute something. */
    private static final Pattern EXECUTION_BAIT = Pattern.compile(
            "\\b(?:run|execute|paste|install|download\\s+and\\s+run|chmod\\s*\\+x|curl\\b.*\\|\\s*(?:sh|bash)|powershell\\s+-|"
                    + "\\.exe\\b|\\.bat\\b|\\.jar\\b|\\.msi\\b|npm\\s+install|pip\\s+install)\\b",
            Pattern.CASE_INSENSITIVE);

    /**
     * Scan one piece of text.
     *
     * @param text  the raw text (a JSON file's contents, a function file, a lang value)
     * @param where a human-readable location, e.g. "data/macroengine/function/x.mcfunction"
     */
    public static List<Finding> scan(String text, String where) {
        List<Finding> out = new ArrayList<>();
        if (text == null || text.isEmpty()) {
            return out;
        }

        for (Pattern pattern : INJECTION) {
            Matcher m = pattern.matcher(text);
            while (m.find()) {
                out.add(new Finding(Severity.HIGH, "prompt-injection", where,
                        clip(text, m.start(), m.end()),
                        "reads as an instruction to an automated reader, not as game data"));
            }
        }

        Set<String> seenLinks = new LinkedHashSet<>();
        for (Pattern pattern : LINKS) {
            Matcher m = pattern.matcher(text);
            while (m.find()) {
                String url = m.group();
                if (!seenLinks.add(url)) {
                    continue;
                }
                out.addAll(classifyLink(url, text, where));
            }
        }

        return out;
    }

    private static List<Finding> classifyLink(String url, String text, String where) {
        List<Finding> out = new ArrayList<>();
        String lower = url.toLowerCase(Locale.ROOT);

        for (Pattern bad : BAD_LINK_SHAPE) {
            if (bad.matcher(lower).find()) {
                out.add(new Finding(Severity.HIGH, "suspicious-link", where, url,
                        "hides its destination, is a raw IP, or is a known file-drop host"));
                return out;
            }
        }

        String host = hostOf(lower);
        if (host != null && !isKnownHost(host)) {
            out.add(new Finding(Severity.WARN, "off-site-link", where, url,
                    "points outside the project's own documentation hosts"));
        }

        // A URL near execution language is the pattern that actually gets people:
        // "download the fix here and run it".
        int idx = text.indexOf(url);
        if (idx >= 0) {
            int from = Math.max(0, idx - 120);
            int to = Math.min(text.length(), idx + url.length() + 120);
            String window = text.substring(from, to);
            if (EXECUTION_BAIT.matcher(window).find()) {
                out.add(new Finding(Severity.HIGH, "link-with-execution", where, url,
                        "appears next to instructions to download or run something"));
            }
        }
        return out;
    }

    private static boolean isKnownHost(String host) {
        for (String known : KNOWN_HOSTS) {
            // Suffix match so e.g. docs.vortaforge.github.io still counts, but
            // evil-vortaforge.github.io.evil.com does not (it ends in evil.com).
            if (host.equals(known) || host.endsWith("." + known)) {
                return true;
            }
        }
        return false;
    }

    static String hostOf(String url) {
        int scheme = url.indexOf("://");
        int start = scheme >= 0 ? scheme + 3 : 0;
        int end = url.length();
        for (int i = start; i < url.length(); i++) {
            char c = url.charAt(i);
            if (c == '/' || c == '?' || c == '#') {
                end = i;
                break;
            }
        }
        String hostPort = url.substring(start, end);
        int at = hostPort.lastIndexOf('@');
        if (at >= 0) {
            hostPort = hostPort.substring(at + 1); // userinfo@host: keep the host
        }
        int colon = hostPort.indexOf(':');
        if (colon >= 0) {
            hostPort = hostPort.substring(0, colon);
        }
        return hostPort.isEmpty() ? null : hostPort;
    }

    /** Keep a snippet short enough for a log line and a tooltip. */
    private static String clip(String text, int start, int end) {
        int from = Math.max(0, start - 24);
        int to = Math.min(text.length(), end + 24);
        String snippet = text.substring(from, to).replaceAll("\\s+", " ").trim();
        if (from > 0) {
            snippet = "…" + snippet;
        }
        if (to < text.length()) {
            snippet = snippet + "…";
        }
        return snippet.length() > 160 ? snippet.substring(0, 157) + "…" : snippet;
    }
}
