package com.foodexpress.controller;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.TableMetadata;
import com.foodexpress.service.DatabaseMetadataService;
import com.foodexpress.service.SqlExecutionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/home", ""})
public class HomeServlet extends HttpServlet {

    private final DatabaseMetadataService metadataService = new DatabaseMetadataService();
    private final SqlExecutionService sqlService = new SqlExecutionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        boolean connected = DBConnection.testConnection();
        req.setAttribute("dbConnected", connected);
        req.setAttribute("dbName", DBConnection.getDatabaseName());

        if (connected) {
            try {
                List<TableMetadata> tables = metadataService.getAllTablesMetadata(false);
                req.setAttribute("tables", tables);
                req.setAttribute("mysqlVersion", metadataService.getMySqlVersion());
            } catch (SQLException e) {
                req.setAttribute("dbError", "Unable to load metadata from MySQL: " + e.getMessage());
                req.setAttribute("tables", List.of());
            }
        } else {
            req.setAttribute("dbError", "Unable to connect to MySQL (" + DBConnection.getLastConnectionError() + ")");
            req.setAttribute("tables", List.of());
        }

        req.setAttribute("history", sqlService.getHistory());
        req.getRequestDispatcher("/WEB-INF/jsp/index.jsp").forward(req, resp);
    }
}
