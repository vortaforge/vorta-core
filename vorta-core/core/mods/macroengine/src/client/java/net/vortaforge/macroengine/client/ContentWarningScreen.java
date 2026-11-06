package net.vortaforge.macroengine.client;

import net.minecraft.client.gui.GuiGraphicsExtractor;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;
import net.vortaforge.macroengine.validate.PackMetaValidator;
import net.vortaforge.macroengine.validate.SuspiciousText;

import java.util.ArrayList;
import java.util.List;

/**
 * The screen a player sees before they press "Create New World" or open a world,
 * when the loaded data packs have findings.
 *
 * <h2>Why a screen rather than a chat line</h2>
 *
 * A datapack's warning in chat scrolls away, and on a fresh world there is no chat
 * history to scroll. This sits in front of the decision instead of after it. The
 * player reads what was found, then either continues or goes back.
 *
 * <h2>Why it shows the matched text, not just a count</h2>
 *
 * "3 warnings found" is unfalsifiable and teaches players to click past it. The
 * actual snippet is what lets a person decide for themselves, including deciding
 * the scanner is wrong - which is a legitimate outcome and is why the "continue"
 * button says so plainly rather than hiding behind a neutral label.
 *
 * <h2>26.3 rendering note</h2>
 *
 * 26.3 has no {@code Screen.render}; drawing happens in
 * {@link #extractRenderState} against a {@link GuiGraphicsExtractor}. Code that
 * copies a 1.21-era screen and overrides {@code render(GuiGraphics, ...)} will
 * compile against nothing and fail at class load, so this method name is not
 * cosmetic.
 */
public final class ContentWarningScreen extends Screen {
    private static final int MARGIN = 24;
    private static final int MAX_LINES = 9;

    private final Screen parent;
    private final List<String> lines;
    private final boolean highSeverity;

    public ContentWarningScreen(Screen parent, List<SuspiciousText.Finding> findings,
                                List<PackMetaValidator.Problem> metaProblems, boolean highSeverity) {
        super(Component.literal("macroEngine - content check"));
        this.parent = parent;
        this.highSeverity = highSeverity;
        this.lines = buildLines(findings, metaProblems);
    }

    private static List<String> buildLines(List<SuspiciousText.Finding> findings,
                                           List<PackMetaValidator.Problem> metaProblems) {
        List<String> out = new ArrayList<>();
        if (findings.isEmpty() && metaProblems.isEmpty()) {
            out.add("Nothing was found.");
            return out;
        }
        int shown = 0;
        for (SuspiciousText.Finding finding : findings) {
            if (shown++ >= MAX_LINES) {
                out.add("… and " + (findings.size() - MAX_LINES) + " more. See the server log.");
                break;
            }
            // Severity first: a reader scanning the list needs to know which line
            // matters before they read what it says.
            out.add("[" + finding.severity() + "] " + finding.where());
            out.add("    \"" + finding.snippet() + "\"");
        }
        for (PackMetaValidator.Problem problem : metaProblems) {
            if (shown++ >= MAX_LINES) {
                out.add("… and " + metaProblems.size() + " more metadata problem(s). See the server log.");
                break;
            }
            out.add("[meta] " + problem.where() + ": " + problem.message());
        }
        return out;
    }

    @Override
    protected void init() {
        int buttonY = this.height - 44;

        // The primary action is placed first and labelled plainly. Two buttons that
        // both read as "OK" would make the choice meaningless.
        this.addRenderableWidget(Button.builder(
                        Component.literal(highSeverity ? "Continue anyway" : "Continue"),
                        b -> closeToParent())
                .bounds(this.width / 2 - 155, buttonY, 150, 20)
                .build());

        this.addRenderableWidget(Button.builder(
                        Component.literal("Back"),
                        b -> {
                            if (this.minecraft != null) {
                                this.minecraft.setScreenAndShow(parent);
                            }
                        })
                .bounds(this.width / 2 + 5, buttonY, 150, 20)
                .build());
    }

    private void closeToParent() {
        if (this.minecraft != null) {
            this.minecraft.setScreenAndShow(parent);
        }
    }

    @Override
    public void extractRenderState(GuiGraphicsExtractor graphics, int mouseX, int mouseY, float partialTick) {
        super.extractRenderState(graphics, mouseX, mouseY, partialTick);

        int top = 40;
        graphics.centeredText(this.font,
                highSeverity ? "macroEngine found something that needs your attention"
                        : "macroEngine found something worth a look",
                this.width / 2, top, 0xFFFF5555);
        top += 22;

        graphics.centeredText(this.font,
                "These data packs are loaded on this world.",
                this.width / 2, top, 0xFFAAAAAA);
        top += 24;

        for (String line : lines) {
            // Clip rather than let a long snippet run off the window and become
            // unreadable, which is how a warning ends up ignored.
            String shown = line;
            int maxWidth = this.width - MARGIN * 2;
            if (this.font.width(shown) > maxWidth) {
                while (shown.length() > 4 && this.font.width(shown + "…") > maxWidth) {
                    shown = shown.substring(0, shown.length() - 1);
                }
                shown = shown + "…";
            }
            int colour = line.startsWith("[HIGH]") ? 0xFFFF5555
                    : line.startsWith("[meta]") ? 0xFFFFAA00
                    : line.startsWith("[WARN]") ? 0xFFFFCC66
                    : 0xFFDDDDDD;
            graphics.text(this.font, shown, MARGIN, top, colour, false);
            top += 14;
        }

        super.extractRenderState(graphics, mouseX, mouseY, partialTick);
    }

    @Override
    public boolean isPauseScreen() {
        // The world is not running yet; pausing is meaningless here and only makes
        // the screen feel stuck.
        return false;
    }
}
