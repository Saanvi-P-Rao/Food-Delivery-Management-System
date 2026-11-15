<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Restaurant Partner Login – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<div class="container">
    <div class="auth-wrapper">
        <h2 style="font-size:1.6rem;font-weight:800;margin-bottom:6px;">Restaurant Partner Portal</h2>
        <p style="color:var(--text-muted);font-size:0.92rem;margin-bottom:22px;">Manage your menu, availability, and incoming Orders.</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/restaurant/login" method="post">
            <div class="form-group">
                <label>Restaurant Email</label>
                <input type="email" name="email" required placeholder="spicegarden@foodexpress.in">
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required placeholder="Enter password">
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;padding:12px;">Sign In to Kitchen Dashboard</button>
        </form>

        <div style="margin-top:18px;padding:12px;background:#f8fafc;border-radius:10px;border:1px solid var(--border);font-size:0.82rem;color:var(--text-muted);">
            <strong>Seeded Demo Restaurant:</strong><br>
            Email: <code>spicegarden@foodexpress.in</code> &bull; Password: <code>FoodExpress@123</code>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
