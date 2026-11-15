package com.foodexpress.controller;

import com.foodexpress.dao.OrderDAO;
import com.foodexpress.dao.UserDAO;
import com.foodexpress.model.User;
import com.foodexpress.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = {"/orders", "/profile"})
public class CustomerOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();
        try {
            if ("/orders".equals(path)) {
                req.setAttribute("orders", orderDAO.findByUserId(user.getUserId()));
                req.getRequestDispatcher("/WEB-INF/jsp/orders.jsp").forward(req, resp);
            } else {
                User freshUser = userDAO.findById(user.getUserId());
                if (freshUser != null) {
                    session.setAttribute("loggedUser", freshUser);
                }
                req.getRequestDispatcher("/WEB-INF/jsp/profile.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/orders.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"/profile".equals(req.getServletPath())) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String fullName = ValidationUtil.trimOrEmpty(req.getParameter("fullName"));
        String phone = ValidationUtil.trimOrEmpty(req.getParameter("phone"));
        String address = ValidationUtil.trimOrEmpty(req.getParameter("address"));
        String city = ValidationUtil.trimOrEmpty(req.getParameter("city"));
        String pincode = ValidationUtil.trimOrEmpty(req.getParameter("pincode"));

        if (ValidationUtil.isBlank(fullName) || !ValidationUtil.isValidPhone(phone)
                || ValidationUtil.isBlank(address) || ValidationUtil.isBlank(city)
                || !ValidationUtil.isValidPincode(pincode)) {
            req.setAttribute("error", "Please enter valid profile details.");
            req.getRequestDispatcher("/WEB-INF/jsp/profile.jsp").forward(req, resp);
            return;
        }

        user.setFullName(fullName);
        user.setPhone(phone);
        user.setAddress(address);
        user.setCity(city);
        user.setPincode(pincode);

        try {
            userDAO.update(user);
            session.setAttribute("loggedUser", userDAO.findById(user.getUserId()));
            req.setAttribute("success", "Profile updated successfully.");
        } catch (SQLException e) {
            req.setAttribute("error", "Unable to update profile: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/jsp/profile.jsp").forward(req, resp);
    }
}
