<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="My Profile – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section class="section">
    <div class="container" style="max-width:640px;">
        <h1 class="section-title" style="margin-bottom:20px;">My Profile</h1>

        <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
        <c:if test="${not empty success}"><div class="alert alert-success">${success}</div></c:if>

        <div style="background:#fff;border:1px solid var(--border);border-radius:16px;padding:28px;box-shadow:var(--shadow-sm);">
            <form action="${pageContext.request.contextPath}/profile" method="post">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="fullName" required value="${sessionScope.loggedUser.fullName}">
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" value="${sessionScope.loggedUser.email}" disabled>
                </div>
                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="text" name="phone" required value="${sessionScope.loggedUser.phone}">
                </div>
                <div class="form-group">
                    <label>Delivery Address</label>
                    <textarea name="address" rows="2" required>${sessionScope.loggedUser.address}</textarea>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
                    <div class="form-group">
                        <label>City</label>
                        <input type="text" name="city" required value="${sessionScope.loggedUser.city}">
                    </div>
                    <div class="form-group">
                        <label>Pincode</label>
                        <input type="text" name="pincode" required value="${sessionScope.loggedUser.pincode}">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </form>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
