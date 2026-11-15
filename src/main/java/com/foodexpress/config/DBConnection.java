package com.foodexpress.config;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Centralized JDBC connection manager for FoodExpress.
 * Resolution order (highest priority first):
 *  1. JVM System Properties (-DDB_HOST, -DDB_USER, -DDB_PASSWORD, ...)
 *  2. OS Environment Variables (DB_HOST, DB_USER, DB_PASSWORD, ...)
 *  3. Tomcat external config (${catalina.base}/conf/foodexpress-db.properties or ${catalina.home}/conf/foodexpress-db.properties)
 *  4. User home config (${user.home}/.foodexpress-db.properties)
 *  5. Local .env file in working directory
 *  6. Classpath db.properties
 */
public final class DBConnection {

    private static final String PLACEHOLDER_PASSWORD = "YOUR_MYSQL_PASSWORD_HERE";
    private static final Map<String, String> CLASSPATH_PROPS = new LinkedHashMap<>();
    private static final Map<String, String> TOMCAT_PROPS = new LinkedHashMap<>();
    private static final Map<String, String> USER_HOME_PROPS = new LinkedHashMap<>();
    private static final Map<String, String> DOTENV = new LinkedHashMap<>();

    private static volatile String tomcatConfigPath = null;
    private static volatile String userHomeConfigPath = null;
    private static volatile String dotEnvPath = null;
    private static volatile String lastConnectionError = null;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("MySQL JDBC Driver not found: " + e.getMessage());
        }
        reloadConfiguration();
    }

    private DBConnection() {
    }

    public static synchronized void reloadConfiguration() {
        CLASSPATH_PROPS.clear();
        TOMCAT_PROPS.clear();
        USER_HOME_PROPS.clear();
        DOTENV.clear();
        tomcatConfigPath = null;
        userHomeConfigPath = null;
        dotEnvPath = null;

        loadClasspathProperties();
        loadTomcatProperties();
        loadUserHomeProperties();
        loadDotEnv();
    }

    private static void loadClasspathProperties() {
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                parseKeyValueStream(in, CLASSPATH_PROPS);
            }
        } catch (IOException ignored) {
        }
    }

    private static void loadTomcatProperties() {
        String catalinaBase = System.getProperty("catalina.base");
        String catalinaHome = System.getProperty("catalina.home");
        Path[] candidates = new Path[] {
            catalinaBase != null ? Paths.get(catalinaBase, "conf", "foodexpress-db.properties") : null,
            catalinaHome != null ? Paths.get(catalinaHome, "conf", "foodexpress-db.properties") : null,
            Paths.get("foodexpress-db.properties")
        };
        for (Path p : candidates) {
            if (p != null && Files.isRegularFile(p)) {
                try (InputStream in = Files.newInputStream(p)) {
                    parseKeyValueStream(in, TOMCAT_PROPS);
                    tomcatConfigPath = p.toAbsolutePath().toString();
                    break;
                } catch (IOException ignored) {
                }
            }
        }
    }

    private static void loadUserHomeProperties() {
        String userHome = System.getProperty("user.home");
        if (userHome == null || userHome.isBlank()) return;
        Path p = Paths.get(userHome, ".foodexpress-db.properties");
        if (Files.isRegularFile(p)) {
            try (InputStream in = Files.newInputStream(p)) {
                parseKeyValueStream(in, USER_HOME_PROPS);
                userHomeConfigPath = p.toAbsolutePath().toString();
            } catch (IOException ignored) {
            }
        }
    }

    private static void loadDotEnv() {
        Path[] candidates = new Path[] {
            Paths.get(".env"),
            Paths.get(System.getProperty("user.dir", "."), ".env")
        };
        for (Path p : candidates) {
            if (Files.isRegularFile(p)) {
                try (InputStream in = Files.newInputStream(p)) {
                    parseKeyValueStream(in, DOTENV);
                    dotEnvPath = p.toAbsolutePath().toString();
                    break;
                } catch (IOException ignored) {
                }
            }
        }
    }

    /**
     * Parses UTF-8 key=value lines safely (strips UTF-8 BOM, preserves backslashes in passwords,
     * ignores blank/comment lines, trims keys and surrounding whitespace on values).
     */
    private static void parseKeyValueStream(InputStream in, Map<String, String> target) throws IOException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String raw;
            boolean firstLine = true;
            while ((raw = reader.readLine()) != null) {
                if (firstLine) {
                    firstLine = false;
                    if (!raw.isEmpty() && raw.charAt(0) == '\uFEFF') {
                        raw = raw.substring(1);
                    }
                }
                String trimmed = raw.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#") || trimmed.startsWith("!")) {
                    continue;
                }
                int idx = raw.indexOf('=');
                if (idx > 0) {
                    String key = raw.substring(0, idx).trim();
                    String val = raw.substring(idx + 1).trim();
                    if ((val.startsWith("\"") && val.endsWith("\"") && val.length() >= 2) ||
                        (val.startsWith("'") && val.endsWith("'") && val.length() >= 2)) {
                        val = val.substring(1, val.length() - 1);
                    }
                    target.put(key, val);
                }
            }
        }
    }

    private static boolean isUsable(String val, boolean isPassword) {
        if (val == null || val.isBlank()) return false;
        if (isPassword && PLACEHOLDER_PASSWORD.equals(val.trim())) return false;
        return true;
    }

    private static String resolve(String envKey, String propKey, String defaultValue, boolean isPassword) {
        String val = System.getProperty(envKey);
        if (isUsable(val, isPassword)) return val.trim();

        val = System.getenv(envKey);
        if (isUsable(val, isPassword)) return val.trim();

        val = firstUsable(TOMCAT_PROPS, envKey, propKey, isPassword);
        if (val != null) return val;

        val = firstUsable(USER_HOME_PROPS, envKey, propKey, isPassword);
        if (val != null) return val;

        val = firstUsable(DOTENV, envKey, propKey, isPassword);
        if (val != null) return val;

        val = firstUsable(CLASSPATH_PROPS, envKey, propKey, isPassword);
        if (val != null) return val;

        return defaultValue;
    }

    private static String firstUsable(Map<String, String> map, String envKey, String propKey, boolean isPassword) {
        String v = map.get(propKey);
        if (isUsable(v, isPassword)) return v.trim();
        v = map.get(envKey);
        if (isUsable(v, isPassword)) return v.trim();
        return null;
    }

    public static String getActivePasswordSource() {
        if (isUsable(System.getProperty("DB_PASSWORD"), true)) return "JVM System Property (-DDB_PASSWORD)";
        if (isUsable(System.getenv("DB_PASSWORD"), true)) return "OS Environment Variable (DB_PASSWORD)";
        if (firstUsable(TOMCAT_PROPS, "DB_PASSWORD", "db.password", true) != null) return "Tomcat config (" + tomcatConfigPath + ")";
        if (firstUsable(USER_HOME_PROPS, "DB_PASSWORD", "db.password", true) != null) return "User home config (" + userHomeConfigPath + ")";
        if (firstUsable(DOTENV, "DB_PASSWORD", "db.password", true) != null) return ".env file (" + dotEnvPath + ")";
        if (firstUsable(CLASSPATH_PROPS, "DB_PASSWORD", "db.password", true) != null) return "Classpath db.properties";
        return "None (password not configured)";
    }

    public static String getLoadedConfigSummary() {
        return String.format(
            "host=%s, port=%s, database=%s, user=%s, passwordPresent=%s, passwordSource=%s, tomcatConfig=%s, userHomeConfig=%s",
            getHost(), getPort(), getDatabaseName(), getUser(),
            isPasswordConfigured(), getActivePasswordSource(),
            tomcatConfigPath != null ? tomcatConfigPath : "not found",
            userHomeConfigPath != null ? userHomeConfigPath : "not found"
        );
    }

    public static String getHost() {
        return resolve("DB_HOST", "db.host", "localhost", false);
    }

    public static String getPort() {
        return resolve("DB_PORT", "db.port", "3306", false);
    }

    public static String getDatabaseName() {
        return resolve("DB_NAME", "db.name", "food_delivery_db", false);
    }

    public static String getSandboxDatabaseName() {
        return resolve("SANDBOX_DB_NAME", "db.sandbox", "food_delivery_sandbox", false);
    }

    public static String getUser() {
        return resolve("DB_USER", "db.user", "root", false);
    }

    private static String getPassword() {
        return resolve("DB_PASSWORD", "db.password", "", true);
    }

    public static boolean isPasswordConfigured() {
        return !getPassword().isEmpty();
    }

    private static String getSqlConsoleUser() {
        String u = resolve("SQL_CONSOLE_DB_USER", "sql.console.user", "", false);
        return u.isEmpty() ? getUser() : u;
    }

    private static String getSqlConsolePassword() {
        String p = resolve("SQL_CONSOLE_DB_PASSWORD", "sql.console.password", "", true);
        return p.isEmpty() ? getPassword() : p;
    }

    public static String getJdbcUrl() {
        return buildJdbcUrl(getDatabaseName());
    }

    private static String buildJdbcUrl(String dbName) {
        return String.format(
            "jdbc:mysql://%s:%s/%s?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata&characterEncoding=UTF-8",
            getHost(), getPort(), dbName
        );
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(buildJdbcUrl(getDatabaseName()), getUser(), getPassword());
            lastConnectionError = null;
            return conn;
        } catch (SQLException e) {
            lastConnectionError = sanitizeError(e);
            throw e;
        }
    }

    public static Connection getSqlConsoleConnection(boolean useSandbox) throws SQLException {
        String targetDb = useSandbox ? getSandboxDatabaseName() : getDatabaseName();
        try {
            Connection conn = DriverManager.getConnection(buildJdbcUrl(targetDb), getSqlConsoleUser(), getSqlConsolePassword());
            lastConnectionError = null;
            return conn;
        } catch (SQLException e) {
            lastConnectionError = sanitizeError(e);
            throw e;
        }
    }

    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && conn.isValid(3);
        } catch (SQLException e) {
            lastConnectionError = sanitizeError(e);
            return false;
        }
    }

    public static String getLastConnectionError() {
        return lastConnectionError;
    }

    private static String sanitizeError(SQLException e) {
        String msg = e.getMessage();
        if (msg == null) return "Unknown database connection error";
        if (!isPasswordConfigured() && msg.contains("using password: NO")) {
            return "MySQL password is not configured. Set DB_PASSWORD or create conf/foodexpress-db.properties in Tomcat.";
        }
        return msg;
    }

    public static void closeQuietly(AutoCloseable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (Exception ignored) {
            }
        }
    }
}
