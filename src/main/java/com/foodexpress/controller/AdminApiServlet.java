package com.foodexpress.controller;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.Admin;
import com.foodexpress.model.QueryResult;
import com.foodexpress.model.TableMetadata;
import com.foodexpress.service.DatabaseMetadataService;
import com.foodexpress.service.SqlExecutionService;
import com.foodexpress.util.JsonUtil;
import com.foodexpress.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {
    "/api/admin/sql/execute",
    "/api/admin/sql/history",
    "/api/admin/explorer/tables",
    "/api/admin/explorer/preview"
})
public class AdminApiServlet extends HttpServlet {

    private final SqlExecutionService sqlService = new SqlExecutionService();
    private final DatabaseMetadataService metadataService = new DatabaseMetadataService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        boolean useSandbox = "true".equalsIgnoreCase(req.getParameter("sandbox"));

        try {
            switch (path) {
                case "/api/admin/sql/history" -> {
                    JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, Map.of(
                        "success", true,
                        "history", sqlService.getHistory()
                    ));
                }
                case "/api/admin/explorer/tables" -> {
                    List<TableMetadata> tables = metadataService.getAllTablesMetadata(useSandbox);
                    JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, Map.of(
                        "success", true,
                        "databaseName", useSandbox ? DBConnection.getSandboxDatabaseName() : DBConnection.getDatabaseName(),
                        "connected", DBConnection.testConnection(),
                        "tables", tables
                    ));
                }
                case "/api/admin/explorer/preview" -> {
                    String table = ValidationUtil.trimOrEmpty(req.getParameter("table"));
                    int limit = ValidationUtil.parsePositiveInt(req.getParameter("limit"), 100);
                    QueryResult res = metadataService.previewTableRecords(table, useSandbox, limit);
                    JsonUtil.writeJson(resp, res.isSuccess() ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST, res);
                }
                default -> JsonUtil.writeJson(resp, HttpServletResponse.SC_NOT_FOUND, Map.of("success", false, "error", "Unknown endpoint"));
            }
        } catch (SQLException e) {
            JsonUtil.writeJson(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                Map.of("success", false, "error", e.getMessage()));
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/api/admin/sql/execute".equals(path)) {
            HttpSession session = req.getSession(false);
            Admin admin = session != null ? (Admin) session.getAttribute("loggedAdmin") : null;
            String username = admin != null ? admin.getUsername() : "admin";

            String sql = req.getParameter("sql");
            boolean useSandbox = "true".equalsIgnoreCase(req.getParameter("sandbox"));
            boolean confirmDestructive = "true".equalsIgnoreCase(req.getParameter("confirmDestructive"));

            QueryResult result = sqlService.executeQuery(sql, useSandbox, confirmDestructive, username);
            int status = result.isSuccess() ? HttpServletResponse.SC_OK
                       : (result.isConfirmationRequired() ? HttpServletResponse.SC_CONFLICT : HttpServletResponse.SC_BAD_REQUEST);
            JsonUtil.writeJson(resp, status, result);
            return;
        }

        if ("/api/admin/sql/history".equals(path) && "clear".equalsIgnoreCase(req.getParameter("action"))) {
            sqlService.clearHistory();
            JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, Map.of("success", true));
            return;
        }

        JsonUtil.writeJson(resp, HttpServletResponse.SC_NOT_FOUND, Map.of("success", false, "error", "Unknown endpoint"));
    }
}
