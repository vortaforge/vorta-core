package com.vortacraftmc.datapackblocker.command;

import com.mojang.brigadier.CommandDispatcher;
import com.mojang.brigadier.arguments.StringArgumentType;
import com.mojang.brigadier.context.CommandContext;
import com.mojang.brigadier.suggestion.SuggestionProvider;
import com.vortacraftmc.datapackblocker.AllowlistManager;
import com.vortacraftmc.datapackblocker.DatapackBlockerMod;
import net.minecraft.command.CommandRegistryAccess;
import net.minecraft.server.command.CommandManager;
import net.minecraft.server.command.ServerCommandSource;
import net.minecraft.text.Text;
import net.minecraft.util.WorldSavePath;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

/**
 * {@code /datapackblocker} - op-only (permission level 4) admin surface for {@link AllowlistManager}. All
 * subcommands re-derive the manager from the live server each time rather than caching it.
 */
public final class BlockerCommand {

    private BlockerCommand() {
    }

    private static final SuggestionProvider<ServerCommandSource> QUARANTINED_NAMES = (context, builder) -> {
        try {
            String typed = builder.getRemainingLowerCase();
            for (String name : manager(context.getSource()).listQuarantined()) {
                if (name.toLowerCase(Locale.ROOT).startsWith(typed)) {
                    builder.suggest(name);
                }
            }
        } catch (IOException ignored) {
            // no suggestions on I/O trouble
        }
        return builder.buildFuture();
    };

    public static void register(CommandDispatcher<ServerCommandSource> dispatcher, CommandRegistryAccess registryAccess) {
        dispatcher.register(CommandManager.literal("datapackblocker")
                .requires(source -> source.hasPermissionLevel(4))
                .then(CommandManager.literal("status").executes(BlockerCommand::status))
                .then(CommandManager.literal("verify").executes(BlockerCommand::verify))
                .then(CommandManager.literal("unlock").executes(BlockerCommand::unlock))
                .then(CommandManager.literal("lock").executes(BlockerCommand::lock))
                .then(CommandManager.literal("approve")
                        .then(CommandManager.argument("name", StringArgumentType.greedyString())
                                .suggests(QUARANTINED_NAMES)
                                .executes(BlockerCommand::approve))));
    }

    private static AllowlistManager manager(ServerCommandSource source) {
        var server = source.getServer();
        return new AllowlistManager(
                server.getSavePath(WorldSavePath.DATAPACKS),
                server.getSavePath(WorldSavePath.ROOT),
                DatapackBlockerMod.LOGGER);
    }

    private static int status(CommandContext<ServerCommandSource> context) {
        try {
            AllowlistManager manager = manager(context.getSource());
            var quarantined = manager.listQuarantineEntries();
            int allowlisted = manager.allowlistSize();
            context.getSource().sendFeedback(() -> Text.literal("Datapack Blocker: " + allowlisted + " allowlisted pack(s), "
                    + quarantined.size() + " in quarantine"
                    + (quarantined.isEmpty() ? "." : ": " + quarantined.stream().map(e -> e.name() + " (" + e.batch() + ")").toList()
                    + ". Use /datapackblocker approve <name> to review and allow one.")), false);
            return 1;
        } catch (IOException exception) {
            context.getSource().sendError(Text.literal("Datapack Blocker status check failed: " + exception.getMessage()));
            return 0;
        }
    }

    /** Read-only: shows what a restart would quarantine. Closes the "added mid-session, picked up by /reload" gap. */
    private static int verify(CommandContext<ServerCommandSource> context) {
        try {
            AllowlistManager.Audit audit = manager(context.getSource()).audit();
            context.getSource().sendFeedback(() -> Text.literal(audit.clean()
                    ? "Datapack Blocker verify: OK - " + audit.ok() + " pack(s) match the allowlist."
                    : "Datapack Blocker verify: PROBLEMS - unreviewed " + audit.unreviewed() + ", modified " + audit.modified()
                    + ", missing " + audit.missing() + ". Unreviewed/modified packs are quarantined on the next restart."), false);
            if (!audit.unverified().isEmpty()) {
                context.getSource().sendFeedback(() -> Text.literal("Datapack Blocker verify: no fingerprint yet for "
                        + audit.unverified() + " (v1 allowlist entries); a restart or /datapackblocker lock records one."), false);
            }
            return audit.clean() ? 1 : 0;
        } catch (IOException exception) {
            context.getSource().sendError(Text.literal("Datapack Blocker verify failed: " + exception.getMessage()));
            return 0;
        }
    }

    private static int unlock(CommandContext<ServerCommandSource> context) {
        try {
            List<String> unlocked = manager(context.getSource()).unlock();
            context.getSource().sendFeedback(() -> Text.literal(
                    "Unlocked " + unlocked.size() + " pack(s) for editing: " + unlocked
                            + ". Run /datapackblocker lock when you're done - it also records the edited contents as trusted."), true);
            return 1;
        } catch (IOException exception) {
            context.getSource().sendError(Text.literal("Datapack Blocker unlock failed: " + exception.getMessage()));
            return 0;
        }
    }

    private static int lock(CommandContext<ServerCommandSource> context) {
        try {
            List<String> locked = manager(context.getSource()).lock();
            context.getSource().sendFeedback(() -> Text.literal("Locked " + locked.size() + " pack(s) and recorded their current contents as trusted: " + locked), true);
            return 1;
        } catch (IOException exception) {
            context.getSource().sendError(Text.literal("Datapack Blocker lock failed: " + exception.getMessage()));
            return 0;
        }
    }

    private static int approve(CommandContext<ServerCommandSource> context) {
        String name = StringArgumentType.getString(context, "name");
        try {
            boolean approved = manager(context.getSource()).approve(name);
            if (approved) {
                context.getSource().sendFeedback(() -> Text.literal(
                        "'" + name + "' approved and restored. Run /reload to load it."), true);
                return 1;
            } else {
                context.getSource().sendError(Text.literal("No quarantined pack named '" + name + "' was found."));
                return 0;
            }
        } catch (IllegalArgumentException exception) {
            context.getSource().sendError(Text.literal("Datapack Blocker approve rejected: " + exception.getMessage()));
            return 0;
        } catch (IOException exception) {
            context.getSource().sendError(Text.literal("Datapack Blocker approve failed: " + exception.getMessage()));
            return 0;
        }
    }
}
