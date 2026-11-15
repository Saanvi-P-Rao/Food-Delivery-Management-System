<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Order History – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section class="section">
    <div class="container" style="max-width:980px;">
        <h1 class="section-title" style="margin-bottom:6px;">My Order History</h1>
        <p class="section-sub" style="margin-bottom:24px;">Live order status and itemized receipts from MySQL</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <c:choose>
            <c:when test="${empty Orders}">
                <div style="text-align:center;padding:56px;background:#fff;border-radius:16px;border:1px solid var(--border);">
                    <h3>No Orders yet</h3>
                    <p style="color:var(--text-muted);margin:8px 0 20px;">Place your first order to see it tracked here.</p>
                    <a href="${pageContext.request.contextPath}/restaurants" class="btn btn-primary">Explore Restaurant</a>
                </div>
            </c:when>
            <c:otherwise>
                <div style="display:flex;flex-direction:column;gap:18px;">
                    <c:forEach var="o" items="${orders}">
                        <div style="background:#fff;border:1px solid var(--border);border-radius:16px;padding:22px;box-shadow:var(--shadow-sm);">
                            <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:12px;padding-bottom:14px;border-bottom:1px solid var(--border);">
                                <div>
                                    <div style="font-weight:800;font-size:1.1rem;">Order #${o.orderId} &bull; ${o.restaurantName}</div>
                                    <div style="font-size:0.84rem;color:var(--text-muted);">Placed on ${o.orderDate} &bull; ${o.deliveryAddress}</div>
                                </div>
                                <div style="text-align:right;">
                                    <span class="status-pill status-${o.orderStatus}">${o.orderStatus}</span>
                                    <div style="font-weight:800;font-size:1.15rem;margin-top:4px;">&#8377;${o.totalAmount}</div>
                                </div>
                            </div>
                            <div style="padding:12px 0;">
                                <c:forEach var="item" items="${o.items}">
                                    <div style="display:flex;justify-content:space-between;font-size:0.9rem;padding:4px 0;">
                                        <span>${item.quantity}x ${item.foodName} <span style="color:var(--text-muted);">(&#8377;${item.itemPrice})</span></span>
                                        <strong>&#8377;${item.subtotal}</strong>
                                    </div>
                                </c:forEach>
                            </div>
                            <c:if test="${not empty o.Payments}">
                                <div style="padding-top:10px;border-top:1px solid #f1f5f9;font-size:0.84rem;color:var(--text-muted);display:flex;justify-content:space-between;flex-wrap:wrap;gap:10px;">
                                    <span>Payments: <strong>${o.Payments.paymentMethod}</strong> (${o.Payments.paymentStatus})</span>
                                    <span>Ref: <code>${o.Payments.transactionRef}</code></span>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
