package com.foodexpress.controller;

import com.foodexpress.dao.FoodItemDAO;
import com.foodexpress.dao.RestaurantDAO;
import com.foodexpress.model.FoodItem;
import com.foodexpress.model.Restaurant;
import com.foodexpress.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/restaurants", "/restaurant/details"})
public class RestaurantServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private final FoodItemDAO foodItemDAO = new FoodItemDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            if ("/restaurant/details".equals(path)) {
                int id = ValidationUtil.parsePositiveInt(req.getParameter("id"), -1);
                if (id <= 0) {
                    resp.sendRedirect(req.getContextPath() + "/restaurants");
                    return;
                }
                Restaurant r = restaurantDAO.findById(id);
                if (r == null) {
                    resp.sendRedirect(req.getContextPath() + "/restaurants");
                    return;
                }
                List<FoodItem> menu = foodItemDAO.findByRestaurantId(id, false);
                req.setAttribute("restaurant", r);
                req.setAttribute("menuItems", menu);
                req.getRequestDispatcher("/WEB-INF/jsp/restaurant-details.jsp").forward(req, resp);
                return;
            }

            String search = req.getParameter("search");
            String city = req.getParameter("city");
            String cuisine = req.getParameter("cuisine");

            req.setAttribute("restaurants", restaurantDAO.findActive(search, city, cuisine));
            req.setAttribute("cities", restaurantDAO.findAllCities());
            req.setAttribute("cuisines", restaurantDAO.findAllCuisines());
            req.setAttribute("selectedSearch", search);
            req.setAttribute("selectedCity", city);
            req.setAttribute("selectedCuisine", cuisine);
            req.getRequestDispatcher("/WEB-INF/jsp/restaurants.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/restaurants.jsp").forward(req, resp);
        }
    }
}
