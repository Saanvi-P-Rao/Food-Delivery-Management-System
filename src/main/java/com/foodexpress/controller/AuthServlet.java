package com.foodexpress.controller;

import com.foodexpress.model.Admin;
import com.foodexpress.model.Restaurant;
import com.foodexpress.model.User;
import com.foodexpress.service.AuthService;
import com.foodexpress.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = {"/login", "/register", "/logout", "/restaurant/login", "/admin/login"})
public class AuthServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/login" -> req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
            case "/register" -> req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            case "/restaurant/login" -> req.getRequestDispatcher("/WEB-INF/jsp/restaurant/login.jsp").forward(req, resp);
            case "/admin/login" -> req.getRequestDispatcher("/WEB-INF/jsp/admin/login.jsp").forward(req, resp);
            case "/logout" -> {
                HttpSession session = req.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                resp.sendRedirect(req.getContextPath() + "/home");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String ctx = req.getContextPath();

        try {
            switch (path) {
                case "/login" -> handleCustomerLogin(req, resp, ctx);
                case "/register" -> handleCustomerRegister(req, resp, ctx);
                case "/restaurant/login" -> handleRestaurantLogin(req, resp, ctx);
                case "/admin/login" -> handleAdminLogin(req, resp, ctx);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
            doGet(req, resp);
        }
    }

    private void handleCustomerLogin(HttpServletRequest req, HttpServletResponse resp, String ctx)
            throws SQLException, IOException, ServletException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        User user = authService.loginCustomer(email, password);
        if (user == null) {
            req.setAttribute("error", "Invalid email or password.");
            req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
            return;
        }
        HttpSession session = req.getSession(true);
        session.setAttribute("loggedUser", user);
        String redirect = req.getParameter("redirect");
        if (redirect != null && redirect.startsWith("/") && !redirect.startsWith("//")) {
            resp.sendRedirect(ctx + redirect);
        } else {
            resp.sendRedirect(ctx + "/restaurants");
        }
    }

    private void handleCustomerRegister(HttpServletRequest req, HttpServletResponse resp, String ctx)
            throws SQLException, IOException, ServletException {
        String fullName = ValidationUtil.trimOrEmpty(req.getParameter("fullName"));
        String email = ValidationUtil.trimOrEmpty(req.getParameter("email"));
        String phone = ValidationUtil.trimOrEmpty(req.getParameter("phone"));
        String password = req.getParameter("password");
        String address = ValidationUtil.trimOrEmpty(req.getParameter("address"));
        String city = ValidationUtil.trimOrEmpty(req.getParameter("city"));
        String pincode = ValidationUtil.trimOrEmpty(req.getParameter("pincode"));

        if (ValidationUtil.isBlank(fullName) || !ValidationUtil.isValidEmail(email)
                || !ValidationUtil.isValidPhone(phone) || ValidationUtil.isBlank(password) || password.length() < 6
                || ValidationUtil.isBlank(address) || ValidationUtil.isBlank(city) || !ValidationUtil.isValidPincode(pincode)) {
            req.setAttribute("error", "Please fill in all fields with valid details (password min 6 chars).");
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            return;
        }

        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setAddress(address);
        user.setCity(city);
        user.setPincode(pincode);

        try {
            authService.registerCustomer(user, password);
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedUser", user);
            resp.sendRedirect(ctx + "/restaurants");
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
        }
    }

    private void handleRestaurantLogin(HttpServletRequest req, HttpServletResponse resp, String ctx)
            throws SQLException, IOException, ServletException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        Restaurant r = authService.loginRestaurant(email, password);
        if (r == null) {
            req.setAttribute("error", "Invalid Restaurant credentials.");
            req.getRequestDispatcher("/WEB-INF/jsp/restaurant/login.jsp").forward(req, resp);
            return;
        }
        HttpSession session = req.getSession(true);
        session.setAttribute("loggedRestaurant", r);
        resp.sendRedirect(ctx + "/restaurant/dashboard");
    }

    private void handleAdminLogin(HttpServletRequest req, HttpServletResponse resp, String ctx)
            throws SQLException, IOException, ServletException {
        String identifier = req.getParameter("identifier");
        String password = req.getParameter("password");
        Admin admin = authService.loginAdmin(identifier, password);
        if (admin == null) {
            req.setAttribute("error", "Invalid administrator username/email or password.");
            req.getRequestDispatcher("/WEB-INF/jsp/admin/login.jsp").forward(req, resp);
            return;
        }
        HttpSession session = req.getSession(true);
        session.setAttribute("loggedAdmin", admin);
        resp.sendRedirect(ctx + "/admin/dashboard");
    }
}
