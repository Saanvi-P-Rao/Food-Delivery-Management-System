<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Shopping Cart – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section class="section">
    <div class="container" style="max-width:920px;">
        <h1 class="section-title" style="margin-bottom:20px;">Your Shopping Cart</h1>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <c:choose>
            <c:when test="${empty cartItems}">
                <div style="text-align:center;padding:56px;background:#fff;border-radius:16px;border:1px solid var(--border);">
                    <h3>Your cart is empty</h3>
                    <p style="color:var(--text-muted);margin:8px 0 20px;">Add delicious dishes from our restaurants to get started.</p>
                    <a href="${pageContext.request.contextPath}/menu" class="btn btn-primary">Browse Menu</a>
                </div>
            </c:when>
            <c:otherwise>
                <div style="background:#fff;border:1px solid var(--border);border-radius:16px;overflow:hidden;box-shadow:var(--shadow-sm);">
                    <div style="padding:16px 22px;background:#f8fafc;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
                        <span style="font-weight:700;">Ordering from: ${cartItems[0].restaurantName}</span>
                        <form action="${pageContext.request.contextPath}/cart" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="clear">
                            <button type="submit" class="btn btn-outline btn-sm">Clear Cart</button>
                        </form>
                    </div>
                    <div style="padding:10px 22px;">
                        <c:forEach var="item" items="${cartItems}">
                            <div style="display:flex;align-items:center;justify-content:space-between;padding:16px 0;border-bottom:1px solid var(--border);gap:16px;flex-wrap:wrap;">
                                <div style="display:flex;align-items:center;gap:14px;">
                                    <img src="${item.imageUrl}" alt="${item.name}" style="width:64px;height:64px;object-fit:cover;border-radius:10px;">
                                    <div>
                                        <div style="font-weight:700;">${item.name}</div>
                                        <div style="font-size:0.85rem;color:var(--text-muted);">&#8377;${item.price} each</div>
                                    </div>
                                </div>
                                <div style="display:flex;align-items:center;gap:16px;">
                                    <form action="${pageContext.request.contextPath}/cart" method="post" style="display:flex;align-items:center;gap:6px;">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="foodId" value="${item.foodId}">
                                        <input type="number" name="quantity" value="${item.quantity}" min="0" max="20" class="form-control" style="width:72px;padding:6px 10px;">
                                        <button type="submit" class="btn btn-outline btn-sm">Update</button>
                                    </form>
                                    <div style="font-weight:800;min-width:80px;text-align:right;">&#8377;${item.subtotal}</div>
                                    <form action="${pageContext.request.contextPath}/cart" method="post">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="foodId" value="${item.foodId}">
                                        <button type="submit" class="btn btn-sm" style="background:#fef2f2;color:#dc2626;">Remove</button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <div style="padding:20px 22px;background:#f8fafc;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:14px;">
                        <div>
                            <div style="font-size:0.88rem;color:var(--text-muted);">Grand Total (INR)</div>
                            <div style="font-size:1.6rem;font-weight:800;">&#8377;${cartTotal}</div>
                        </div>
                        <div style="display:flex;gap:12px;">
                            <a href="${pageContext.request.contextPath}/menu" class="btn btn-outline">Add More Items</a>
                            <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary">Proceed to Checkout &rarr;</a>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
