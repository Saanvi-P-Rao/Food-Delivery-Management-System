package com.foodexpress.config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Logs safe database configuration diagnostics and connectivity status on Tomcat startup.
 * Never logs actual database passwords.
 */
@WebListener
public class AppInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[FoodExpress] DB Config: " + DBConnection.getLoadedConfigSummary());
        System.out.println("[FoodExpress] JDBC URL: " + DBConnection.getJdbcUrl());

        boolean ok = DBConnection.testConnection();
        sce.getServletContext().setAttribute("dbConnected", ok);
        if (ok) {
            System.out.println("[FoodExpress] Successfully connected to MySQL database: " + DBConnection.getDatabaseName());
        } else {
            System.err.println("[FoodExpress] WARNING: MySQL connection failed (" + DBConnection.getLastConnectionError() + ")");
        }
    }
}
