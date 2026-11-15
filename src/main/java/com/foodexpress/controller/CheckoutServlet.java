package com.foodexpress.controller;

import com.foodexpress.dao.OrderDAO;
import com.foodexpress.model.CartItem;
import com.foodexpress.model.Order;
import com.foodexpress.model.User;
import com.foodexpress.service.OrderService;
import com.foodexpress.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/checkout", "/payment", "/order/place", "/order/confirmation"})
public class CheckoutServlet extends HttpServlet {

    private final OrderService orderService = new OrderService();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if ("/order/confirmation".equals(path)) {
            int orderId = ValidationUtil.parsePositiveInt(req.getParameter("orderId"), -1);
            if (orderId <= 0) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }
            try {
                Order order = orderDAO.findById(orderId);
                if (order == null || order.getUserId() != user.getUserId()) {
                    resp.sendRedirect(req.getContextPath() + "/orders");
                    return;
                }
                req.setAttribute("order", order);
                req.getRequestDispatcher("/WEB-INF/jsp/order-confirmation.jsp").forward(req, resp);
            } catch (SQLException e) {
                req.setAttribute("error", "Unable to load order: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/jsp/orders.jsp").forward(req, resp);
            }
            return;
        }

        List<CartItem> cart = CartServlet.getOrCreateCart(session);
        if (cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        req.setAttribute("cartItems", cart);
        req.setAttribute("cartTotal", CartServlet.calculateTotal(cart));

        if ("/payment".equals(path)) {
            String deliveryAddress = (String) session.getAttribute("checkoutAddress");
            if (ValidationUtil.isBlank(deliveryAddress)) {
                deliveryAddress = user.getAddress() + ", " + user.getCity() + " - " + user.getPincode();
                session.setAttribute("checkoutAddress", deliveryAddress);
            }
            req.setAttribute("deliveryAddress", deliveryAddress);
            req.setAttribute("specialInstructions", session.getAttribute("checkoutInstructions"));
            req.getRequestDispatcher("/WEB-INF/jsp/payment.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/jsp/checkout.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<CartItem> cart = CartServlet.getOrCreateCart(session);
        if (cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        if ("/checkout".equals(path)) {
            String address = ValidationUtil.trimOrEmpty(req.getParameter("deliveryAddress"));
            String instructions = ValidationUtil.trimOrEmpty(req.getParameter("specialInstructions"));
            if (ValidationUtil.isBlank(address)) {
                req.setAttribute("error", "Please enter a valid delivery address.");
                req.setAttribute("cartItems", cart);
                req.setAttribute("cartTotal", CartServlet.calculateTotal(cart));
                req.getRequestDispatcher("/WEB-INF/jsp/checkout.jsp").forward(req, resp);
                return;
            }
            session.setAttribute("checkoutAddress", address);
            session.setAttribute("checkoutInstructions", instructions);
            resp.sendRedirect(req.getContextPath() + "/payment");
            return;
        }

        if ("/order/place".equals(path)) {
            String address = ValidationUtil.trimOrEmpty(req.getParameter("deliveryAddress"));
            if (ValidationUtil.isBlank(address)) {
                address = (String) session.getAttribute("checkoutAddress");
            }
            String instructions = ValidationUtil.trimOrEmpty(req.getParameter("specialInstructions"));
            if (ValidationUtil.isBlank(instructions)) {
                instructions = (String) session.getAttribute("checkoutInstructions");
            }
            String paymentMethod = ValidationUtil.trimOrEmpty(req.getParameter("paymentMethod"));

            try {
                Order placedOrder = orderService.placeOrder(user.getUserId(), cart, address, instructions, paymentMethod);
                cart.clear();
                session.setAttribute("cart", cart);
                session.removeAttribute("checkoutAddress");
                session.removeAttribute("checkoutInstructions");
                resp.sendRedirect(req.getContextPath() + "/order/confirmation?orderId=" + placedOrder.getOrderId());
            } catch (Exception e) {
                req.setAttribute("error", "Order placement failed (transaction rolled back): " + e.getMessage());
                req.setAttribute("cartItems", cart);
                req.setAttribute("cartTotal", CartServlet.calculateTotal(cart));
                req.setAttribute("deliveryAddress", address);
                req.setAttribute("specialInstructions", instructions);
                req.getRequestDispatcher("/WEB-INF/jsp/payment.jsp").forward(req, resp);
            }
        }
    }
}
