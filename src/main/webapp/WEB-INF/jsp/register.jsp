<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create Account – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<div class="container">
    <div class="auth-wrapper" style="max-width:540px;">
        <h2 style="font-size:1.65rem;font-weight:800;margin-bottom:6px;">Create your FoodExpress account</h2>
        <p style="color:var(--text-muted);font-size:0.92rem;margin-bottom:24px;">Order from top Indian restaurants with live tracking.</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="post">
            <div class="form-group">
                <label>Full Name</label>
                <input type="text" name="fullName" required placeholder="e.g., Aarav Sharma" value="${param.fullName}">
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" required placeholder="you@example.in" value="${param.email}">
                </div>
                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="text" name="phone" required placeholder="9876543210" value="${param.phone}">
                </div>
            </div>
            <div class="form-group">
                <label>Password (min 6 characters)</label>
                <input type="password" name="password" required minlength="6" placeholder="Create a strong password">
            </div>
            <div class="form-group">
                <label>Delivery Address</label>
                <textarea name="address" rows="2" required placeholder="House/Flat No, Street, Landmark">${param.address}</textarea>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
                <div class="form-group">
                    <label>City</label>
                    <input type="text" name="city" required placeholder="e.g., Bengaluru" value="${param.city}">
                </div>
                <div class="form-group">
                    <label>Pincode</label>
                    <input type="text" name="pincode" required placeholder="560038" value="${param.pincode}">
                </div>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;padding:12px;">Create Account</button>
        </form>
        <p style="text-align:center;margin-top:18px;font-size:0.9rem;color:var(--text-muted);">
            Already have an account? <a href="${pageContext.request.contextPath}/login" style="color:var(--primary);font-weight:700;">Sign In</a>
        </p>
    </div>
</div>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
