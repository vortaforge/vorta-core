package com.vortacraftmc.afkmanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class MotionSampleTest {

    private static final MotionSample BASE = new MotionSample(10, 64, 10, 90f, 0f);

    @Test void identicalSamplesDoNotDiffer() {
        assertFalse(BASE.differsFrom(new MotionSample(10, 64, 10, 90f, 0f)));
    }

    @Test void tinyJitterIsIgnored() {
        assertFalse(BASE.differsFrom(new MotionSample(10.01, 64, 10, 90.2f, 0.1f)));
    }

    @Test void realMovementOrTurningCounts() {
        assertTrue(BASE.differsFrom(new MotionSample(10.5, 64, 10, 90f, 0f)));
        assertTrue(BASE.differsFrom(new MotionSample(10, 66, 10, 90f, 0f)));
        assertTrue(BASE.differsFrom(new MotionSample(10, 64, 10, 95f, 0f)));
        assertTrue(BASE.differsFrom(new MotionSample(10, 64, 10, 90f, 15f)));
    }

    @Test void yawWrapAroundIsNotAFakeTurn() {
        MotionSample a = new MotionSample(0, 0, 0, 179.9f, 0f);
        MotionSample b = new MotionSample(0, 0, 0, -179.9f, 0f); // 0.2 degrees apart across the seam
        assertFalse(a.differsFrom(b));
        assertFalse(new MotionSample(0, 0, 0, 359.9f, 0f).differsFrom(new MotionSample(0, 0, 0, -0.1f, 0f)));
    }
}
