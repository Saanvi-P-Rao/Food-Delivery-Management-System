<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Customer Login – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<div class="container">
    <div class="auth-wrapper">
        <h2 style="font-size:1.65rem;font-weight:800;margin-bottom:6px;">Welcome back</h2>
        <p style="color:var(--text-muted);font-size:0.92rem;margin-bottom:22px;">Sign in to order food and track your deliveries.</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <input type="hidden" name="redirect" value="${param.redirect}">
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" required placeholder="aarav.sharma@example.in" value="${param.email}">
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required placeholder="Enter your password">
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;padding:12px;">Sign In</button>
        </form>

        <div style="margin-top:18px;padding:12px;background:#f8fafc;border-radius:10px;border:1px solid var(--border);font-size:0.82rem;color:var(--text-muted);">
            <strong>Seeded Demo Customer:</strong><br>
            Email: <code>aarav.sharma@example.in</code> &bull; Password: <code>FoodExpress@123</code>
        </div>

        <p style="text-align:center;margin-top:18px;font-size:0.9rem;color:var(--text-muted);">
            New to FoodExpress? <a href="${pageContext.request.contextPath}/register" style="color:var(--primary);font-weight:700;">Create an account</a>
        </p>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
