package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.slf4j.Logger;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

/** Loads/creates {@code config/join-throttle.json}. Kept apart from {@link ThrottleSettings} so the latter stays Gson-free. */
final class SettingsFile {

    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();

    private SettingsFile() {}

    static ThrottleSettings loadOrCreate(Path file, Logger log) {
        if (Files.exists(file)) {
            try {
                ThrottleSettings parsed = GSON.fromJson(Files.readString(file, StandardCharsets.UTF_8), ThrottleSettings.class);
                if (parsed != null) return parsed.sanitized();
                log.warn("{} is empty, using defaults.", file.getFileName());
            } catch (IOException | RuntimeException e) {
                // Never take the server down over a bad config: fall back to safe defaults and say so.
                log.error("Could not read {} ({}), using defaults.", file.getFileName(), e.getMessage());
            }
            return new ThrottleSettings().sanitized();
        }
        ThrottleSettings defaults = new ThrottleSettings();
        try {
            Files.createDirectories(file.getParent());
            Files.writeString(file, GSON.toJson(defaults), StandardCharsets.UTF_8);
        } catch (IOException e) {
            log.warn("Could not write default {}: {}", file.getFileName(), e.getMessage());
        }
        return defaults.sanitized();
    }
}
