package com.foodexpress.dao;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.DashboardStats;
import com.foodexpress.model.Order;
import com.foodexpress.model.Payment;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO {

    public DashboardStats getAdminStats() throws SQLException {
        DashboardStats stats = new DashboardStats();
        try (Connection conn = DBConnection.getConnection()) {
            stats.setTotalUsers(queryCount(conn, "SELECT COUNT(*) FROM `Users`"));
            stats.setTotalRestaurants(queryCount(conn, "SELECT COUNT(*) FROM `Restaurants`"));
            stats.setTotalFoodItems(queryCount(conn, "SELECT COUNT(*) FROM `Food_Items`"));
            stats.setTotalOrders(queryCount(conn, "SELECT COUNT(*) FROM `Orders`"));
            stats.setPendingOrders(queryCount(conn, "SELECT COUNT(*) FROM `Orders` WHERE order_status IN ('PLACED','CONFIRMED','PREPARING','OUT_FOR_DELIVERY')"));
            stats.setCompletedOrders(queryCount(conn, "SELECT COUNT(*) FROM `Orders` WHERE order_status = 'DELIVERED'"));
            stats.setCancelledOrders(queryCount(conn, "SELECT COUNT(*) FROM `Orders` WHERE order_status = 'CANCELLED'"));

            String revSql = "SELECT COALESCE(SUM(amount), 0.00) FROM `Payments` WHERE payment_status = 'SUCCESS'";
            try (PreparedStatement ps = conn.prepareStatement(revSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal rev = rs.getBigDecimal(1);
                    stats.setTotalRevenue(rev != null ? rev : BigDecimal.ZERO);
                }
            }

            String paySql = "SELECT * FROM `Payments` ORDER BY payment_date DESC, payment_id DESC LIMIT 8";
            List<Payment> payments = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(paySql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payment p = new Payment();
                    p.setPaymentId(rs.getInt("payment_id"));
                    p.setOrderId(rs.getInt("order_id"));
                    p.setPaymentMethod(rs.getString("payment_method"));
                    p.setPaymentStatus(rs.getString("payment_status"));
                    p.setAmount(rs.getBigDecimal("amount"));
                    p.setTransactionRef(rs.getString("transaction_ref"));
                    p.setPaymentDate(rs.getTimestamp("payment_date"));
                    payments.add(p);
                }
            }
            stats.setRecentPayments(payments);

            String ordSql = "SELECT o.*, u.full_name AS customer_name, u.phone AS customer_phone, r.name AS restaurant_name " +
                            "FROM `Orders` o JOIN `Users` u ON o.user_id = u.user_id " +
                            "JOIN `Restaurants` r ON o.restaurant_id = r.restaurant_id " +
                            "ORDER BY o.order_date DESC, o.order_id DESC LIMIT 8";
            List<Order> orders = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(ordSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("order_id"));
                    o.setUserId(rs.getInt("user_id"));
                    o.setRestaurantId(rs.getInt("restaurant_id"));
                    o.setCustomerName(rs.getString("customer_name"));
                    o.setCustomerPhone(rs.getString("customer_phone"));
                    o.setRestaurantName(rs.getString("restaurant_name"));
                    o.setOrderStatus(rs.getString("order_status"));
                    o.setTotalAmount(rs.getBigDecimal("total_amount"));
                    o.setOrderDate(rs.getTimestamp("order_date"));
                    orders.add(o);
                }
            }
            stats.setRecentOrders(orders);
        }
        return stats;
    }

    public DashboardStats getRestaurantStats(int restaurantId) throws SQLException {
        DashboardStats stats = new DashboardStats();
        try (Connection conn = DBConnection.getConnection()) {
            stats.setTotalFoodItems(queryCountWithInt(conn, "SELECT COUNT(*) FROM `Food_Items` WHERE restaurant_id = ?", restaurantId));
            stats.setTotalOrders(queryCountWithInt(conn, "SELECT COUNT(*) FROM `Orders` WHERE restaurant_id = ?", restaurantId));
            stats.setPendingOrders(queryCountWithInt(conn, "SELECT COUNT(*) FROM `Orders` WHERE restaurant_id = ? AND order_status IN ('PLACED','CONFIRMED','PREPARING','OUT_FOR_DELIVERY')", restaurantId));
            stats.setCompletedOrders(queryCountWithInt(conn, "SELECT COUNT(*) FROM `Orders` WHERE restaurant_id = ? AND order_status = 'DELIVERED'", restaurantId));

            String revSql = "SELECT COALESCE(SUM(total_amount), 0.00) FROM `Orders` WHERE restaurant_id = ? AND order_status <> 'CANCELLED'";
            try (PreparedStatement ps = conn.prepareStatement(revSql)) {
                ps.setInt(1, restaurantId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats.setTotalRevenue(rs.getBigDecimal(1));
                    }
                }
            }
        }
        return stats;
    }

    private int queryCount(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private int queryCountWithInt(Connection conn, String sql, int param) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
