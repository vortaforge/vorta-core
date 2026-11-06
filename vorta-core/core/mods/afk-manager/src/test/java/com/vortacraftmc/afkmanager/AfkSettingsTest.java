package com.vortacraftmc.afkmanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class AfkSettingsTest {

    @Test void defaultsAreValid() {
        AfkSettings s = new AfkSettings().sanitized();
        assertEquals(300, s.afkAfterSeconds);
        assertEquals(0, s.kickAfterSeconds);
        assertTrue(s.exemptOperatorsFromKick);
    }

    @Test void clampsAfkThreshold() {
        AfkSettings s = new AfkSettings();
        s.afkAfterSeconds = 1;
        assertEquals(AfkSettings.MIN_AFK_SECONDS, s.sanitized().afkAfterSeconds);
        s.afkAfterSeconds = 10_000_000;
        assertEquals(AfkSettings.MAX_AFK_SECONDS, s.sanitized().afkAfterSeconds);
    }

    @Test void kickIsOffOrAtLeastTheAfkThreshold() {
        AfkSettings s = new AfkSettings();
        s.afkAfterSeconds = 600;
        s.kickAfterSeconds = -5;
        assertEquals(0, s.sanitized().kickAfterSeconds);
        s.kickAfterSeconds = 60;                       // lower than afkAfter -> raised
        assertEquals(600, s.sanitized().kickAfterSeconds);
        s.kickAfterSeconds = 900;
        assertEquals(900, s.sanitized().kickAfterSeconds);
        s.kickAfterSeconds = Integer.MAX_VALUE;
        assertEquals(AfkSettings.MAX_KICK_SECONDS, s.sanitized().kickAfterSeconds);
    }

    @Test void sanitizedValuesAlwaysSatisfyIdleTrackerPreconditions() {
        int[] samples = {Integer.MIN_VALUE, -1, 0, 1, 10, 299, 300, 301, 86_400, 86_401, Integer.MAX_VALUE};
        for (int a : samples) for (int k : samples) {
            AfkSettings s = new AfkSettings();
            s.afkAfterSeconds = a;
            s.kickAfterSeconds = k;
            AfkSettings c = s.sanitized();
            new IdleTracker<String>(c.afkAfterSeconds * 1000L, c.kickAfterSeconds * 1000L); // must not throw
        }
    }

    @Test void blankOrHugeKickMessage() {
        AfkSettings s = new AfkSettings();
        s.kickMessage = null;
        assertEquals(new AfkSettings().kickMessage, s.sanitized().kickMessage);
        s.kickMessage = "y".repeat(999);
        assertEquals(200, s.sanitized().kickMessage.length());
    }
}
