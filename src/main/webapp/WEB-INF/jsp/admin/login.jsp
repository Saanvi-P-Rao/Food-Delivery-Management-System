<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Admin Login – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<div class="container">
    <div class="auth-wrapper">
        <h2 style="font-size:1.6rem;font-weight:800;margin-bottom:6px;">Administrator Console</h2>
        <p style="color:var(--text-muted);font-size:0.92rem;margin-bottom:22px;">Sign in to access system management, Database Explorer &amp; SQL Query Console.</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/admin/login" method="post">
            <div class="form-group">
                <label>Username or Email</label>
                <input type="text" name="identifier" required placeholder="superadmin or admin@foodexpress.in">
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required placeholder="Enter admin password">
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;padding:12px;">Sign In as Administrator</button>
        </form>

        <div style="margin-top:18px;padding:12px;background:#f8fafc;border-radius:10px;border:1px solid var(--border);font-size:0.82rem;color:var(--text-muted);">
            <strong>Seeded Demo Admin:</strong><br>
            Username: <code>superadmin</code> (or <code>admin@foodexpress.in</code>) &bull; Password: <code>FoodExpress@123</code>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
