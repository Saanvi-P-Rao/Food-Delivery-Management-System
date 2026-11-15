<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.foodexpress.controller.CartServlet" %>
<%
    int navCartCount = 0;
    if (session != null) {
        navCartCount = CartServlet.calculateCount(CartServlet.getOrCreateCart(session));
    }
    request.setAttribute("navCartCount", navCartCount);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty pageTitle ? pageTitle : 'FoodExpress – Food Delivery Management System'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <script>window.APP_CTX = '${pageContext.request.contextPath}';</script>
</head>
<body>
<header class="navbar">
    <div class="container nav-inner">
        <a href="${pageContext.request.contextPath}/home" class="brand">
            <span class="brand-badge">FE</span>
            <span>Food<span style="color:var(--primary);">Express</span></span>
        </a>
        <nav class="nav-links">
            <a href="${pageContext.request.contextPath}/home">Home</a>
            <a href="${pageContext.request.contextPath}/restaurants">Restaurant</a>
            <a href="${pageContext.request.contextPath}/menu">Food Menu</a>
            <c:if test="${not empty sessionScope.loggedUser}">
                <a href="${pageContext.request.contextPath}/orders">My Orders</a>
                <a href="${pageContext.request.contextPath}/profile">Profile</a>
            </c:if>
            <a href="${pageContext.request.contextPath}/restaurant/login">Partner Portal</a>
            <a href="${pageContext.request.contextPath}/admin/login">Admin Console</a>
        </nav>
        <div class="nav-actions">
            <a href="${pageContext.request.contextPath}/cart" class="cart-pill">
                <span>Cart</span>
                <span class="cart-count" id="navCartCount">${navCartCount}</span>
            </a>
            <c:choose>
                <c:when test="${not empty sessionScope.loggedUser}">
                    <a href="${pageContext.request.contextPath}/profile" class="btn btn-outline btn-sm">${sessionScope.loggedUser.fullName}</a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-primary btn-sm">Logout</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline btn-sm">Login</a>
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-sm">Sign Up</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>
