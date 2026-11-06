package com.vortacraftmc.afkmanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/**
 * Position + view direction at one instant. Two samples "differ" when the
 * player moved or turned by more than a small threshold.
 *
 * <p>Known limitation: being pushed (water, pistons, other entities) also
 * counts as movement, so such a player is not marked AFK.
 */
public record MotionSample(double x, double y, double z, float yaw, float pitch) {

    /** 0.05 blocks, squared. */
    static final double POSITION_EPSILON_SQ = 0.0025;
    /** Degrees. */
    static final float ANGLE_EPSILON = 0.5f;

    public boolean differsFrom(MotionSample other) {
        double dx = x - other.x, dy = y - other.y, dz = z - other.z;
        if (dx * dx + dy * dy + dz * dz > POSITION_EPSILON_SQ) return true;
        return angleDelta(yaw, other.yaw) > ANGLE_EPSILON || angleDelta(pitch, other.pitch) > ANGLE_EPSILON;
    }

    /** Smallest absolute difference between two angles in degrees, wrap-around safe (yaw can exceed +-180). */
    static float angleDelta(float a, float b) {
        float d = Math.abs(a - b) % 360f;
        return d > 180f ? 360f - d : d;
    }
}
