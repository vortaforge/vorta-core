package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.ArrayDeque;
import java.util.HashMap;
import java.util.Map;

/**
 * Sliding-window attempt limiter keyed by an arbitrary string (here: a
 * normalized client address). Pure Java - no Minecraft or Fabric types - so it
 * is unit-testable on its own.
 *
 * <p>Semantics: an attempt is <em>denied</em> when the key already has
 * {@code maxAttempts} attempts inside the last {@code windowMillis}. Denied
 * attempts are recorded too (the per-key history is capped at
 * {@code maxAttempts} entries), so a client that keeps hammering stays
 * blocked until it has been quiet for a full window, while a client that
 * stops is let back in automatically.
 *
 * <p>Memory is bounded: at most {@code maxKeys} keys are tracked. When the cap
 * is exceeded, expired keys are dropped first, then the least recently seen
 * key. Consequence (accepted trade-off): an attacker rotating through more
 * than {@code maxKeys} addresses can push a real offender out of the table.
 * Bounded memory was judged more important than perfect recall.
 *
 * <p>All methods are thread-safe; login checks arrive on network threads.
 */
public final class AttemptLimiter {

    public enum Result {
        ALLOWED,
        /** First denial of a block episode - the caller should log this one. */
        DENIED_FIRST,
        /** Further denials in the same episode - the caller should stay quiet (log-flood protection). */
        DENIED_REPEAT;

        public boolean isDenied() {
            return this != ALLOWED;
        }
    }

    private static final class Entry {
        final ArrayDeque<Long> times = new ArrayDeque<>();
        boolean denialReported;
        long lastSeen;
    }

    private final int maxAttempts;
    private final long windowMillis;
    private final int maxKeys;
    private final Map<String, Entry> entries = new HashMap<>();

    public AttemptLimiter(int maxAttempts, long windowMillis, int maxKeys) {
        if (maxAttempts < 1) throw new IllegalArgumentException("maxAttempts must be >= 1");
        if (windowMillis < 1) throw new IllegalArgumentException("windowMillis must be >= 1");
        if (maxKeys < 1) throw new IllegalArgumentException("maxKeys must be >= 1");
        this.maxAttempts = maxAttempts;
        this.windowMillis = windowMillis;
        this.maxKeys = maxKeys;
    }

    /** Records an attempt for {@code key} at {@code nowMillis} (monotonic clock) and says whether it is allowed. */
    public synchronized Result check(String key, long nowMillis) {
        Entry entry = entries.computeIfAbsent(key, k -> new Entry());

        while (!entry.times.isEmpty() && nowMillis - entry.times.peekFirst() >= windowMillis) {
            entry.times.pollFirst();
        }
        boolean denied = entry.times.size() >= maxAttempts;

        entry.times.addLast(nowMillis);
        while (entry.times.size() > maxAttempts) {
            entry.times.pollFirst();
        }
        entry.lastSeen = nowMillis;

        Result result;
        if (!denied) {
            entry.denialReported = false;
            result = Result.ALLOWED;
        } else if (!entry.denialReported) {
            entry.denialReported = true;
            result = Result.DENIED_FIRST;
        } else {
            result = Result.DENIED_REPEAT;
        }

        if (entries.size() > maxKeys) {
            evict(nowMillis, key);
        }
        return result;
    }

    /** Number of keys currently tracked (for tests / diagnostics). */
    public synchronized int trackedKeys() {
        return entries.size();
    }

    private void evict(long nowMillis, String keep) {
        entries.entrySet().removeIf(e ->
                !e.getKey().equals(keep) && nowMillis - e.getValue().lastSeen >= windowMillis);
        while (entries.size() > maxKeys) {
            String oldestKey = null;
            long oldestSeen = Long.MAX_VALUE;
            for (Map.Entry<String, Entry> e : entries.entrySet()) {
                if (e.getKey().equals(keep)) continue;
                if (e.getValue().lastSeen < oldestSeen) {
                    oldestSeen = e.getValue().lastSeen;
                    oldestKey = e.getKey();
                }
            }
            if (oldestKey == null) break;
            entries.remove(oldestKey);
        }
    }
}
