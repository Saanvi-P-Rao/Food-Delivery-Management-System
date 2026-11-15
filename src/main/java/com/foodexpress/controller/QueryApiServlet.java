package com.foodexpress.controller;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.QueryResult;
import com.foodexpress.model.TableMetadata;
import com.foodexpress.model.VisualQueryRequest;
import com.foodexpress.service.DatabaseMetadataService;
import com.foodexpress.service.SqlExecutionService;
import com.foodexpress.service.SqlExecutionService.ExecutionMode;
import com.foodexpress.service.VisualQueryBuilder;
import com.foodexpress.util.JsonUtil;
import com.foodexpress.util.ValidationUtil;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {
    "/api/query/status",
    "/api/query/tables",
    "/api/query/columns",
    "/api/query/build",
    "/api/query/execute",
    "/api/query/history"
})
public class QueryApiServlet extends HttpServlet {

    private static final Gson GSON = new Gson();

    private final SqlExecutionService sqlService = new SqlExecutionService();
    private final DatabaseMetadataService metadataService = new DatabaseMetadataService();
    private final VisualQueryBuilder queryBuilder = new VisualQueryBuilder();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/api/query/status" -> {
                    boolean connected = DBConnection.testConnection();
                    String version = connected ? metadataService.getMySqlVersion() : null;
                    int tableCount = connected ? metadataService.getAllTablesMetadata(false).size() : 0;
                    Map<String, Object> payload = new LinkedHashMap<>();
                    payload.put("success", true);
                    payload.put("connected", connected);
                    payload.put("databaseName", DBConnection.getDatabaseName());
                    payload.put("mysqlVersion", version != null ? version : "N/A");
                    payload.put("tableCount", tableCount);
                    payload.put("lastError", DBConnection.getLastConnectionError());
                    JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, payload);
                }
                case "/api/query/tables" -> {
                    List<TableMetadata> tables = metadataService.getAllTablesMetadata(false);
                    JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, Map.of(
                        "success", true,
                        "databaseName", DBConnection.getDatabaseName(),
                        "connected", true,
                        "tables", tables
                    ));
                }
                case "/api/query/columns" -> {
                    String table = ValidationUtil.trimOrEmpty(req.getParameter("table"));
                    if (table.isEmpty()) {
                        JsonUtil.writeJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                            Map.of("success", false, "error", "Query parameter 'table' is required."));
                        return;
                    }
                    List<TableMetadata.ColumnInfo> columns = metadataService.getTableColumns(table);
                    if (columns.isEmpty()) {
                        JsonUtil.writeJson(resp, HttpServletResponse.SC_NOT_FOUND,
                            Map.of("success", false, "error", "Table '" + table + "' was not found in " + DBConnection.getDatabaseName() + "."));
                        return;
                    }
                    JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, Map.of(
                        "success", true,
                        "table", table,
                        "columns", columns
                    ));
                }
                case "/api/query/history" -> {
                    JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, Map.of(
                        "success", true,
                        "history", sqlService.getHistory()
                    ));
                }
                default -> JsonUtil.writeJson(resp, HttpServletResponse.SC_NOT_FOUND,
                    Map.of("success", false, "error", "Unknown endpoint"));
            }
        } catch (SQLException e) {
            JsonUtil.writeJson(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                Map.of("success", false, "connected", false, "error", e.getMessage()));
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/api/query/build" -> handleBuild(req, resp);
            case "/api/query/execute" -> handleExecute(req, resp);
            case "/api/query/history" -> {
                if ("clear".equalsIgnoreCase(req.getParameter("action"))) {
                    sqlService.clearHistory();
                    JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, Map.of("success", true));
                } else {
                    JsonUtil.writeJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                        Map.of("success", false, "error", "Unsupported action"));
                }
            }
            default -> JsonUtil.writeJson(resp, HttpServletResponse.SC_NOT_FOUND,
                Map.of("success", false, "error", "Unknown endpoint"));
        }
    }

    private void handleBuild(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String body = readBody(req);
            VisualQueryRequest vq = GSON.fromJson(body, VisualQueryRequest.class);
            Map<String, List<String>> schemaMap = metadataService.getSchemaColumnMap();
            String sql = queryBuilder.buildSql(vq, schemaMap);
            JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, Map.of(
                "success", true,
                "sql", sql
            ));
        } catch (IllegalArgumentException | JsonSyntaxException e) {
            JsonUtil.writeJson(resp, HttpServletResponse.SC_BAD_REQUEST,
                Map.of("success", false, "error", e.getMessage()));
        } catch (SQLException e) {
            JsonUtil.writeJson(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                Map.of("success", false, "error", e.getMessage()));
        }
    }

    private void handleExecute(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String contentType = req.getContentType();
        String sql = null;
        String source = "MANUAL";
        boolean confirmDestructive = false;

        if (contentType != null && contentType.toLowerCase().contains("application/json")) {
            try {
                String body = readBody(req);
                ExecutePayload payload = GSON.fromJson(body, ExecutePayload.class);
                if (payload != null) {
                    source = payload.source != null ? payload.source : "MANUAL";
                    confirmDestructive = payload.confirmDestructive;
                    if (payload.visualQuery != null) {
                        source = "VISUAL";
                        Map<String, List<String>> schemaMap = metadataService.getSchemaColumnMap();
                        sql = queryBuilder.buildSql(payload.visualQuery, schemaMap);
                    } else {
                        sql = payload.sql;
                    }
                }
            } catch (IllegalArgumentException | JsonSyntaxException e) {
                QueryResult err = new QueryResult();
                err.setSuccess(false);
                err.setSource(source);
                err.setDatabaseName(DBConnection.getDatabaseName());
                err.setErrorMessage(e.getMessage());
                JsonUtil.writeJson(resp, HttpServletResponse.SC_BAD_REQUEST, err);
                return;
            } catch (SQLException e) {
                QueryResult err = new QueryResult();
                err.setSuccess(false);
                err.setSource(source);
                err.setDatabaseName(DBConnection.getDatabaseName());
                err.setErrorMessage(e.getMessage());
                JsonUtil.writeJson(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, err);
                return;
            }
        } else {
            sql = req.getParameter("sql");
            String paramSource = req.getParameter("source");
            if (paramSource != null && !paramSource.isBlank()) {
                source = paramSource.trim().toUpperCase();
            }
            confirmDestructive = "true".equalsIgnoreCase(req.getParameter("confirmDestructive"));
        }

        QueryResult result = sqlService.executeQuery(sql, false, confirmDestructive, "web-user", source, ExecutionMode.LANDING_PUBLIC);
        int status = result.isSuccess() ? HttpServletResponse.SC_OK
                   : (result.isConfirmationRequired() ? HttpServletResponse.SC_CONFLICT : HttpServletResponse.SC_BAD_REQUEST);
        JsonUtil.writeJson(resp, status, result);
    }

    private String readBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line).append('\n');
            }
        }
        return sb.toString();
    }

    private static class ExecutePayload {
        String sql;
        String source;
        boolean confirmDestructive;
        VisualQueryRequest visualQuery;
    }
}
