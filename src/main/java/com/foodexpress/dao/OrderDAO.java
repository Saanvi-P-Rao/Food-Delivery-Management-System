package com.foodexpress.dao;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.Order;
import com.foodexpress.model.Payment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));
        o.setUserId(rs.getInt("user_id"));
        o.setRestaurantId(rs.getInt("restaurant_id"));
        o.setCustomerName(rs.getString("customer_name"));
        o.setCustomerPhone(rs.getString("customer_phone"));
        o.setRestaurantName(rs.getString("restaurant_name"));
        o.setOrderStatus(rs.getString("order_status"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setDeliveryAddress(rs.getString("delivery_address"));
        o.setSpecialInstructions(rs.getString("special_instructions"));
        o.setOrderDate(rs.getTimestamp("order_date"));
        o.setUpdatedAt(rs.getTimestamp("updated_at"));
        return o;
    }

    public int createWithConnection(Connection conn, Order order) throws SQLException {
        String sql = "INSERT INTO `Orders` (user_id, restaurant_id, order_status, total_amount, delivery_address, special_instructions) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, order.getUserId());
            ps.setInt(2, order.getRestaurantId());
            ps.setString(3, order.getOrderStatus());
            ps.setBigDecimal(4, order.getTotalAmount());
            ps.setString(5, order.getDeliveryAddress());
            ps.setString(6, order.getSpecialInstructions());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    order.setOrderId(id);
                    return id;
                }
            }
        }
        throw new SQLException("Creating order failed, no ID obtained.");
    }

    public Order findById(int orderId) throws SQLException {
        String sql = "SELECT o.*, u.full_name AS customer_name, u.phone AS customer_phone, r.name AS restaurant_name " +
                     "FROM `Orders` o " +
                     "JOIN `Users` u ON o.user_id = u.user_id " +
                     "JOIN `Restaurants` r ON o.restaurant_id = r.restaurant_id " +
                     "WHERE o.order_id = ?";
        OrderItemDAO itemDAO = new OrderItemDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = mapRow(rs);
                    o.setItems(itemDAO.findByOrderId(orderId));
                    o.setPayment(paymentDAO.findByOrderId(orderId));
                    return o;
                }
            }
        }
        return null;
    }

    public List<Order> findByUserId(int userId) throws SQLException {
        String sql = "SELECT o.*, u.full_name AS customer_name, u.phone AS customer_phone, r.name AS restaurant_name " +
                     "FROM `Orders` o " +
                     "JOIN `Users` u ON o.user_id = u.user_id " +
                     "JOIN `Restaurants` r ON o.restaurant_id = r.restaurant_id " +
                     "WHERE o.user_id = ? ORDER BY o.order_date DESC, o.order_id DESC";
        List<Order> list = new ArrayList<>();
        OrderItemDAO itemDAO = new OrderItemDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setItems(itemDAO.findByOrderId(o.getOrderId()));
                    o.setPayment(paymentDAO.findByOrderId(o.getOrderId()));
                    list.add(o);
                }
            }
        }
        return list;
    }

    public List<Order> findByRestaurantId(int restaurantId) throws SQLException {
        String sql = "SELECT o.*, u.full_name AS customer_name, u.phone AS customer_phone, r.name AS restaurant_name " +
                     "FROM `Orders` o " +
                     "JOIN `Users` u ON o.user_id = u.user_id " +
                     "JOIN `Restaurants` r ON o.restaurant_id = r.restaurant_id " +
                     "WHERE o.restaurant_id = ? ORDER BY o.order_date DESC, o.order_id DESC";
        List<Order> list = new ArrayList<>();
        OrderItemDAO itemDAO = new OrderItemDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setItems(itemDAO.findByOrderId(o.getOrderId()));
                    o.setPayment(paymentDAO.findByOrderId(o.getOrderId()));
                    list.add(o);
                }
            }
        }
        return list;
    }

    public List<Order> findAll() throws SQLException {
        String sql = "SELECT o.*, u.full_name AS customer_name, u.phone AS customer_phone, r.name AS restaurant_name " +
                     "FROM `Orders` o " +
                     "JOIN `Users` u ON o.user_id = u.user_id " +
                     "JOIN `Restaurants` r ON o.restaurant_id = r.restaurant_id " +
                     "ORDER BY o.order_date DESC, o.order_id DESC";
        List<Order> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public boolean updateStatus(int orderId, String newStatus) throws SQLException {
        String sql = "UPDATE `Orders` SET order_status = ? WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatusForRestaurant(int orderId, int restaurantId, String newStatus) throws SQLException {
        String sql = "UPDATE `Orders` SET order_status = ? WHERE order_id = ? AND restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            ps.setInt(3, restaurantId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int orderId) throws SQLException {
        String sql = "DELETE FROM `Orders` WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        }
    }
}
