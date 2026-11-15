package com.foodexpress.service;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.QueryHistoryEntry;
import com.foodexpress.model.QueryResult;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicLong;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Genuine JDBC SQL Query Execution Engine for the Admin SQL Console.
 * Uses Statement.execute() and ResultSetMetaData for dynamic query execution.
 */
public class SqlExecutionService {

    public enum ExecutionMode {
        LANDING_PUBLIC,
        ADMIN_FULL
    }

    private static final int MAX_ROWS = 1000;
    private static final int QUERY_TIMEOUT_SECONDS = 10;
    private static final int MAX_HISTORY = 100;
    private static final LinkedList<QueryHistoryEntry> HISTORY = new LinkedList<>();
    private static final AtomicLong HISTORY_SEQ = new AtomicLong(1);
    private static final DateTimeFormatter TS_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private static final Pattern CORE_TABLE_DDL = Pattern.compile(
        "\\b(DROP|TRUNCATE)\\s+(TABLE|DATABASE)\\b",
        Pattern.CASE_INSENSITIVE
    );

    private static final Pattern BLOCKED_PUBLIC_KEYWORDS = Pattern.compile(
        "\\b(DROP|TRUNCATE|ALTER|CREATE|RENAME|GRANT|REVOKE|SHUTDOWN|KILL|LOAD\\s+DATA|INTO\\s+OUTFILE|INTO\\s+DUMPFILE|LOAD_FILE|SLEEP|BENCHMARK)\\b",
        Pattern.CASE_INSENSITIVE
    );

    private static final Pattern BLOCKED_SYSTEM_SCHEMAS = Pattern.compile(
        "\\b(mysql|performance_schema|sys)\\s*\\.",
        Pattern.CASE_INSENSITIVE
    );

    public QueryResult executeQuery(String rawSql, boolean useSandbox, boolean confirmDestructive, String adminUsername) {
        return executeQuery(rawSql, useSandbox, confirmDestructive, adminUsername, "CONSOLE", ExecutionMode.ADMIN_FULL);
    }

