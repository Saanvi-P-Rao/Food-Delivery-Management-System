package com.foodexpress.dao;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.Payment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {

    private Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPaymentId(rs.getInt("payment_id"));
        p.setOrderId(rs.getInt("order_id"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setPaymentStatus(rs.getString("payment_status"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setTransactionRef(rs.getString("transaction_ref"));
        p.setPaymentDate(rs.getTimestamp("payment_date"));
        return p;
    }

    public int insertWithConnection(Connection conn, Payment payment) throws SQLException {
        String sql = "INSERT INTO `Payments` (order_id, payment_method, payment_status, amount, transaction_ref) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, payment.getOrderId());
            ps.setString(2, payment.getPaymentMethod());
            ps.setString(3, payment.getPaymentStatus());
            ps.setBigDecimal(4, payment.getAmount());
            ps.setString(5, payment.getTransactionRef());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    payment.setPaymentId(id);
                    return id;
                }
            }
        }
        throw new SQLException("Creating Payments failed, no ID obtained.");
    }

    public Payment findByOrderId(int orderId) throws SQLException {
        String sql = "SELECT * FROM `Payments` WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<Payment> findAll() throws SQLException {
        String sql = "SELECT * FROM `Payments` ORDER BY payment_date DESC, payment_id DESC";
        List<Payment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public boolean updateStatus(int paymentId, String status) throws SQLException {
        String sql = "UPDATE `Payments` SET payment_status = ? WHERE payment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, paymentId);
            return ps.executeUpdate() > 0;
        }
    }
}
