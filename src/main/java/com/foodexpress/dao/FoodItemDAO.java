package com.foodexpress.dao;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.FoodItem;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FoodItemDAO {

    private FoodItem mapRow(ResultSet rs) throws SQLException {
        FoodItem f = new FoodItem();
        f.setFoodId(rs.getInt("food_id"));
        f.setRestaurantId(rs.getInt("restaurant_id"));
        f.setRestaurantName(rs.getString("restaurant_name"));
        f.setName(rs.getString("name"));
        f.setDescription(rs.getString("description"));
        f.setCategory(rs.getString("category"));
        f.setPrice(rs.getBigDecimal("price"));
        f.setVeg(rs.getBoolean("is_veg"));
        f.setAvailable(rs.getBoolean("is_available"));
        f.setImageUrl(rs.getString("image_url"));
        f.setCreatedAt(rs.getTimestamp("created_at"));
        return f;
    }

    public FoodItem findById(int foodId) throws SQLException {
        String sql = "SELECT f.*, r.name AS restaurant_name FROM `Food_Items` f " +
                     "JOIN `Restaurants` r ON f.restaurant_id = r.restaurant_id WHERE f.food_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, foodId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public List<FoodItem> findByRestaurantId(int restaurantId, boolean onlyAvailable) throws SQLException {
        String sql = "SELECT f.*, r.name AS restaurant_name FROM `Food_Items` f " +
                     "JOIN `Restaurants` r ON f.restaurant_id = r.restaurant_id " +
                     "WHERE f.restaurant_id = ? " + (onlyAvailable ? "AND f.is_available = TRUE " : "") +
                     "ORDER BY f.category ASC, f.name ASC";
        List<FoodItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<FoodItem> findAll() throws SQLException {
        String sql = "SELECT f.*, r.name AS restaurant_name FROM `Food_Items` f " +
                     "JOIN `Restaurants` r ON f.restaurant_id = r.restaurant_id ORDER BY f.food_id DESC";
        List<FoodItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public List<FoodItem> searchAndFilter(String search, String category, Boolean isVeg,
                                          Integer restaurantId, BigDecimal maxPrice, String sortBy) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT f.*, r.name AS restaurant_name FROM `Food_Items` f " +
            "JOIN `Restaurants` r ON f.restaurant_id = r.restaurant_id " +
            "WHERE r.is_active = TRUE AND f.is_available = TRUE"
        );
        List<Object> params = new ArrayList<>();
        if (search != null && !search.isBlank()) {
            sb.append(" AND (LOWER(f.name) LIKE ? OR LOWER(f.description) LIKE ? OR LOWER(r.name) LIKE ? OR LOWER(f.category) LIKE ?)");
            String like = "%" + search.trim().toLowerCase() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (category != null && !category.isBlank()) {
            sb.append(" AND f.category = ?");
            params.add(category.trim());
        }
        if (isVeg != null) {
            sb.append(" AND f.is_veg = ?");
            params.add(isVeg);
        }
        if (restaurantId != null && restaurantId > 0) {
            sb.append(" AND f.restaurant_id = ?");
            params.add(restaurantId);
        }
        if (maxPrice != null && maxPrice.compareTo(BigDecimal.ZERO) > 0) {
            sb.append(" AND f.price <= ?");
            params.add(maxPrice);
        }

        if ("price_asc".equals(sortBy)) {
            sb.append(" ORDER BY f.price ASC");
        } else if ("price_desc".equals(sortBy)) {
            sb.append(" ORDER BY f.price DESC");
        } else {
            sb.append(" ORDER BY r.rating DESC, f.name ASC");
        }

        List<FoodItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sb.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<String> findAllCategories() throws SQLException {
        String sql = "SELECT DISTINCT category FROM `Food_Items` ORDER BY category ASC";
        List<String> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("category"));
            }
        }
        return list;
    }

    public int create(FoodItem f) throws SQLException {
        String sql = "INSERT INTO `Food_Items` (restaurant_id, name, description, category, price, is_veg, is_available, image_url) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, f.getRestaurantId());
            ps.setString(2, f.getName());
            ps.setString(3, f.getDescription());
            ps.setString(4, f.getCategory());
            ps.setBigDecimal(5, f.getPrice());
            ps.setBoolean(6, f.isVeg());
            ps.setBoolean(7, f.isAvailable());
            ps.setString(8, f.getImageUrl());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    f.setFoodId(id);
                    return id;
                }
            }
        }
        return 0;
    }

    public boolean update(FoodItem f) throws SQLException {
        String sql = "UPDATE `Food_Items` SET restaurant_id = ?, name = ?, description = ?, category = ?, price = ?, is_veg = ?, is_available = ?, image_url = ? WHERE food_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, f.getRestaurantId());
            ps.setString(2, f.getName());
            ps.setString(3, f.getDescription());
            ps.setString(4, f.getCategory());
            ps.setBigDecimal(5, f.getPrice());
            ps.setBoolean(6, f.isVeg());
            ps.setBoolean(7, f.isAvailable());
            ps.setString(8, f.getImageUrl());
            ps.setInt(9, f.getFoodId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean toggleAvailability(int foodId, int restaurantId, boolean available) throws SQLException {
        String sql = "UPDATE `Food_Items` SET is_available = ? WHERE food_id = ? AND restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, available);
            ps.setInt(2, foodId);
            ps.setInt(3, restaurantId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int foodId) throws SQLException {
        String sql = "DELETE FROM `Food_Items` WHERE food_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, foodId);
            return ps.executeUpdate() > 0;
        }
    }
}
