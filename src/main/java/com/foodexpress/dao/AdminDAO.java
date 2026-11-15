package com.foodexpress.dao;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.Admin;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    private Admin mapRow(ResultSet rs) throws SQLException {
        Admin a = new Admin();
        a.setAdminId(rs.getInt("admin_id"));
        a.setUsername(rs.getString("username"));
        a.setFullName(rs.getString("full_name"));
        a.setEmail(rs.getString("email"));
        a.setPasswordHash(rs.getString("password_hash"));
        a.setRole(rs.getString("role"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        return a;
    }

    public Admin findByUsernameOrEmail(String identifier) throws SQLException {
        String sql = "SELECT * FROM `ADMIN` WHERE username = ? OR email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public Admin findById(int adminId) throws SQLException {
        String sql = "SELECT * FROM `ADMIN` WHERE admin_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<Admin> findAll() throws SQLException {
        String sql = "SELECT * FROM `ADMIN` ORDER BY admin_id ASC";
        List<Admin> list = new ArrayList<>();
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
