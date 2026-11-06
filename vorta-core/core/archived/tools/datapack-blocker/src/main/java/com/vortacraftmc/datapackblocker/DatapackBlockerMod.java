package com.vortacraftmc.datapackblocker;

import com.vortacraftmc.datapackblocker.command.BlockerCommand;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerLifecycleEvents;
import net.minecraft.util.WorldSavePath;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Datapack Blocker - Fabric mod for Minecraft 1.21.1.
 *
 * <p>Quarantining happens in {@link DatapackBlockerPreLaunch} (dedicated server, before the datapacks are read).
 * The {@code SERVER_STARTING} hook below runs after the server has already loaded its datapacks, so it must not move
 * anything: it captures the first-run baseline, re-locks allowlisted packs and loudly reports any violation that the
 * early pass could not handle (for example a brand-new world, or an integrated server).
 *
 * <p>See {@link AllowlistManager}'s class doc for exactly what this does and does not protect against.
 */
public class DatapackBlockerMod implements ModInitializer {

    public static final String MOD_ID = "datapack-blocker";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("Loading Datapack Blocker (Fabric 1.21.1)...");

        ServerLifecycleEvents.SERVER_STARTING.register(server -> {
            try {
                AllowlistManager manager = new AllowlistManager(
                        server.getSavePath(WorldSavePath.DATAPACKS),
                        server.getSavePath(WorldSavePath.ROOT),
                        LOGGER);
                manager.enforce(AllowlistManager.Phase.LATE);
            } catch (Exception exception) {
                // Never take the server down over this - log loudly and let it boot.
                LOGGER.error("Datapack Blocker: enforcement pass failed, datapacks folder was left as-is.", exception);
            }
        });

        CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) ->
                BlockerCommand.register(dispatcher, registryAccess));

        LOGGER.info("Datapack Blocker loaded.");
    }
}
