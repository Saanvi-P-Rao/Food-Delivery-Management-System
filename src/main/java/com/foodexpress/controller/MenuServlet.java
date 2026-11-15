package com.foodexpress.controller;

import com.foodexpress.dao.FoodItemDAO;
import com.foodexpress.dao.RestaurantDAO;
import com.foodexpress.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String search = req.getParameter("search");
            String category = req.getParameter("category");
            String vegParam = req.getParameter("veg");
            Boolean isVeg = null;
            if ("true".equalsIgnoreCase(vegParam) || "veg".equalsIgnoreCase(vegParam)) {
                isVeg = Boolean.TRUE;
            } else if ("false".equalsIgnoreCase(vegParam) || "nonveg".equalsIgnoreCase(vegParam)) {
                isVeg = Boolean.FALSE;
            }
            Integer restaurantId = null;
            int parsedRest = ValidationUtil.parsePositiveInt(req.getParameter("restaurantId"), -1);
            if (parsedRest > 0) restaurantId = parsedRest;

            BigDecimal maxPrice = ValidationUtil.parsePositiveDecimal(req.getParameter("maxPrice"));
            String sortBy = req.getParameter("sort");

            req.setAttribute("foodItems", foodItemDAO.searchAndFilter(search, category, isVeg, restaurantId, maxPrice, sortBy));
            req.setAttribute("categories", foodItemDAO.findAllCategories());
            req.setAttribute("restaurants", restaurantDAO.findActive(null, null, null));
            req.setAttribute("selectedSearch", search);
            req.setAttribute("selectedCategory", category);
            req.setAttribute("selectedVeg", vegParam);
            req.setAttribute("selectedRestaurantId", restaurantId);
            req.setAttribute("selectedMaxPrice", maxPrice);
            req.setAttribute("selectedSort", sortBy);
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/jsp/menu.jsp").forward(req, resp);
    }
}
