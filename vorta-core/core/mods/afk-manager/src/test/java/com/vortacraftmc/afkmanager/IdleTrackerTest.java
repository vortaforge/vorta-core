package com.vortacraftmc.afkmanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import com.vortacraftmc.afkmanager.IdleTracker.Verdict;
import org.junit.jupiter.api.Test;

class IdleTrackerTest {

    @Test void becomesAfkOnlyAfterTheThreshold() {
        IdleTracker<String> t = new IdleTracker<>(10_000, 0);
        assertEquals(Verdict.NONE, t.check("p", 0));
        assertEquals(Verdict.NONE, t.check("p", 9_999));
        assertEquals(Verdict.BECAME_AFK, t.check("p", 10_000));
        assertTrue(t.isAfk("p"));
    }

    @Test void becameAfkIsReportedOnlyOnce() {
        IdleTracker<String> t = new IdleTracker<>(1_000, 0);
        t.check("p", 0);
        assertEquals(Verdict.BECAME_AFK, t.check("p", 1_000));
        assertEquals(Verdict.NONE, t.check("p", 2_000));
        assertEquals(Verdict.NONE, t.check("p", 99_000)); // kick disabled -> never SHOULD_KICK
    }

    @Test void activityResetsTheClockAndReportsReturn() {
        IdleTracker<String> t = new IdleTracker<>(1_000, 0);
        t.check("p", 0);
        assertEquals(Verdict.BECAME_AFK, t.check("p", 1_000));
        assertTrue(t.activity("p", 1_500));   // was AFK -> returned
        assertFalse(t.isAfk("p"));
        assertFalse(t.activity("p", 1_600));  // already active
        assertEquals(Verdict.NONE, t.check("p", 2_500));
        assertEquals(Verdict.BECAME_AFK, t.check("p", 2_600));
    }

    @Test void kickIsOnlyProposedForAfkKeysAfterTheKickThreshold() {
        IdleTracker<String> t = new IdleTracker<>(1_000, 5_000);
        t.check("p", 0);
        assertEquals(Verdict.BECAME_AFK, t.check("p", 1_000));
        assertEquals(Verdict.NONE, t.check("p", 4_999));
        assertEquals(Verdict.SHOULD_KICK, t.check("p", 5_000));
    }

    @Test void aHugeTimeJumpGoesThroughAfkBeforeKick() {
        IdleTracker<String> t = new IdleTracker<>(1_000, 5_000);
        t.check("p", 0);
        assertEquals(Verdict.BECAME_AFK, t.check("p", 1_000_000));
        assertEquals(Verdict.SHOULD_KICK, t.check("p", 1_000_001));
    }

    @Test void manualAfkRestartsTheIdleClockSoItIsNotKickedInstantly() {
        IdleTracker<String> t = new IdleTracker<>(1_000, 5_000);
        t.check("p", 0);
        assertTrue(t.setAfk("p", 100_000, true));
        assertTrue(t.isAfk("p"));
        assertEquals(Verdict.NONE, t.check("p", 100_001));
        assertEquals(Verdict.SHOULD_KICK, t.check("p", 105_000));
        assertFalse(t.setAfk("p", 105_001, true)); // no change
        assertTrue(t.setAfk("p", 105_002, false));
        assertFalse(t.isAfk("p"));
    }

    @Test void keysAreIndependentAndRemovable() {
        IdleTracker<String> t = new IdleTracker<>(1_000, 0);
        t.check("a", 0);
        t.check("b", 0);
        assertEquals(Verdict.BECAME_AFK, t.check("a", 1_000));
        t.activity("b", 900);
        assertEquals(Verdict.NONE, t.check("b", 1_000));
        t.remove("a");
        assertEquals(1, t.size());
        assertFalse(t.isAfk("a"));
    }

    @Test void rejectsInvalidThresholds() {
        assertThrows(IllegalArgumentException.class, () -> new IdleTracker<String>(0, 0));
        assertThrows(IllegalArgumentException.class, () -> new IdleTracker<String>(1_000, -1));
        assertThrows(IllegalArgumentException.class, () -> new IdleTracker<String>(5_000, 1_000));
    }
}
