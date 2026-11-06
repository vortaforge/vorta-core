package com.vortacraftmc.afkmanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.HashMap;
import java.util.Map;

/**
 * Per-key idle state machine (pure Java, no Minecraft types, so it is
 * unit-testable). The caller supplies a monotonic "now" in milliseconds - the
 * mod uses server ticks * 50, so timers pause with the server instead of
 * jumping on wall-clock changes.
 *
 * <p>States: active -> AFK once idle for {@code afkAfterMs}; an AFK key is
 * reported once as {@link Verdict#SHOULD_KICK} when idle for
 * {@code kickAfterMs} (0 disables kicking). Any activity returns it to active.
 */
public final class IdleTracker<K> {

    public enum Verdict { NONE, BECAME_AFK, SHOULD_KICK }

    private static final class State {
        long lastActivity;
        boolean afk;
        State(long now) { this.lastActivity = now; }
    }

    private final long afkAfterMs;
    private final long kickAfterMs;
    private final Map<K, State> states = new HashMap<>();

    public IdleTracker(long afkAfterMs, long kickAfterMs) {
        if (afkAfterMs < 1) throw new IllegalArgumentException("afkAfterMs must be >= 1");
        if (kickAfterMs < 0) throw new IllegalArgumentException("kickAfterMs must be >= 0");
        if (kickAfterMs != 0 && kickAfterMs < afkAfterMs) {
            throw new IllegalArgumentException("kickAfterMs must be 0 (off) or >= afkAfterMs");
        }
        this.afkAfterMs = afkAfterMs;
        this.kickAfterMs = kickAfterMs;
    }

    /** Records activity. @return true if the key was AFK and has just returned. */
    public synchronized boolean activity(K key, long now) {
        State s = states.computeIfAbsent(key, k -> new State(now));
        boolean wasAfk = s.afk;
        s.afk = false;
        s.lastActivity = now;
        return wasAfk;
    }

    /** Periodic timer check for one key. A key seen for the first time starts its idle clock now. */
    public synchronized Verdict check(K key, long now) {
        State s = states.computeIfAbsent(key, k -> new State(now));
        long idle = now - s.lastActivity;
        if (!s.afk) {
            if (idle >= afkAfterMs) {
                s.afk = true;
                return Verdict.BECAME_AFK;
            }
            return Verdict.NONE;
        }
        return (kickAfterMs > 0 && idle >= kickAfterMs) ? Verdict.SHOULD_KICK : Verdict.NONE;
    }

    /**
     * Manual toggle (/afk). The idle clock restarts so a manually-AFK key is
     * not kicked instantly because of old idle time.
     *
     * @return true if the state actually changed
     */
    public synchronized boolean setAfk(K key, long now, boolean afk) {
        State s = states.computeIfAbsent(key, k -> new State(now));
        boolean changed = s.afk != afk;
        s.afk = afk;
        s.lastActivity = now;
        return changed;
    }

    public synchronized boolean isAfk(K key) {
        State s = states.get(key);
        return s != null && s.afk;
    }

    public synchronized void remove(K key) {
        states.remove(key);
    }

    public synchronized int size() {
        return states.size();
    }
}