    public QueryResult executeQuery(String rawSql, boolean useSandbox, boolean confirmDestructive,
                                    String executedBy, String source, ExecutionMode mode) {
        QueryResult result = new QueryResult();
        String dbName = useSandbox ? DBConnection.getSandboxDatabaseName() : DBConnection.getDatabaseName();
        result.setDatabaseName(dbName);
        result.setSource(source != null ? source : "MANUAL");

        if (rawSql == null || rawSql.trim().isEmpty()) {
            result.setSuccess(false);
            result.setErrorMessage("SQL query cannot be empty.");
            return result;
        }

        String cleanedSql = stripTrailingSemicolon(rawSql.trim());
        if (containsMultipleStatements(cleanedSql)) {
            result.setSuccess(false);
            result.setStatementType("MULTI_STATEMENT");
            result.setErrorMessage("Multiple SQL statements in a single execution are disabled for security. Please execute one statement at a time.");
            recordHistory(cleanedSql, result, executedBy, source);
            return result;
        }

        String stmtType = detectStatementType(cleanedSql);
        result.setStatementType(stmtType);

        if (mode == ExecutionMode.LANDING_PUBLIC) {
            String permissionError = checkPublicPermission(cleanedSql, stmtType);
            if (permissionError != null) {
                result.setSuccess(false);
                result.setSqlState("42000");
                result.setErrorMessage(permissionError);
                recordHistory(cleanedSql, result, executedBy, source);
                return result;
            }
        }

        // Safeguard: require explicit confirmation for destructive operations on the primary application database
        if (!useSandbox && !confirmDestructive && isDestructiveOnPrimary(cleanedSql, stmtType)) {
            result.setSuccess(false);
            result.setConfirmationRequired(true);
            result.setErrorMessage("Confirmation required: This destructive statement (" + stmtType +
                ") targets the live application database '" + dbName + "'. Confirm to proceed.");
            return result;
        }

        long startNs = System.nanoTime();
        try (Connection conn = DBConnection.getSqlConsoleConnection(useSandbox);
             Statement stmt = conn.createStatement()) {

            stmt.setMaxRows(MAX_ROWS);
            stmt.setQueryTimeout(QUERY_TIMEOUT_SECONDS);
            boolean hasRs = stmt.execute(cleanedSql);
            long elapsedMs = Math.max(1, (System.nanoTime() - startNs) / 1_000_000);
            result.setExecutionTimeMs(elapsedMs);
            result.setSuccess(true);
            result.setHasResultSet(hasRs);

            if (hasRs) {
                try (ResultSet rs = stmt.getResultSet()) {
                    ResultSetMetaData meta = rs.getMetaData();
                    int colCount = meta.getColumnCount();
                    List<String> cols = new ArrayList<>(colCount);
                    List<String> types = new ArrayList<>(colCount);
                    for (int i = 1; i <= colCount; i++) {
                        String label = meta.getColumnLabel(i);
                        if (label == null || label.isEmpty()) {
                            label = meta.getColumnName(i);
                        }
                        cols.add(label);
                        types.add(meta.getColumnTypeName(i));
                    }
                    result.setColumns(cols);
                    result.setColumnTypes(types);

                    List<List<Object>> rows = new ArrayList<>();
                    while (rs.next()) {
                        List<Object> row = new ArrayList<>(colCount);
                        for (int i = 1; i <= colCount; i++) {
                            Object val = rs.getObject(i);
                            if (val instanceof byte[] bytes) {
                                row.add("[BLOB " + bytes.length + " bytes]");
                            } else if (val instanceof Timestamp || val instanceof Date || val instanceof Time) {
                                row.add(val.toString());
                            } else {
                                row.add(val);
                            }
                        }
                        rows.add(row);
                    }
                    result.setRows(rows);
                    result.setRowsReturned(rows.size());
                    result.setStatusMessage("Query executed successfully. " + rows.size() + " row(s) returned in " + elapsedMs + " ms.");
                }
            } else {
                int affected = stmt.getUpdateCount();
                result.setRowsAffected(Math.max(affected, 0));
                result.setStatusMessage(stmtType + " executed successfully. " + Math.max(affected, 0) + " row(s) affected in " + elapsedMs + " ms.");
            }
        } catch (SQLException e) {
            long elapsedMs = Math.max(1, (System.nanoTime() - startNs) / 1_000_000);
            result.setExecutionTimeMs(elapsedMs);
            result.setSuccess(false);
            result.setErrorMessage(e.getMessage());
            result.setSqlState(e.getSQLState());
            result.setErrorCode(e.getErrorCode());
        }

        recordHistory(cleanedSql, result, executedBy, source);
        return result;
    }

    private String checkPublicPermission(String sql, String stmtType) {
        if ("DROP".equals(stmtType) || "TRUNCATE".equals(stmtType) || "ALTER".equals(stmtType) || "CREATE".equals(stmtType)) {
            return "Permission denied: Schema DDL statement '" + stmtType + "' is restricted on the public query interface.";
        }
        if ("SQL".equals(stmtType)) {
            String upper = sql.replaceAll("^/\\*.*?\\*/\\s*", "").trim().toUpperCase(Locale.ROOT);
            if (upper.startsWith("USE ") || upper.startsWith("SET ") || upper.startsWith("GRANT") || upper.startsWith("REVOKE")) {
                return "Permission denied: Session or privilege command is not permitted.";
            }
        }
        if (BLOCKED_PUBLIC_KEYWORDS.matcher(sql).find()) {
            return "Permission denied: Statement contains a restricted SQL keyword or function.";
        }
        if (BLOCKED_SYSTEM_SCHEMAS.matcher(sql).find()) {
            return "Permission denied: Direct access to MySQL system schemas is restricted. Query tables in food_delivery_db.";
        }
        return null;
    }

