package com.vortacraftmc.afkmanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/** Plain settings object (public fields for Gson); {@link #sanitized()} clamps everything before use. */
public final class AfkSettings {

    public static final int MIN_AFK_SECONDS = 10;
    public static final int MAX_AFK_SECONDS = 86_400;
    public static final int MAX_KICK_SECONDS = 604_800;

    public int afkAfterSeconds = 300;
    /** 0 = never kick. Otherwise must be >= afkAfterSeconds (raised to it if lower). */
    public int kickAfterSeconds = 0;
    public boolean announce = true;
    public boolean exemptOperatorsFromKick = true;
    public String kickMessage = "Kicked for being AFK.";

    public AfkSettings sanitized() {
        AfkSettings s = new AfkSettings();
        s.afkAfterSeconds = Math.max(MIN_AFK_SECONDS, Math.min(MAX_AFK_SECONDS, afkAfterSeconds));
        if (kickAfterSeconds <= 0) {
            s.kickAfterSeconds = 0;
        } else {
            s.kickAfterSeconds = Math.min(MAX_KICK_SECONDS, Math.max(s.afkAfterSeconds, kickAfterSeconds));
        }
        s.announce = announce;
        s.exemptOperatorsFromKick = exemptOperatorsFromKick;
        String msg = (kickMessage == null || kickMessage.isBlank()) ? new AfkSettings().kickMessage : kickMessage;
        s.kickMessage = msg.length() > 200 ? msg.substring(0, 200) : msg;
        return s;
    }
}
