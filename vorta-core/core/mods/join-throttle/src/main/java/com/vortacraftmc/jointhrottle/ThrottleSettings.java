package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.ArrayList;
import java.util.List;

/**
 * Plain settings object (public fields so Gson can read/write it). All values
 * are clamped by {@link #sanitized()} before use, so a hand-edited or corrupt
 * config can never produce a limiter that blocks everyone or nobody.
 */
public final class ThrottleSettings {

    public static final int MAX_JOINS_LIMIT = 1000;
    public static final int MAX_WINDOW_SECONDS = 3600;

    /** Logins allowed per address within {@link #windowSeconds}. */
    public int maxJoins = 5;
    public int windowSeconds = 30;
    /** Addresses that are never throttled (raw IP strings, e.g. a trusted reverse proxy). */
    public List<String> exemptAddresses = new ArrayList<>();
    /** Shown to the rejected client. */
    public String denyMessage = "Too many connection attempts. Please wait a moment and try again.";

    public ThrottleSettings sanitized() {
        ThrottleSettings s = new ThrottleSettings();
        s.maxJoins = Math.max(1, Math.min(MAX_JOINS_LIMIT, maxJoins));
        s.windowSeconds = Math.max(1, Math.min(MAX_WINDOW_SECONDS, windowSeconds));
        s.exemptAddresses = new ArrayList<>();
        if (exemptAddresses != null) {
            for (String a : exemptAddresses) {
                if (a != null && !a.isBlank()) s.exemptAddresses.add(a.trim().toLowerCase());
            }
        }
        String msg = (denyMessage == null || denyMessage.isBlank()) ? new ThrottleSettings().denyMessage : denyMessage;
        s.denyMessage = msg.length() > 200 ? msg.substring(0, 200) : msg;
        return s;
    }
}
