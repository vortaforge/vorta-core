package com.vortacraftmc.datapackblocker;

import net.fabricmc.api.EnvType;
import net.fabricmc.loader.api.FabricLoader;
import net.fabricmc.loader.api.entrypoint.PreLaunchEntrypoint;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

/**
 * Early enforcement for dedicated servers. Runs before any Minecraft class is loaded, i.e. before the server reads
 * {@code <world>/datapacks}, so quarantined packs really are not loaded. The world folder is located through
 * {@code level-name} in {@code server.properties}. If the world does not exist yet there is nothing to enforce; the
 * baseline is then captured by the {@code SERVER_STARTING} pass in {@link DatapackBlockerMod}.
 */
public final class DatapackBlockerPreLaunch implements PreLaunchEntrypoint {
    @Override
    public void onPreLaunch() {
        if (FabricLoader.getInstance().getEnvironmentType() != EnvType.SERVER) {
            return;
        }
        try {
            Path gameDir = FabricLoader.getInstance().getGameDir();
            Path worldRoot = gameDir.resolve(readLevelName(gameDir.resolve("server.properties"))).normalize();
            Path datapacks = worldRoot.resolve("datapacks");
            if (!Files.isDirectory(datapacks)) {
                DatapackBlockerMod.LOGGER.info("Datapack Blocker: no datapacks folder at '{}' yet; early enforcement skipped.", datapacks);
                return;
            }
            new AllowlistManager(datapacks, worldRoot, DatapackBlockerMod.LOGGER).enforce(AllowlistManager.Phase.EARLY);
        } catch (Exception exception) {
            // Never take the server down over this - log loudly and let it boot.
            DatapackBlockerMod.LOGGER.error("Datapack Blocker: early enforcement failed, datapacks folder was left as-is.", exception);
        }
    }

    private static String readLevelName(Path serverProperties) throws IOException {
        if (!Files.isRegularFile(serverProperties)) {
            return "world";
        }
        Properties properties = new Properties();
        try (InputStream in = Files.newInputStream(serverProperties)) {
            properties.load(in);
        }
        String name = properties.getProperty("level-name", "world").strip();
        return name.isEmpty() ? "world" : name;
    }
}
