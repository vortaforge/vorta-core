package com.vortacraftmc.afkmanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import com.mojang.brigadier.Command;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerTickEvents;
import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.fabricmc.fabric.api.message.v1.ServerMessageEvents;
import net.fabricmc.fabric.api.networking.v1.ServerPlayConnectionEvents;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.command.CommandManager;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.text.Text;
import net.minecraft.util.ActionResult;
import net.minecraft.util.Formatting;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * AFK Manager - Fabric mod for Minecraft 1.21.1 (dedicated server).
 *
 * <p>Activity = moved/turned (sampled once per second), sent a chat message,
 * or right-clicked a block. The state machine itself is {@link IdleTracker}.
 * Time is measured in server ticks (x50 ms), so a lagging server does not
 * mass-mark players AFK.
 */
public class AfkManagerMod implements ModInitializer {

    public static final String MOD_ID = "afk-manager";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    /** Movement is sampled once per second. */
    private static final int CHECK_INTERVAL_TICKS = 20;

    private final Map<UUID, MotionSample> lastMotion = new HashMap<>();
    private AfkSettings settings;
    private IdleTracker<UUID> tracker;

    @Override
    public void onInitialize() {
        settings = SettingsFile.loadOrCreate(FabricLoader.getInstance().getConfigDir().resolve("afk-manager.json"), LOGGER);
        tracker = new IdleTracker<>(settings.afkAfterSeconds * 1000L, settings.kickAfterSeconds * 1000L);

        ServerTickEvents.END_SERVER_TICK.register(this::onTick);

        ServerMessageEvents.CHAT_MESSAGE.register((message, sender, params) -> markActive(sender));
        UseBlockCallback.EVENT.register((player, world, hand, hitResult) -> {
            if (player instanceof ServerPlayerEntity sp) markActive(sp);
            return ActionResult.PASS;
        });

        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> markActive(handler.player));
        ServerPlayConnectionEvents.DISCONNECT.register((handler, server) -> {
            tracker.remove(handler.player.getUuid());
            lastMotion.remove(handler.player.getUuid());
        });

        CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) ->
                dispatcher.register(CommandManager.literal("afk").executes(ctx -> {
                    ServerPlayerEntity player = ctx.getSource().getPlayerOrThrow();
                    boolean nowAfk = !tracker.isAfk(player.getUuid());
                    tracker.setAfk(player.getUuid(), nowMillis(ctx.getSource().getServer()), nowAfk);
                    if (nowAfk) announceAfk(player); else announceBack(player);
                    return Command.SINGLE_SUCCESS;
                })));

        LOGGER.info("AFK Manager active: AFK after {}s, kick {}.", settings.afkAfterSeconds,
                settings.kickAfterSeconds == 0 ? "disabled" : "after " + settings.kickAfterSeconds + "s");
    }

    private static long nowMillis(MinecraftServer server) {
        return server.getTicks() * 50L;
    }

    private void markActive(ServerPlayerEntity player) {
        MinecraftServer server = player.getServer();
        if (server == null) return;
        if (tracker.activity(player.getUuid(), nowMillis(server))) {
            announceBack(player);
        }
    }

    private void onTick(MinecraftServer server) {
        int ticks = server.getTicks();
        if (ticks % CHECK_INTERVAL_TICKS != 0) return;
        long now = ticks * 50L;

        for (ServerPlayerEntity player : List.copyOf(server.getPlayerManager().getPlayerList())) {
            UUID id = player.getUuid();
            MotionSample current = new MotionSample(player.getX(), player.getY(), player.getZ(), player.getYaw(), player.getPitch());
            MotionSample previous = lastMotion.put(id, current);

            if (previous != null && current.differsFrom(previous)) {
                if (tracker.activity(id, now)) announceBack(player);
                continue;
            }
            switch (tracker.check(id, now)) {
                case BECAME_AFK -> announceAfk(player);
                case SHOULD_KICK -> kick(server, player);
                case NONE -> { }
            }
        }
    }

    private void kick(MinecraftServer server, ServerPlayerEntity player) {
        if (settings.exemptOperatorsFromKick && server.getPlayerManager().isOperator(player.getGameProfile())) {
            return;
        }
        LOGGER.info("Kicking {} for being AFK too long.", player.getGameProfile().getName());
        tracker.remove(player.getUuid());
        lastMotion.remove(player.getUuid());
        player.networkHandler.disconnect(Text.literal(settings.kickMessage));
    }

    private void announceAfk(ServerPlayerEntity player) {
        announce(player, " is now AFK");
    }

    private void announceBack(ServerPlayerEntity player) {
        announce(player, " is no longer AFK");
    }

    private void announce(ServerPlayerEntity player, String suffix) {
        if (!settings.announce) return;
        MinecraftServer server = player.getServer();
        if (server == null) return;
        server.getPlayerManager().broadcast(
                Text.empty().append(player.getDisplayName()).append(Text.literal(suffix)).formatted(Formatting.GRAY),
                false);
    }
}
