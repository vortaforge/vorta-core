package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import com.vortacraftmc.jointhrottle.AttemptLimiter.Result;
import org.junit.jupiter.api.Test;

class AttemptLimiterTest {

    @Test void allowsUpToMaxThenDenies() {
        AttemptLimiter l = new AttemptLimiter(3, 10_000, 100);
        assertEquals(Result.ALLOWED, l.check("a", 0));
        assertEquals(Result.ALLOWED, l.check("a", 1_000));
        assertEquals(Result.ALLOWED, l.check("a", 2_000));
        assertTrue(l.check("a", 3_000).isDenied());
    }

    @Test void firstDenialIsReportedOnceThenRepeat() {
        AttemptLimiter l = new AttemptLimiter(1, 10_000, 100);
        assertEquals(Result.ALLOWED, l.check("a", 0));
        assertEquals(Result.DENIED_FIRST, l.check("a", 100));
        assertEquals(Result.DENIED_REPEAT, l.check("a", 200));
        assertEquals(Result.DENIED_REPEAT, l.check("a", 300));
    }

    @Test void recoversAfterAQuietWindow() {
        AttemptLimiter l = new AttemptLimiter(2, 10_000, 100);
        l.check("a", 0);
        l.check("a", 1_000);
        assertTrue(l.check("a", 2_000).isDenied());
        // quiet for >= one full window after the last attempt -> let back in
        assertEquals(Result.ALLOWED, l.check("a", 12_000));
        // and a fresh block episode is reported again
        assertEquals(Result.ALLOWED, l.check("a", 12_100));
        assertEquals(Result.DENIED_FIRST, l.check("a", 12_200));
    }

    @Test void continuedHammeringStaysBlocked() {
        AttemptLimiter l = new AttemptLimiter(2, 10_000, 100);
        l.check("a", 0);
        l.check("a", 100);
        for (long t = 1_000; t <= 30_000; t += 1_000) {
            assertTrue(l.check("a", t).isDenied(), "still hammering at t=" + t);
        }
    }

    @Test void keysAreIndependent() {
        AttemptLimiter l = new AttemptLimiter(1, 10_000, 100);
        assertEquals(Result.ALLOWED, l.check("a", 0));
        assertEquals(Result.ALLOWED, l.check("b", 0));
        assertTrue(l.check("a", 1).isDenied());
        assertTrue(l.check("b", 1).isDenied());
    }

    @Test void memoryIsBounded() {
        AttemptLimiter l = new AttemptLimiter(1, 60_000, 3);
        for (int i = 0; i < 50; i++) {
            l.check("ip-" + i, i);
            assertTrue(l.trackedKeys() <= 3, "tracked " + l.trackedKeys() + " after " + (i + 1));
        }
    }

    @Test void theKeyBeingCheckedIsNeverEvictedMidCheck() {
        AttemptLimiter l = new AttemptLimiter(1, 60_000, 1);
        assertEquals(Result.ALLOWED, l.check("a", 0));
        assertEquals(Result.ALLOWED, l.check("b", 1)); // evicts a
        assertTrue(l.check("b", 2).isDenied());         // b must still be remembered
    }

    @Test void rejectsInvalidConstruction() {
        assertThrows(IllegalArgumentException.class, () -> new AttemptLimiter(0, 1, 1));
        assertThrows(IllegalArgumentException.class, () -> new AttemptLimiter(1, 0, 1));
        assertThrows(IllegalArgumentException.class, () -> new AttemptLimiter(1, 1, 0));
    }
}
