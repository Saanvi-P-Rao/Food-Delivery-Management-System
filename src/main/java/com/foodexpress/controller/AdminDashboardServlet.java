package com.foodexpress.controller;

import com.foodexpress.config.DBConnection;
import com.foodexpress.dao.*;
import com.foodexpress.model.*;
import com.foodexpress.service.DatabaseMetadataService;
import com.foodexpress.service.SqlExecutionService;
import com.foodexpress.util.PasswordUtil;
import com.foodexpress.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet(urlPatterns = {
    "/admin/dashboard", "/admin/users", "/admin/restaurants", "/admin/foods",
    "/admin/orders", "/admin/order-items", "/admin/payments",
    "/admin/explorer", "/admin/sql-console", "/admin/query-history"
})
public class AdminDashboardServlet extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final UserDAO userDAO = new UserDAO();
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final OrderItemDAO orderItemDAO = new OrderItemDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final DatabaseMetadataService metadataService = new DatabaseMetadataService();
    private final SqlExecutionService sqlService = new SqlExecutionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        req.setAttribute("dbName", DBConnection.getDatabaseName());
        req.setAttribute("sandboxDbName", DBConnection.getSandboxDatabaseName());
        req.setAttribute("dbConnected", DBConnection.testConnection());

        try {
            if ("/admin/explorer".equals(path)) {
                boolean sandbox = "true".equalsIgnoreCase(req.getParameter("sandbox"));
                req.setAttribute("useSandbox", sandbox);
                req.setAttribute("tables", metadataService.getAllTablesMetadata(sandbox));
                req.getRequestDispatcher("/WEB-INF/jsp/admin/explorer.jsp").forward(req, resp);
                return;
            }
            if ("/admin/sql-console".equals(path)) {
                req.setAttribute("tables", metadataService.getAllTablesMetadata(false));
                req.setAttribute("history", sqlService.getHistory());
                try (java.sql.Connection c = DBConnection.getConnection()) {
                    req.setAttribute("mysqlVersion", c.getMetaData().getDatabaseProductVersion());
                } catch (SQLException ignored) {
                    req.setAttribute("mysqlVersion", "Unavailable");
                }
                req.getRequestDispatcher("/WEB-INF/jsp/admin/sql-console.jsp").forward(req, resp);
                return;
            }
            if ("/admin/query-history".equals(path)) {
                req.setAttribute("activeSection", "history");
                req.setAttribute("history", sqlService.getHistory());
                req.setAttribute("stats", dashboardDAO.getAdminStats());
                req.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(req, resp);
                return;
            }

            String section = switch (path) {
                case "/admin/users" -> "users";
                case "/admin/restaurants" -> "restaurants";
                case "/admin/foods" -> "foods";
                case "/admin/orders" -> "orders";
                case "/admin/order-items" -> "order-items";
                case "/admin/payments" -> "payments";
                default -> "overview";
            };
            req.setAttribute("activeSection", section);
            req.setAttribute("stats", dashboardDAO.getAdminStats());

            switch (section) {
                case "users" -> req.setAttribute("users", userDAO.findAll());
                case "restaurants" -> req.setAttribute("restaurants", restaurantDAO.findAll());
                case "foods" -> {
                    req.setAttribute("foods", foodItemDAO.findAll());
                    req.setAttribute("restaurants", restaurantDAO.findAll());
                }
                case "orders" -> req.setAttribute("orders", orderDAO.findAll());
                case "order-items" -> req.setAttribute("orderItems", orderItemDAO.findAll());
                case "payments" -> req.setAttribute("payments", paymentDAO.findAll());
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = ValidationUtil.trimOrEmpty(req.getParameter("action"));
        try {
            switch (action) {
                case "createUser" -> {
                    User u = new User();
                    u.setFullName(ValidationUtil.trimOrEmpty(req.getParameter("fullName")));
                    u.setEmail(ValidationUtil.trimOrEmpty(req.getParameter("email")));
                    u.setPhone(ValidationUtil.trimOrEmpty(req.getParameter("phone")));
                    u.setPasswordHash(PasswordUtil.hashPassword(req.getParameter("password")));
                    u.setAddress(ValidationUtil.trimOrEmpty(req.getParameter("address")));
                    u.setCity(ValidationUtil.trimOrEmpty(req.getParameter("city")));
                    u.setPincode(ValidationUtil.trimOrEmpty(req.getParameter("pincode")));
                    userDAO.create(u);
                    req.setAttribute("success", "User created successfully.");
                }
                case "updateUser" -> {
                    int id = ValidationUtil.parsePositiveInt(req.getParameter("userId"), -1);
                    User u = userDAO.findById(id);
                    if (u != null) {
                        u.setFullName(ValidationUtil.trimOrEmpty(req.getParameter("fullName")));
                        u.setEmail(ValidationUtil.trimOrEmpty(req.getParameter("email")));
                        u.setPhone(ValidationUtil.trimOrEmpty(req.getParameter("phone")));
                        u.setAddress(ValidationUtil.trimOrEmpty(req.getParameter("address")));
                        u.setCity(ValidationUtil.trimOrEmpty(req.getParameter("city")));
                        u.setPincode(ValidationUtil.trimOrEmpty(req.getParameter("pincode")));
                        userDAO.update(u);
                        req.setAttribute("success", "User #" + id + " updated.");
                    }
                }
                case "deleteUser" -> {
                    int id = ValidationUtil.parsePositiveInt(req.getParameter("userId"), -1);
                    userDAO.delete(id);
                    req.setAttribute("success", "User #" + id + " deleted.");
                }
                case "createRestaurant" -> {
                    Restaurant r = new Restaurant();
                    r.setName(ValidationUtil.trimOrEmpty(req.getParameter("name")));
                    r.setEmail(ValidationUtil.trimOrEmpty(req.getParameter("email")));
                    r.setPhone(ValidationUtil.trimOrEmpty(req.getParameter("phone")));
                    r.setPasswordHash(PasswordUtil.hashPassword(req.getParameter("password")));
                    r.setCuisineType(ValidationUtil.trimOrEmpty(req.getParameter("cuisineType")));
                    r.setDescription(ValidationUtil.trimOrEmpty(req.getParameter("description")));
                    r.setAddress(ValidationUtil.trimOrEmpty(req.getParameter("address")));
                    r.setCity(ValidationUtil.trimOrEmpty(req.getParameter("city")));
                    r.setRating(new BigDecimal("4.30"));
                    r.setDeliveryTimeMins(ValidationUtil.parsePositiveInt(req.getParameter("deliveryTimeMins"), 30));
                    String img = ValidationUtil.trimOrEmpty(req.getParameter("imageUrl"));
                    r.setImageUrl(img.isEmpty() ? "https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800&q=80" : img);
                    r.setActive(true);
                    restaurantDAO.create(r);
                    req.setAttribute("success", "Restaurant added.");
                }
                case "updateRestaurant" -> {
                    int id = ValidationUtil.parsePositiveInt(req.getParameter("restaurantId"), -1);
                    Restaurant r = restaurantDAO.findById(id);
                    if (r != null) {
                        r.setName(ValidationUtil.trimOrEmpty(req.getParameter("name")));
                        r.setEmail(ValidationUtil.trimOrEmpty(req.getParameter("email")));
                        r.setPhone(ValidationUtil.trimOrEmpty(req.getParameter("phone")));
                        r.setCuisineType(ValidationUtil.trimOrEmpty(req.getParameter("cuisineType")));
                        r.setCity(ValidationUtil.trimOrEmpty(req.getParameter("city")));
                        r.setAddress(ValidationUtil.trimOrEmpty(req.getParameter("address")));
                        r.setDeliveryTimeMins(ValidationUtil.parsePositiveInt(req.getParameter("deliveryTimeMins"), 30));
                        r.setActive("true".equalsIgnoreCase(req.getParameter("isActive")));
                        restaurantDAO.update(r);
                        req.setAttribute("success", "Restaurant #" + id + " updated.");
                    }
                }
                case "deleteRestaurant" -> {
                    int id = ValidationUtil.parsePositiveInt(req.getParameter("restaurantId"), -1);
                    restaurantDAO.delete(id);
                    req.setAttribute("success", "Restaurant #" + id + " deleted.");
                }
                case "createFood" -> {
                    FoodItem f = new FoodItem();
                    f.setRestaurantId(ValidationUtil.parsePositiveInt(req.getParameter("restaurantId"), 1));
                    f.setName(ValidationUtil.trimOrEmpty(req.getParameter("name")));
                    f.setDescription(ValidationUtil.trimOrEmpty(req.getParameter("description")));
                    f.setCategory(ValidationUtil.trimOrEmpty(req.getParameter("category")));
                    f.setPrice(ValidationUtil.parsePositiveDecimal(req.getParameter("price")));
                    f.setVeg("true".equalsIgnoreCase(req.getParameter("isVeg")));
                    f.setAvailable(true);
                    String img = ValidationUtil.trimOrEmpty(req.getParameter("imageUrl"));
                    f.setImageUrl(img.isEmpty() ? "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80" : img);
                    foodItemDAO.create(f);
                    req.setAttribute("success", "Food item added.");
                }
                case "deleteFood" -> {
                    int id = ValidationUtil.parsePositiveInt(req.getParameter("foodId"), -1);
                    foodItemDAO.delete(id);
                    req.setAttribute("success", "Food item #" + id + " deleted.");
                }
                case "updateOrderStatus" -> {
                    int id = ValidationUtil.parsePositiveInt(req.getParameter("orderId"), -1);
                    String status = ValidationUtil.trimOrEmpty(req.getParameter("orderStatus"));
                    orderDAO.updateStatus(id, status);
                    req.setAttribute("success", "Order #" + id + " updated to " + status + ".");
                }
                case "deleteOrder" -> {
                    int id = ValidationUtil.parsePositiveInt(req.getParameter("orderId"), -1);
                    orderDAO.delete(id);
                    req.setAttribute("success", "Order #" + id + " deleted.");
                }
                case "updatePaymentStatus" -> {
                    int id = ValidationUtil.parsePositiveInt(req.getParameter("paymentId"), -1);
                    String status = ValidationUtil.trimOrEmpty(req.getParameter("paymentStatus"));
                    paymentDAO.updateStatus(id, status);
                    req.setAttribute("success", "Payments #" + id + " updated to " + status + ".");
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", "MySQL Error: " + e.getMessage());
        }
        doGet(req, resp);
    }
}
