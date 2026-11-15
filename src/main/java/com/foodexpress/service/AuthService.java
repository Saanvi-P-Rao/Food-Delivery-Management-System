package com.foodexpress.service;

import com.foodexpress.dao.AdminDAO;
import com.foodexpress.dao.RestaurantDAO;
import com.foodexpress.dao.UserDAO;
import com.foodexpress.model.Admin;
import com.foodexpress.model.Restaurant;
import com.foodexpress.model.User;
import com.foodexpress.util.PasswordUtil;
import com.foodexpress.util.ValidationUtil;
import java.sql.SQLException;

public class AuthService {

    private final UserDAO userDAO = new UserDAO();
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private final AdminDAO adminDAO = new AdminDAO();

    public User loginCustomer(String email, String rawPassword) throws SQLException {
        if (ValidationUtil.isBlank(email) || ValidationUtil.isBlank(rawPassword)) {
            return null;
        }
        User user = userDAO.findByEmail(email.trim());
        if (user != null && PasswordUtil.verifyPassword(rawPassword, user.getPasswordHash())) {
            return user;
        }
        return null;
    }

    public User registerCustomer(User user, String rawPassword) throws SQLException {
        if (userDAO.findByEmail(user.getEmail().trim()) != null) {
            throw new IllegalArgumentException("An account with this email already exists.");
        }
        user.setPasswordHash(PasswordUtil.hashPassword(rawPassword));
        userDAO.create(user);
        return user;
    }

    public Restaurant loginRestaurant(String email, String rawPassword) throws SQLException {
        if (ValidationUtil.isBlank(email) || ValidationUtil.isBlank(rawPassword)) {
            return null;
        }
        Restaurant restaurant = restaurantDAO.findByEmail(email.trim());
        if (restaurant != null && PasswordUtil.verifyPassword(rawPassword, restaurant.getPasswordHash())) {
            return restaurant;
        }
        return null;
    }

    public Admin loginAdmin(String identifier, String rawPassword) throws SQLException {
        if (ValidationUtil.isBlank(identifier) || ValidationUtil.isBlank(rawPassword)) {
            return null;
        }
        Admin admin = adminDAO.findByUsernameOrEmail(identifier.trim());
        if (admin != null && PasswordUtil.verifyPassword(rawPassword, admin.getPasswordHash())) {
            return admin;
        }
        return null;
    }
}
