package com.foodexpress.controller;

import com.foodexpress.dao.FoodItemDAO;
import com.foodexpress.model.CartItem;
import com.foodexpress.model.FoodItem;
import com.foodexpress.util.JsonUtil;
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
import java.util.*;

@WebServlet(urlPatterns = {"/cart", "/api/cart"})
public class CartServlet extends HttpServlet {

    private final FoodItemDAO foodItemDAO = new FoodItemDAO();

    @SuppressWarnings("unchecked")
    public static List<CartItem> getOrCreateCart(HttpSession session) {
        Object obj = session.getAttribute("cart");
        if (obj instanceof List<?>) {
            return (List<CartItem>) obj;
        }
        List<CartItem> cart = new ArrayList<>();
        session.setAttribute("cart", cart);
        return cart;
    }

    public static BigDecimal calculateTotal(List<CartItem> cart) {
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : cart) {
            total = total.add(item.getSubtotal());
        }
        return total;
    }

    public static int calculateCount(List<CartItem> cart) {
        int count = 0;
        for (CartItem item : cart) {
            count += item.getQuantity();
        }
        return count;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        List<CartItem> cart = getOrCreateCart(session);

        if ("/api/cart".equals(req.getServletPath())) {
            Map<String, Object> res = new LinkedHashMap<>();
            res.put("success", true);
            res.put("items", cart);
            res.put("count", calculateCount(cart));
            res.put("total", calculateTotal(cart));
            JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, res);
            return;
        }

        req.setAttribute("cartItems", cart);
        req.setAttribute("cartTotal", calculateTotal(cart));
        req.getRequestDispatcher("/WEB-INF/jsp/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        List<CartItem> cart = getOrCreateCart(session);
        String action = ValidationUtil.trimOrEmpty(req.getParameter("action"));
        boolean isApi = "/api/cart".equals(req.getServletPath());

        try {
            switch (action) {
                case "add" -> {
                    int foodId = ValidationUtil.parsePositiveInt(req.getParameter("foodId"), -1);
                    int qty = ValidationUtil.parsePositiveInt(req.getParameter("quantity"), 1);
                    boolean replaceCart = "true".equalsIgnoreCase(req.getParameter("replace"));

                    FoodItem food = foodItemDAO.findById(foodId);
                    if (food == null || !food.isAvailable()) {
                        respondError(req, resp, isApi, "Food item is unavailable.");
                        return;
                    }

                    if (!cart.isEmpty() && cart.get(0).getRestaurantId() != food.getRestaurantId()) {
                        if (replaceCart) {
                            cart.clear();
                        } else {
                            if (isApi) {
                                JsonUtil.writeJson(resp, HttpServletResponse.SC_CONFLICT, Map.of(
                                    "success", false,
                                    "differentRestaurant", true,
                                    "error", "Your cart contains items from " + cart.get(0).getRestaurantName() +
                                             ". Clear cart to order from " + food.getRestaurantName() + "?"
                                ));
                                return;
                            }
                            cart.clear();
                        }
                    }

                    boolean found = false;
                    for (CartItem item : cart) {
                        if (item.getFoodId() == foodId) {
                            item.setQuantity(item.getQuantity() + qty);
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        cart.add(new CartItem(food, qty));
                    }
                }
                case "update" -> {
                    int foodId = ValidationUtil.parsePositiveInt(req.getParameter("foodId"), -1);
                    int qty = Integer.parseInt(req.getParameter("quantity"));
                    if (qty <= 0) {
                        cart.removeIf(item -> item.getFoodId() == foodId);
                    } else {
                        for (CartItem item : cart) {
                            if (item.getFoodId() == foodId) {
                                item.setQuantity(qty);
                                break;
                            }
                        }
                    }
                }
                case "remove" -> {
                    int foodId = ValidationUtil.parsePositiveInt(req.getParameter("foodId"), -1);
                    cart.removeIf(item -> item.getFoodId() == foodId);
                }
                case "clear" -> cart.clear();
            }

            session.setAttribute("cart", cart);
            if (isApi) {
                Map<String, Object> res = new LinkedHashMap<>();
                res.put("success", true);
                res.put("items", cart);
                res.put("count", calculateCount(cart));
                res.put("total", calculateTotal(cart));
                JsonUtil.writeJson(resp, HttpServletResponse.SC_OK, res);
            } else {
                resp.sendRedirect(req.getContextPath() + "/cart");
            }
        } catch (SQLException e) {
            respondError(req, resp, isApi, "Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            respondError(req, resp, isApi, "Invalid quantity.");
        }
    }

    private void respondError(HttpServletRequest req, HttpServletResponse resp, boolean isApi, String msg)
            throws IOException, ServletException {
        if (isApi) {
            JsonUtil.writeJson(resp, HttpServletResponse.SC_BAD_REQUEST, Map.of("success", false, "error", msg));
        } else {
            req.setAttribute("error", msg);
            doGet(req, resp);
        }
    }
}
