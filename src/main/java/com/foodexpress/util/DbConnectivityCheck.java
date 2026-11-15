package com.foodexpress.util;

import com.foodexpress.config.DBConnection;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

/**
 * Standalone CLI utility to verify live MySQL JDBC connectivity,
 * configuration resolution, database existence, and all 7 required FoodExpress tables.
 */
public class DbConnectivityCheck {

    private static final List<String> REQUIRED_TABLES = List.of(
        "Users", "Restaurants", "Admin", "Food_Items", "Orders", "Order_Items", "Payments"
    );

    public static void main(String[] args) {
        System.out.println("Config Summary : " + DBConnection.getLoadedConfigSummary());
        System.out.println("JDBC URL       : " + DBConnection.getJdbcUrl());

        try (Connection conn = DBConnection.getConnection()) {
            System.out.println("SUCCESS: Connected to MySQL database '" + DBConnection.getDatabaseName() + "'.");
            DatabaseMetaData meta = conn.getMetaData();
            System.out.println("Server: " + meta.getDatabaseProductName() + " " + meta.getDatabaseProductVersion());

            for (String table : REQUIRED_TABLES) {
                boolean exists = false;
                try (ResultSet rs = meta.getTables(DBConnection.getDatabaseName(), null, table, new String[]{"TABLE"})) {
                    exists = rs.next();
                }
                if (exists) {
                    try (Statement st = conn.createStatement();
                         ResultSet cntRs = st.executeQuery("SELECT COUNT(*) FROM `" + table + "`")) {
                        long count = cntRs.next() ? cntRs.getLong(1) : 0;
                        System.out.println("  [OK] Table " + table + " exists (" + count + " rows)");
                    }
                } else {
                    System.out.println("  [MISSING] Table " + table + " does NOT exist!");
                }
            }
        } catch (Exception e) {
            System.err.println("FAILED: " + e.getMessage());
            System.exit(1);
        }
    }
}
