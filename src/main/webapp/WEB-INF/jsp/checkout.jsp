<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Checkout – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section class="section">
    <div class="container" style="max-width:960px;">
        <h1 class="section-title" style="margin-bottom:22px;">Checkout</h1>
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <div style="display:grid;grid-template-columns:1.3fr 0.9fr;gap:24px;">
            <div style="background:#fff;border:1px solid var(--border);border-radius:16px;padding:26px;">
                <h3 style="margin-bottom:16px;">Delivery Details</h3>
                <form action="${pageContext.request.contextPath}/checkout" method="post">
                    <div class="form-group">
                        <label>Customer Name</label>
                        <input type="text" value="${sessionScope.loggedUser.fullName}" disabled>
                    </div>
                    <div class="form-group">
                        <label>Delivery Address</label>
                        <textarea name="deliveryAddress" rows="3" required>${sessionScope.loggedUser.address}, ${sessionScope.loggedUser.city} - ${sessionScope.loggedUser.pincode}</textarea>
                    </div>
                    <div class="form-group">
                        <label>Special Instructions (Optional)</label>
                        <input type="text" name="specialInstructions" placeholder="e.g., Less spicy, leave at security gate">
                    </div>
                    <button type="submit" class="btn btn-primary" style="width:100%;padding:13px;">Continue to Payments &rarr;</button>
                </form>
            </div>

            <div style="background:#fff;border:1px solid var(--border);border-radius:16px;padding:24px;height:fit-content;">
                <h3 style="margin-bottom:14px;">Order Summary</h3>
                <div style="font-size:0.86rem;color:var(--text-muted);margin-bottom:14px;">From <strong>${cartItems[0].restaurantName}</strong></div>
                <c:forEach var="item" items="${cartItems}">
                    <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--border);font-size:0.9rem;">
                        <span>${item.quantity}x ${item.name}</span>
                        <strong>&#8377;${item.subtotal}</strong>
                    </div>
                </c:forEach>
                <div style="display:flex;justify-content:space-between;padding-top:14px;font-size:1.2rem;font-weight:800;">
                    <span>Total Payable</span>
                    <span>&#8377;${cartTotal}</span>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
