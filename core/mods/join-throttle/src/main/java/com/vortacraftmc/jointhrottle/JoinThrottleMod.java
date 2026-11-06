package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import net.fabricmc.api.ModInitializer;
import net.fabricmc.loader.api.FabricLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Join Throttle - Fabric mod for Minecraft 1.21.1 (dedicated server).
 *
 * <p>The actual check lives in {@code PlayerManagerMixin}, which hooks
 * {@code PlayerManager#checkCanJoin} - the same point vanilla uses for bans
 * and the whitelist - so a rejected client is disconnected during login and
 * never joins the world (no join/leave chat spam, no chunk loading).
 *
 * <p>What this is NOT: it runs after the Mojang session check, so it does not
 * stop handshake-level or network-level floods. Use a firewall / hosting
 * provider protection for those.
 */
public class JoinThrottleMod implements ModInitializer {

    public static final String MOD_ID = "join-throttle";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        ThrottleSettings settings = SettingsFile.loadOrCreate(
                FabricLoader.getInstance().getConfigDir().resolve("join-throttle.json"), LOGGER);
        JoinThrottle.configure(settings);
        LOGGER.info("Join Throttle active: max {} login(s) per address per {}s, {} exempt address(es).",
                settings.maxJoins, settings.windowSeconds, settings.exemptAddresses.size());
    }
}
