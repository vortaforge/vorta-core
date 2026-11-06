package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import java.util.Arrays;
import org.junit.jupiter.api.Test;

class ThrottleSettingsTest {

    @Test void defaultsAreAlreadyValid() {
        ThrottleSettings s = new ThrottleSettings().sanitized();
        assertEquals(5, s.maxJoins);
        assertEquals(30, s.windowSeconds);
    }

    @Test void clampsOutOfRangeNumbers() {
        ThrottleSettings s = new ThrottleSettings();
        s.maxJoins = -4;
        s.windowSeconds = 999_999;
        ThrottleSettings c = s.sanitized();
        assertEquals(1, c.maxJoins);
        assertEquals(ThrottleSettings.MAX_WINDOW_SECONDS, c.windowSeconds);
        s.maxJoins = 5_000_000;
        s.windowSeconds = 0;
        c = s.sanitized();
        assertEquals(ThrottleSettings.MAX_JOINS_LIMIT, c.maxJoins);
        assertEquals(1, c.windowSeconds);
    }

    @Test void normalizesExemptAddressesAndDropsJunk() {
        ThrottleSettings s = new ThrottleSettings();
        s.exemptAddresses = Arrays.asList("  10.0.0.1 ", null, "", "   ", "FE80::1");
        assertEquals(Arrays.asList("10.0.0.1", "fe80::1"), s.sanitized().exemptAddresses);
        s.exemptAddresses = null;
        assertTrue(s.sanitized().exemptAddresses.isEmpty());
    }

    @Test void blankOrHugeMessageIsReplacedOrTrimmed() {
        ThrottleSettings s = new ThrottleSettings();
        s.denyMessage = "   ";
        assertEquals(new ThrottleSettings().denyMessage, s.sanitized().denyMessage);
        s.denyMessage = "x".repeat(500);
        assertEquals(200, s.sanitized().denyMessage.length());
    }
}
