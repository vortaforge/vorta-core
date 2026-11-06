package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.net.SocketAddress;
import java.util.HashSet;
import java.util.Set;

/**
 * Static facade used by the mixin. Holds the active limiter/settings; until
 * {@link #configure} runs (before the first player can connect) every check
 * allows the connection.
 */
public final class JoinThrottle {

    /** Upper bound on tracked addresses (memory cap, see {@link AttemptLimiter}). */
    private static final int MAX_TRACKED_ADDRESSES = 4096;

    private static volatile AttemptLimiter limiter;
    private static volatile ThrottleSettings settings;
    /** {@link ThrottleSettings#exemptAddresses} normalized via {@link AddressKeys#canonicalLiteral} (IPv6 spelling-proof). */
    private static volatile Set<String> exemptCanonical = Set.of();

    private JoinThrottle() {}

    static void configure(ThrottleSettings newSettings) {
        ThrottleSettings s = newSettings.sanitized();
        Set<String> canonical = new HashSet<>();
        for (String address : s.exemptAddresses) canonical.add(AddressKeys.canonicalLiteral(address));
        exemptCanonical = Set.copyOf(canonical);
        settings = s;
        limiter = new AttemptLimiter(s.maxJoins, s.windowSeconds * 1000L, MAX_TRACKED_ADDRESSES);
    }

    /**
     * Called from the login path for every connection that is about to join.
     *
     * @return the disconnect message if this connection must be rejected, otherwise {@code null}
     */
    public static String check(SocketAddress address) {
        AttemptLimiter active = limiter;
        ThrottleSettings cfg = settings;
        if (active == null || cfg == null) return null;

        String key = AddressKeys.keyFor(address);
        if (key == null) return null; // no usable IP (e.g. local/embedded connection) -> not throttled

        // First form: the limiter key itself (e.g. "v6/2001:db8:0:1::/64"). Second: the literal address in any spelling
        // ("::1" vs "0:0:0:0:0:0:0:1" - the raw string compare used before never matched compressed IPv6 entries).
        if (cfg.exemptAddresses.contains(key.toLowerCase(java.util.Locale.ROOT)) || exemptCanonical.contains(rawHost(address))) {
            return null;
        }

        AttemptLimiter.Result result = active.check(key, System.nanoTime() / 1_000_000L);
        if (!result.isDenied()) return null;
        if (result == AttemptLimiter.Result.DENIED_FIRST) {
            JoinThrottleMod.LOGGER.warn("Throttling {}: more than {} login(s) within {}s (further denials for this address are not logged until it calms down).",
                    key, cfg.maxJoins, cfg.windowSeconds);
        }
        return cfg.denyMessage;
    }

    private static String rawHost(SocketAddress address) {
        return address instanceof java.net.InetSocketAddress i && i.getAddress() != null
                ? AddressKeys.canonicalLiteral(i.getAddress().getHostAddress())
                : "";
    }
}