    public List<QueryHistoryEntry> getHistory() {
        synchronized (HISTORY) {
            return Collections.unmodifiableList(new ArrayList<>(HISTORY));
        }
    }

    public void clearHistory() {
        synchronized (HISTORY) {
            HISTORY.clear();
        }
    }

    private void recordHistory(String sql, QueryResult result, String adminUsername, String source) {
        QueryHistoryEntry entry = new QueryHistoryEntry();
        entry.setId(HISTORY_SEQ.getAndIncrement());
        entry.setSql(sql);
        entry.setDatabaseName(result.getDatabaseName());
        entry.setStatementType(result.getStatementType());
        entry.setSuccess(result.isSuccess());
        entry.setRowsReturned(result.getRowsReturned());
        entry.setRowsAffected(result.getRowsAffected());
        entry.setExecutionTimeMs(result.getExecutionTimeMs());
        entry.setErrorMessage(result.getErrorMessage());
        entry.setExecutedBy(adminUsername != null ? adminUsername : "user");
        entry.setExecutedAt(LocalDateTime.now().format(TS_FMT));
        entry.setSource(source != null ? source : "MANUAL");

        synchronized (HISTORY) {
            HISTORY.addFirst(entry);
            while (HISTORY.size() > MAX_HISTORY) {
                HISTORY.removeLast();
            }
        }
    }

    private String stripTrailingSemicolon(String sql) {
        String s = sql;
        while (s.endsWith(";")) {
            s = s.substring(0, s.length() - 1).trim();
        }
        return s;
    }

    /**
     * Checks for semicolons outside single/double quotes or backticks.
     */
    private boolean containsMultipleStatements(String sql) {
        boolean inSingle = false;
        boolean inDouble = false;
        boolean inBacktick = false;
        for (int i = 0; i < sql.length(); i++) {
            char c = sql.charAt(i);
            char prev = i > 0 ? sql.charAt(i - 1) : '\0';
            if (c == '\'' && !inDouble && !inBacktick && prev != '\\') {
                inSingle = !inSingle;
            } else if (c == '"' && !inSingle && !inBacktick && prev != '\\') {
                inDouble = !inDouble;
            } else if (c == '`' && !inSingle && !inDouble) {
                inBacktick = !inBacktick;
            } else if (c == ';' && !inSingle && !inDouble && !inBacktick) {
                return true;
            }
        }
        return false;
    }

    private String detectStatementType(String sql) {
        String upper = sql.replaceAll("^/\\*.*?\\*/\\s*", "").trim().toUpperCase(Locale.ROOT);
        if (upper.startsWith("SELECT") || upper.startsWith("WITH")) return "SELECT";
        if (upper.startsWith("SHOW")) return "SHOW";
        if (upper.startsWith("DESCRIBE") || upper.startsWith("DESC ")) return "DESCRIBE";
        if (upper.startsWith("EXPLAIN")) return "EXPLAIN";
        if (upper.startsWith("INSERT")) return "INSERT";
        if (upper.startsWith("UPDATE")) return "UPDATE";
        if (upper.startsWith("DELETE")) return "DELETE";
        if (upper.startsWith("CREATE")) return "CREATE";
        if (upper.startsWith("ALTER")) return "ALTER";
        if (upper.startsWith("DROP")) return "DROP";
        if (upper.startsWith("TRUNCATE")) return "TRUNCATE";
        return "SQL";
    }

    private boolean isDestructiveOnPrimary(String sql, String stmtType) {
        if ("DROP".equals(stmtType) || "TRUNCATE".equals(stmtType) || "ALTER".equals(stmtType)) {
            return true;
        }
        Matcher m = CORE_TABLE_DDL.matcher(sql);
        if (m.find()) {
            return true;
        }
        String upper = sql.toUpperCase(Locale.ROOT);
        if (("DELETE".equals(stmtType) || "UPDATE".equals(stmtType)) && !upper.contains(" WHERE ")) {
            return true;
        }
        return false;
    }
}
