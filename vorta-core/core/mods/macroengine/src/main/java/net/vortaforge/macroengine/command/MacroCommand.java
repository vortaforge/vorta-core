package net.vortaforge.macroengine.command;

import com.mojang.brigadier.CommandDispatcher;
import com.mojang.brigadier.arguments.StringArgumentType;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.minecraft.commands.CommandSourceStack;
import net.minecraft.commands.Commands;
import net.minecraft.network.chat.Component;
import net.minecraft.server.MinecraftServer;
import net.vortaforge.macroengine.MacroEngine;
import net.vortaforge.macroengine.module.MacroModule;
import net.vortaforge.macroengine.module.ModuleRegistry;
import net.vortaforge.macroengine.validate.PackScanner;

/**
 * {@code /macroengine ...} - the operator's entry point.
 *
 * <p>This is also what the datapack calls: a function can run
 * {@code macroengine module vf_alert} and read the result, so the pack does not
 * need its own copy of the verdict.
 *
 * <p>Permission level 2 (gamemaster) throughout. A player being able to trigger a
 * full re-scan is a trivial way to make a server stutter every tick, and nothing
 * here is a player-facing action.
 */
public final class MacroCommand {
    private MacroCommand() {
    }

    public static void register() {
        CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) ->
                register(dispatcher));
    }

    private static void register(CommandDispatcher<CommandSourceStack> dispatcher) {
        dispatcher.register(Commands.literal("macroengine")
                .requires(Commands.hasPermission(Commands.LEVEL_GAMEMASTERS))

                .then(Commands.literal("rescan")
                        .executes(ctx -> {
                            MinecraftServer server = ctx.getSource().getServer();
                            PackScanner.Report report = MacroEngine.scanAndReport(
                                    "manual rescan", server.getResourceManager());
                            ctx.getSource().sendSuccess(() -> Component.literal(report.summaryLine()), false);
                            return report.isClean() ? 1 : 0;
                        }))

                .then(Commands.literal("status")
                        .executes(ctx -> {
                            var report = net.vortaforge.macroengine.scan.ScanResults.current();
                            ctx.getSource().sendSuccess(() -> Component.literal(report.summaryLine()), false);
                            if (!report.inspectedAnything()) {
                                return 0;
                            }
                            return report.isClean() ? 1 : 0;
                        }))

                .then(Commands.literal("modules")
                        .executes(ctx -> {
                            var modules = ModuleRegistry.all();
                            ctx.getSource().sendSuccess(
                                    () -> Component.literal("macroEngine modules (" + modules.size() + "):"), false);
                            for (MacroModule module : modules) {
                                ctx.getSource().sendSuccess(() -> Component.literal(
                                        "  " + module.id() + " - " + module.description()), false);
                            }
                            return modules.size();
                        }))

                // The datapack-facing call: run a module by id with string args.
                .then(Commands.literal("module")
                        .then(Commands.argument("id", StringArgumentType.word())
                                .executes(ctx -> runModule(ctx.getSource(),
                                        StringArgumentType.getString(ctx, "id"), new String[0]))
                                .then(Commands.argument("args", StringArgumentType.greedyString())
                                        .executes(ctx -> runModule(ctx.getSource(),
                                                StringArgumentType.getString(ctx, "id"),
                                                StringArgumentType.getString(ctx, "args").trim().split("\\s+")))))));
    }

    private static int runModule(CommandSourceStack source, String id, String[] args) {
        var found = ModuleRegistry.find(id);
        if (found.isEmpty()) {
            // Naming the id that failed matters: silently doing nothing is how a
            // typo in a pack function goes unnoticed for months.
            source.sendFailure(Component.literal(
                    "macroEngine: no module named '" + id + "'; try /macroengine modules"));
            return 0;
        }

        MacroModule module = found.get();
        long tick = source.getServer().getTickCount();
        MacroModule.Context context = new MacroModule.Context() {
            @Override
            public CommandSourceStack source() {
                return source;
            }

            @Override
            public String[] args() {
                return args;
            }

            @Override
            public void log(String message) {
                source.sendSuccess(() -> Component.literal(message), false);
                MacroEngine.LOG.info("macroEngine[{}]: {}", id, message);
            }

            @Override
            public long tick() {
                return tick;
            }
        };

        try {
            String result = module.run(context);
            // Chat feedback is used by a pack that wants to branch on the answer;
            // without it the function has nothing to read back.
            source.sendSuccess(() -> Component.literal("macroengine:" + id + " -> " + result), false);
            return 1;
        } catch (MacroModule.ModuleException e) {
            // An expected bad argument: report it as the operator error it is,
            // without a stack trace pretending the mod crashed.
            source.sendFailure(Component.literal("macroEngine: " + e.getMessage()));
            return 0;
        }
    }
}
