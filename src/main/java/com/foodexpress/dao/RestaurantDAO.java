package com.foodexpress.dao;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.Restaurant;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RestaurantDAO {

    private Restaurant mapRow(ResultSet rs) throws SQLException {
        Restaurant r = new Restaurant();
        r.setRestaurantId(rs.getInt("restaurant_id"));
        r.setName(rs.getString("name"));
        r.setEmail(rs.getString("email"));
        r.setPhone(rs.getString("phone"));
        r.setPasswordHash(rs.getString("password_hash"));
        r.setCuisineType(rs.getString("cuisine_type"));
        r.setDescription(rs.getString("description"));
        r.setAddress(rs.getString("address"));
        r.setCity(rs.getString("city"));
        r.setRating(rs.getBigDecimal("rating"));
        r.setDeliveryTimeMins(rs.getInt("delivery_time_mins"));
        r.setImageUrl(rs.getString("image_url"));
        r.setActive(rs.getBoolean("is_active"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }

    public Restaurant findById(int restaurantId) throws SQLException {
        String sql = "SELECT r.*, (SELECT COUNT(*) FROM `Food_Items` f WHERE f.restaurant_id = r.restaurant_id) AS item_count " +
                     "FROM `Restaurants` r WHERE r.restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Restaurant r = mapRow(rs);
                    r.setFoodItemCount(rs.getInt("item_count"));
                    return r;
                }
            }
        }
        return null;
    }

    public Restaurant findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM `Restaurants` WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<Restaurant> findAll() throws SQLException {
        String sql = "SELECT r.*, (SELECT COUNT(*) FROM `Food_Items` f WHERE f.restaurant_id = r.restaurant_id) AS item_count " +
                     "FROM `Restaurants` r ORDER BY r.restaurant_id DESC";
        List<Restaurant> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Restaurant r = mapRow(rs);
                r.setFoodItemCount(rs.getInt("item_count"));
                list.add(r);
            }
        }
        return list;
    }

    public List<Restaurant> findActive(String search, String city, String cuisine) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT r.*, (SELECT COUNT(*) FROM `Food_Items` f WHERE f.restaurant_id = r.restaurant_id AND f.is_available = TRUE) AS item_count " +
            "FROM `Restaurants` r WHERE r.is_active = TRUE"
        );
        List<Object> params = new ArrayList<>();
        if (search != null && !search.isBlank()) {
            sb.append(" AND (LOWER(r.name) LIKE ? OR LOWER(r.cuisine_type) LIKE ? OR LOWER(r.city) LIKE ?)");
            String like = "%" + search.trim().toLowerCase() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (city != null && !city.isBlank()) {
            sb.append(" AND r.city = ?");
            params.add(city.trim());
        }
        if (cuisine != null && !cuisine.isBlank()) {
            sb.append(" AND r.cuisine_type = ?");
            params.add(cuisine.trim());
        }
        sb.append(" ORDER BY r.rating DESC, r.name ASC");

        List<Restaurant> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sb.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Restaurant r = mapRow(rs);
                    r.setFoodItemCount(rs.getInt("item_count"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public List<String> findAllCities() throws SQLException {
        String sql = "SELECT DISTINCT city FROM `Restaurants` WHERE is_active = TRUE ORDER BY city ASC";
        List<String> cities = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                cities.add(rs.getString("city"));
            }
        }
        return cities;
    }

    public List<String> findAllCuisines() throws SQLException {
        String sql = "SELECT DISTINCT cuisine_type FROM `Restaurants` WHERE is_active = TRUE ORDER BY cuisine_type ASC";
        List<String> cuisines = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                cuisines.add(rs.getString("cuisine_type"));
            }
        }
        return cuisines;
    }

    public int create(Restaurant r) throws SQLException {
        String sql = "INSERT INTO `Restaurants` (name, email, phone, password_hash, cuisine_type, description, address, city, rating, delivery_time_mins, image_url, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, r.getName());
            ps.setString(2, r.getEmail());
            ps.setString(3, r.getPhone());
            ps.setString(4, r.getPasswordHash());
            ps.setString(5, r.getCuisineType());
            ps.setString(6, r.getDescription());
            ps.setString(7, r.getAddress());
            ps.setString(8, r.getCity());
            ps.setBigDecimal(9, r.getRating());
            ps.setInt(10, r.getDeliveryTimeMins());
            ps.setString(11, r.getImageUrl());
            ps.setBoolean(12, r.isActive());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    r.setRestaurantId(id);
                    return id;
                }
            }
        }
        return 0;
    }

    public boolean update(Restaurant r) throws SQLException {
        String sql = "UPDATE `Restaurants` SET name = ?, email = ?, phone = ?, cuisine_type = ?, description = ?, address = ?, city = ?, rating = ?, delivery_time_mins = ?, image_url = ?, is_active = ? WHERE restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, r.getName());
            ps.setString(2, r.getEmail());
            ps.setString(3, r.getPhone());
            ps.setString(4, r.getCuisineType());
            ps.setString(5, r.getDescription());
            ps.setString(6, r.getAddress());
            ps.setString(7, r.getCity());
            ps.setBigDecimal(8, r.getRating());
            ps.setInt(9, r.getDeliveryTimeMins());
            ps.setString(10, r.getImageUrl());
            ps.setBoolean(11, r.isActive());
            ps.setInt(12, r.getRestaurantId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int restaurantId) throws SQLException {
        String sql = "DELETE FROM `Restaurants` WHERE restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            return ps.executeUpdate() > 0;
        }
    }
}
