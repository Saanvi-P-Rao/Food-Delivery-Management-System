package com.foodexpress.filter;

import com.foodexpress.util.JsonUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

/**
 * Enforces backend role-based access control for Customer, Restaurant, and Admin routes.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String ctx = req.getContextPath();
        String path = req.getRequestURI().substring(ctx.length());
        HttpSession session = req.getSession(false);

        // 1. Protect Admin APIs
        if (path.startsWith("/api/admin/")) {
            if (session == null || session.getAttribute("loggedAdmin") == null) {
                JsonUtil.writeJson(resp, HttpServletResponse.SC_UNAUTHORIZED,
                    Map.of("success", false, "error", "Unauthorized: Administrator authentication required."));
                return;
            }
        }

        // 2. Protect Admin Pages (except /admin/login)
        if (path.startsWith("/admin/") && !path.equals("/admin/login")) {
            if (session == null || session.getAttribute("loggedAdmin") == null) {
                resp.sendRedirect(ctx + "/admin/login");
                return;
            }
        }

        // 3. Protect Restaurant Dashboard Pages (except /restaurant/login and public /restaurant/details)
        if (path.startsWith("/restaurant/") && !path.equals("/restaurant/login") && !path.equals("/restaurant/details")) {
            if (session == null || session.getAttribute("loggedRestaurant") == null) {
                resp.sendRedirect(ctx + "/restaurant/login");
                return;
            }
        }

        // 4. Protect Customer Authenticated Pages
        if (path.equals("/checkout") || path.equals("/payment") || path.startsWith("/order/")
                || path.equals("/orders") || path.equals("/profile")) {
            if (session == null || session.getAttribute("loggedUser") == null) {
                resp.sendRedirect(ctx + "/login?redirect=" + java.net.URLEncoder.encode(path, "UTF-8"));
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
