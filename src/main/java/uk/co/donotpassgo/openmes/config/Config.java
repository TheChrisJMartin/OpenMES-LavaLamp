package uk.co.donotpassgo.openmes.config;

import java.util.ArrayList;
import java.util.List;

/**
 * Environment-only secrets and connection settings.
 * Operator tunables live in system_config after the migrator has run.
 */
public final class Config {
    public static final String[] REQUIRED = {
        "OPENMES_DB_URL",
        "OPENMES_DB_USER",
        "OPENMES_DB_PASSWORD"
    };

    private Config() {}

    public static String get(String key, String def) {
        String v = System.getenv(key);
        return (v == null || v.isBlank()) ? def : v.trim();
    }

    public static String require(String key) {
        String v = System.getenv(key);
        if (v == null || v.isBlank()) {
            throw new IllegalStateException("Missing required environment variable: " + key);
        }
        return v.trim();
    }

    public static List<String> missingRequired() {
        List<String> missing = new ArrayList<>();
        for (String key : REQUIRED) {
            String v = System.getenv(key);
            if (v == null || v.isBlank()) missing.add(key);
        }
        return missing;
    }

    public static void requireAll() {
        List<String> missing = missingRequired();
        if (!missing.isEmpty()) {
            throw new IllegalStateException(
                "OpenMES refused to start; set: " + String.join(", ", missing));
        }
    }

    public static String dbUrl() {
        return require("OPENMES_DB_URL");
    }

    public static String dbUser() {
        return require("OPENMES_DB_USER");
    }

    public static String dbPassword() {
        return require("OPENMES_DB_PASSWORD");
    }

    public static String baseUrl() {
        return get("OPENMES_BASE_URL", "http://localhost:8080/openmes");
    }

    public static int poolSize() {
        try {
            return Integer.parseInt(get("OPENMES_DB_POOL", "8"));
        } catch (NumberFormatException e) {
            return 8;
        }
    }
}
