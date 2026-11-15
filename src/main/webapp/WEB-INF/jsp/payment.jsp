<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Payments Simulation – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section class="section">
    <div class="container" style="max-width:760px;">
        <h1 class="section-title" style="margin-bottom:8px;">Payments</h1>
        <p style="color:var(--text-muted);margin-bottom:22px;">Academic DBMS Payments Simulation &bull; Executed inside a single JDBC transaction</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <div style="background:#fff;border:1px solid var(--border);border-radius:16px;padding:28px;box-shadow:var(--shadow-sm);">
            <div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:18px;border-bottom:1px solid var(--border);margin-bottom:20px;">
                <div>
                    <div style="font-size:0.86rem;color:var(--text-muted);">Delivering to</div>
                    <div style="font-weight:600;">${deliveryAddress}</div>
                </div>
                <div style="text-align:right;">
                    <div style="font-size:0.86rem;color:var(--text-muted);">Amount Payable</div>
                    <div style="font-size:1.55rem;font-weight:800;color:var(--primary);">&#8377;${cartTotal}</div>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/order/place" method="post">
                <input type="hidden" name="deliveryAddress" value="${deliveryAddress}">
                <input type="hidden" name="specialInstructions" value="${specialInstructions}">

                <div class="form-group">
                    <label>Select Payments Method</label>
                    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin-top:8px;">
                        <label style="border:1px solid var(--border);padding:14px;border-radius:12px;cursor:pointer;display:flex;align-items:center;gap:8px;font-weight:600;">
                            <input type="radio" name="paymentMethod" value="UPI" checked style="width:auto;"> UPI (GPay / PhonePe)
                        </label>
                        <label style="border:1px solid var(--border);padding:14px;border-radius:12px;cursor:pointer;display:flex;align-items:center;gap:8px;font-weight:600;">
                            <input type="radio" name="paymentMethod" value="CARD" style="width:auto;"> Credit / Debit Card
                        </label>
                        <label style="border:1px solid var(--border);padding:14px;border-radius:12px;cursor:pointer;display:flex;align-items:center;gap:8px;font-weight:600;">
                            <input type="radio" name="paymentMethod" value="NET_BANKING" style="width:auto;"> Net Banking
                        </label>
                        <label style="border:1px solid var(--border);padding:14px;border-radius:12px;cursor:pointer;display:flex;align-items:center;gap:8px;font-weight:600;">
                            <input type="radio" name="paymentMethod" value="WALLET" style="width:auto;"> Digital Wallet
                        </label>
                        <label style="border:1px solid var(--border);padding:14px;border-radius:12px;cursor:pointer;display:flex;align-items:center;gap:8px;font-weight:600;">
                            <input type="radio" name="paymentMethod" value="COD" style="width:auto;"> Cash on Delivery
                        </label>
                    </div>
                </div>

                <div style="padding:12px 16px;background:#f8fafc;border-radius:10px;border:1px solid var(--border);font-size:0.84rem;color:var(--text-muted);margin-bottom:20px;">
                    Note: This is an academic Payments simulation. Submitting places the order in <code>Orders</code>, inserts line items into <code>Order_Items</code>, and records the Payments in <code>Payments</code> atomically.
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%;padding:14px;font-size:1rem;">
                    Confirm &amp; Place Order (&#8377;${cartTotal})
                </button>
            </form>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
