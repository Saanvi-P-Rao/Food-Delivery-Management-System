package com.foodexpress.dao;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.OrderItem;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderItemDAO {

    private OrderItem mapRow(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();
        item.setOrderItemId(rs.getInt("order_item_id"));
        item.setOrderId(rs.getInt("order_id"));
        item.setFoodId(rs.getInt("food_id"));
        item.setFoodName(rs.getString("food_name"));
        item.setVeg(rs.getBoolean("is_veg"));
        item.setQuantity(rs.getInt("quantity"));
        item.setItemPrice(rs.getBigDecimal("item_price"));
        item.setSubtotal(rs.getBigDecimal("subtotal"));
        return item;
    }

    public void insertBatchWithConnection(Connection conn, List<OrderItem> items) throws SQLException {
        String sql = "INSERT INTO `ORDER_ITEMS` (order_id, food_id, quantity, item_price, subtotal) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            for (OrderItem item : items) {
                ps.setInt(1, item.getOrderId());
                ps.setInt(2, item.getFoodId());
                ps.setInt(3, item.getQuantity());
                ps.setBigDecimal(4, item.getItemPrice());
                ps.setBigDecimal(5, item.getSubtotal());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    public List<OrderItem> findByOrderId(int orderId) throws SQLException {
        String sql = "SELECT oi.*, f.name AS food_name, f.is_veg FROM `ORDER_ITEMS` oi " +
                     "JOIN `FOOD_ITEMS` f ON oi.food_id = f.food_id WHERE oi.order_id = ? ORDER BY oi.order_item_id ASC";
        List<OrderItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<OrderItem> findAll() throws SQLException {
        String sql = "SELECT oi.*, f.name AS food_name, f.is_veg FROM `ORDER_ITEMS` oi " +
                     "JOIN `FOOD_ITEMS` f ON oi.food_id = f.food_id ORDER BY oi.order_item_id DESC LIMIT 250";
        List<OrderItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }
}
