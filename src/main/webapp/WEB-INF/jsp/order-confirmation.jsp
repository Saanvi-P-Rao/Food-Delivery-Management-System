<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Order Confirmed – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section class="section">
    <div class="container" style="max-width:760px;">
        <div style="background:#fff;border:1px solid var(--border);border-radius:18px;padding:34px;box-shadow:var(--shadow-md);">
            <div style="text-align:center;margin-bottom:26px;">
                <div style="width:62px;height:62px;border-radius:50%;background:#ecfdf5;color:#16a34a;display:inline-grid;place-items:center;font-size:1.8rem;font-weight:800;margin-bottom:12px;">&#10003;</div>
                <h1 style="font-size:1.8rem;font-weight:800;">Order Confirmed!</h1>
                <p style="color:var(--text-muted);">Order <strong>#${order.orderId}</strong> has been committed to MySQL.</p>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;background:#f8fafc;padding:16px;border-radius:12px;margin-bottom:22px;font-size:0.9rem;">
                <div><strong>Restaurant:</strong> ${order.restaurantName}</div>
                <div><strong>Status:</strong> <span class="status-pill status-${order.orderStatus}">${order.orderStatus}</span></div>
                <div><strong>Payments Method:</strong> ${order.Payments.paymentMethod}</div>
                <div><strong>Transaction Ref:</strong> <code>${order.Payments.transactionRef}</code></div>
                <div style="grid-column:1/-1;"><strong>Delivery Address:</strong> ${order.deliveryAddress}</div>
            </div>

            <h3 style="margin-bottom:12px;">Ordered Items</h3>
            <table style="width:100%;border-collapse:collapse;font-size:0.92rem;margin-bottom:20px;">
                <thead>
                    <tr style="border-bottom:1px solid var(--border);text-align:left;color:var(--text-muted);">
                        <th style="padding:8px 0;">Item</th>
                        <th style="padding:8px 0;">Qty</th>
                        <th style="padding:8px 0;">Unit Price</th>
                        <th style="padding:8px 0;text-align:right;">Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${order.items}">
                        <tr style="border-bottom:1px solid #f1f5f9;">
                            <td style="padding:10px 0;font-weight:600;">${item.foodName}</td>
                            <td style="padding:10px 0;">${item.quantity}</td>
                            <td style="padding:10px 0;">&#8377;${item.itemPrice}</td>
                            <td style="padding:10px 0;text-align:right;font-weight:700;">&#8377;${item.subtotal}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div style="display:flex;justify-content:space-between;align-items:center;padding-top:14px;border-top:2px solid var(--border);font-size:1.2rem;font-weight:800;">
                <span>Total Paid</span>
                <span>&#8377;${order.totalAmount}</span>
            </div>

            <div style="display:flex;gap:12px;justify-content:center;margin-top:28px;">
                <a href="${pageContext.request.contextPath}/orders" class="btn btn-primary">View Order History</a>
                <a href="${pageContext.request.contextPath}/restaurants" class="btn btn-outline">Order More Food</a>
            </div>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
