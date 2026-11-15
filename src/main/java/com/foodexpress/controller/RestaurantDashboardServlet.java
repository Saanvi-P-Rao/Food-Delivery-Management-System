package com.foodexpress.controller;

import com.foodexpress.dao.DashboardDAO;
import com.foodexpress.dao.FoodItemDAO;
import com.foodexpress.dao.OrderDAO;
import com.foodexpress.dao.RestaurantDAO;
import com.foodexpress.model.FoodItem;
import com.foodexpress.model.Order;
import com.foodexpress.model.Restaurant;
import com.foodexpress.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/restaurant/dashboard", "/restaurant/foods", "/restaurant/orders", "/restaurant/profile"})
public class RestaurantDashboardServlet extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Restaurant r = session != null ? (Restaurant) session.getAttribute("loggedRestaurant") : null;
        if (r == null) {
            resp.sendRedirect(req.getContextPath() + "/restaurant/login");
            return;
        }

        String path = req.getServletPath();
        String tab = switch (path) {
            case "/restaurant/foods" -> "foods";
            case "/restaurant/orders" -> "orders";
            case "/restaurant/profile" -> "profile";
            default -> "overview";
        };
        req.setAttribute("activeTab", tab);

        try {
            Restaurant fresh = restaurantDAO.findById(r.getRestaurantId());
            if (fresh != null) {
                session.setAttribute("loggedRestaurant", fresh);
                r = fresh;
            }
            req.setAttribute("stats", dashboardDAO.getRestaurantStats(r.getRestaurantId()));
            List<FoodItem> foods = foodItemDAO.findByRestaurantId(r.getRestaurantId(), false);
            List<Order> orders = orderDAO.findByRestaurantId(r.getRestaurantId());
            req.setAttribute("foods", foods);
            req.setAttribute("orders", orders);
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }

        req.getRequestDispatcher("/WEB-INF/jsp/restaurant/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Restaurant r = session != null ? (Restaurant) session.getAttribute("loggedRestaurant") : null;
        if (r == null) {
            resp.sendRedirect(req.getContextPath() + "/restaurant/login");
            return;
        }

        String action = ValidationUtil.trimOrEmpty(req.getParameter("action"));
        try {
            switch (action) {
                case "addFood" -> {
                    FoodItem f = new FoodItem();
                    f.setRestaurantId(r.getRestaurantId());
                    f.setName(ValidationUtil.trimOrEmpty(req.getParameter("name")));
                    f.setDescription(ValidationUtil.trimOrEmpty(req.getParameter("description")));
                    f.setCategory(ValidationUtil.trimOrEmpty(req.getParameter("category")));
                    BigDecimal price = ValidationUtil.parsePositiveDecimal(req.getParameter("price"));
                    if (ValidationUtil.isBlank(f.getName()) || price == null) {
                        req.setAttribute("error", "Valid food name and positive price are required.");
                    } else {
                        f.setPrice(price);
                        f.setVeg("true".equalsIgnoreCase(req.getParameter("isVeg")));
                        f.setAvailable(true);
                        String img = ValidationUtil.trimOrEmpty(req.getParameter("imageUrl"));
                        f.setImageUrl(img.isEmpty() ? "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80" : img);
                        foodItemDAO.create(f);
                        req.setAttribute("success", "Food item added to menu.");
                    }
                }
                case "editFood" -> {
                    int foodId = ValidationUtil.parsePositiveInt(req.getParameter("foodId"), -1);
                    FoodItem existing = foodItemDAO.findById(foodId);
                    if (existing != null && existing.getRestaurantId() == r.getRestaurantId()) {
                        BigDecimal price = ValidationUtil.parsePositiveDecimal(req.getParameter("price"));
                        existing.setName(ValidationUtil.trimOrEmpty(req.getParameter("name")));
                        existing.setDescription(ValidationUtil.trimOrEmpty(req.getParameter("description")));
                        existing.setCategory(ValidationUtil.trimOrEmpty(req.getParameter("category")));
                        if (price != null) existing.setPrice(price);
                        existing.setVeg("true".equalsIgnoreCase(req.getParameter("isVeg")));
                        existing.setAvailable("true".equalsIgnoreCase(req.getParameter("isAvailable")));
                        String img = ValidationUtil.trimOrEmpty(req.getParameter("imageUrl"));
                        if (!img.isEmpty()) existing.setImageUrl(img);
                        foodItemDAO.update(existing);
                        req.setAttribute("success", "Food item updated.");
                    }
                }
                case "toggleAvailability" -> {
                    int foodId = ValidationUtil.parsePositiveInt(req.getParameter("foodId"), -1);
                    boolean avail = "true".equalsIgnoreCase(req.getParameter("available"));
                    foodItemDAO.toggleAvailability(foodId, r.getRestaurantId(), avail);
                    req.setAttribute("success", "Availability updated.");
                }
                case "deleteFood" -> {
                    int foodId = ValidationUtil.parsePositiveInt(req.getParameter("foodId"), -1);
                    FoodItem existing = foodItemDAO.findById(foodId);
                    if (existing != null && existing.getRestaurantId() == r.getRestaurantId()) {
                        foodItemDAO.delete(foodId);
                        req.setAttribute("success", "Food item deleted.");
                    }
                }
                case "updateOrderStatus" -> {
                    int orderId = ValidationUtil.parsePositiveInt(req.getParameter("orderId"), -1);
                    String status = ValidationUtil.trimOrEmpty(req.getParameter("orderStatus"));
                    orderDAO.updateStatusForRestaurant(orderId, r.getRestaurantId(), status);
                    req.setAttribute("success", "Order #" + orderId + " status updated to " + status + ".");
                }
                case "updateProfile" -> {
                    r.setName(ValidationUtil.trimOrEmpty(req.getParameter("name")));
                    r.setPhone(ValidationUtil.trimOrEmpty(req.getParameter("phone")));
                    r.setCuisineType(ValidationUtil.trimOrEmpty(req.getParameter("cuisineType")));
                    r.setDescription(ValidationUtil.trimOrEmpty(req.getParameter("description")));
                    r.setAddress(ValidationUtil.trimOrEmpty(req.getParameter("address")));
                    r.setCity(ValidationUtil.trimOrEmpty(req.getParameter("city")));
                    r.setDeliveryTimeMins(ValidationUtil.parsePositiveInt(req.getParameter("deliveryTimeMins"), 30));
                    restaurantDAO.update(r);
                    session.setAttribute("loggedRestaurant", restaurantDAO.findById(r.getRestaurantId()));
                    req.setAttribute("success", "Restaurant profile updated.");
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Operation failed: " + e.getMessage());
        }
        doGet(req, resp);
    }
}
