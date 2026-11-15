<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – FoodExpress</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
</head>
<body>
<div class="dash-layout">
    <jsp:include page="/WEB-INF/jsp/includes/admin-sidebar.jsp"/>
    <main class="dash-main">
        <div class="dash-topbar">
            <div>
                <h1 class="dash-title">Admin Control Center</h1>
                <p style="color:var(--text-muted);font-size:0.9rem;">
                    Signed in as <strong>${sessionScope.loggedAdmin.fullName}</strong> (${sessionScope.loggedAdmin.role}) &bull;
                    DB: <code>${dbName}</code> (${dbConnected ? 'Connected' : 'Disconnected'})
                </p>
            </div>
            <div style="display:flex;gap:10px;">
                <a href="${pageContext.request.contextPath}/admin/explorer" class="btn btn-outline btn-sm">Database Explorer</a>
                <a href="${pageContext.request.contextPath}/admin/sql-console" class="btn btn-primary btn-sm">Open SQL Console</a>
            </div>
        </div>

        <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
        <c:if test="${not empty success}"><div class="alert alert-success">${success}</div></c:if>

        <div class="kpi-grid">
            <div class="kpi-card"><div class="kpi-label">Total Users</div><div class="kpi-value">${stats.totalUsers}</div></div>
            <div class="kpi-card"><div class="kpi-label">Total Restaurant</div><div class="kpi-value">${stats.totalRestaurants}</div></div>
            <div class="kpi-card"><div class="kpi-label">Total Food Items</div><div class="kpi-value">${stats.totalFoodItems}</div></div>
            <div class="kpi-card"><div class="kpi-label">Total Orders</div><div class="kpi-value">${stats.totalOrders}</div></div>
            <div class="kpi-card"><div class="kpi-label">Total Revenue</div><div class="kpi-value">&#8377;${stats.totalRevenue}</div></div>
            <div class="kpi-card"><div class="kpi-label">Pending Orders</div><div class="kpi-value">${stats.pendingOrders}</div></div>
            <div class="kpi-card"><div class="kpi-label">Completed Orders</div><div class="kpi-value">${stats.completedOrders}</div></div>
        </div>

        <c:if test="${activeSection == 'overview'}">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">
                <div class="panel">
                    <div class="panel-header"><h2 class="panel-title">Recent Orders</h2><a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline btn-sm">View All</a></div>
                    <div class="table-wrap">
                        <table class="data-table">
                            <thead><tr><th>ID</th><th>Customer</th><th>Restaurant</th><th>Total</th><th>Status</th></tr></thead>
                            <tbody>
                                <c:forEach var="o" items="${stats.recentOrders}">
                                    <tr>
                                        <td>#${o.orderId}</td>
                                        <td>${o.customerName}</td>
                                        <td>${o.restaurantName}</td>
                                        <td>&#8377;${o.totalAmount}</td>
                                        <td><span class="status-pill status-${o.orderStatus}">${o.orderStatus}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="panel">
                    <div class="panel-header"><h2 class="panel-title">Recent Payments</h2><a href="${pageContext.request.contextPath}/admin/payments" class="btn btn-outline btn-sm">View All</a></div>
                    <div class="table-wrap">
                        <table class="data-table">
                            <thead><tr><th>Ref</th><th>Order</th><th>Method</th><th>Amount</th><th>Status</th></tr></thead>
                            <tbody>
                                <c:forEach var="p" items="${stats.recentPayments}">
                                    <tr>
                                        <td><code>${p.transactionRef}</code></td>
                                        <td>#${p.orderId}</td>
                                        <td>${p.paymentMethod}</td>
                                        <td>&#8377;${p.amount}</td>
                                        <td><span class="status-pill status-${p.paymentStatus}">${p.paymentStatus}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </c:if>

        <c:if test="${activeSection == 'users'}">
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">Add New Customer</h2></div>
                <form action="${pageContext.request.contextPath}/admin/users" method="post">
                    <input type="hidden" name="action" value="createUser">
                    <div class="form-grid">
                        <div class="form-group"><label>Full Name</label><input type="text" name="fullName" required></div>
                        <div class="form-group"><label>Email</label><input type="email" name="email" required></div>
                        <div class="form-group"><label>Phone</label><input type="text" name="phone" required></div>
                        <div class="form-group"><label>Password</label><input type="password" name="password" required></div>
                        <div class="form-group"><label>City</label><input type="text" name="city" required></div>
                        <div class="form-group"><label>Pincode</label><input type="text" name="pincode" required></div>
                    </div>
                    <div class="form-group"><label>Address</label><input type="text" name="address" required></div>
                    <button type="submit" class="btn btn-primary btn-sm">+ Create User</button>
                </form>
            </div>
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">All Users (${users.size()})</h2></div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>City</th><th>Pincode</th><th>Action</th></tr></thead>
                        <tbody>
                            <c:forEach var="u" items="${users}">
                                <tr>
                                    <td>#${u.userId}</td>
                                    <td><strong>${u.fullName}</strong></td>
                                    <td>${u.email}</td>
                                    <td>${u.phone}</td>
                                    <td>${u.city}</td>
                                    <td>${u.pincode}</td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/users" method="post" onsubmit="return confirm('Delete user #${u.userId}?');">
                                            <input type="hidden" name="action" value="deleteUser">
                                            <input type="hidden" name="userId" value="${u.userId}">
                                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <c:if test="${activeSection == 'restaurants'}">
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">Add Restaurant</h2></div>
                <form action="${pageContext.request.contextPath}/admin/restaurants" method="post">
                    <input type="hidden" name="action" value="createRestaurant">
                    <div class="form-grid">
                        <div class="form-group"><label>Name</label><input type="text" name="name" required></div>
                        <div class="form-group"><label>Email</label><input type="email" name="email" required></div>
                        <div class="form-group"><label>Phone</label><input type="text" name="phone" required></div>
                        <div class="form-group"><label>Password</label><input type="password" name="password" required></div>
                        <div class="form-group"><label>Cuisine</label><input type="text" name="cuisineType" required></div>
                        <div class="form-group"><label>City</label><input type="text" name="city" required></div>
                        <div class="form-group"><label>Delivery Mins</label><input type="number" name="deliveryTimeMins" value="30" required></div>
                        <div class="form-group"><label>Address</label><input type="text" name="address" required></div>
                    </div>
                    <div class="form-group"><label>Description</label><input type="text" name="description"></div>
                    <button type="submit" class="btn btn-primary btn-sm">+ Add Restaurant</button>
                </form>
            </div>
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">All Restaurant (${restaurants.size()})</h2></div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>ID</th><th>Name</th><th>Cuisine</th><th>City</th><th>Rating</th><th>Items</th><th>Status</th><th>Action</th></tr></thead>
                        <tbody>
                            <c:forEach var="r" items="${restaurants}">
                                <tr>
                                    <td>#${r.restaurantId}</td>
                                    <td><strong>${r.name}</strong><br><span style="font-size:0.78rem;color:#6b7280;">${r.email}</span></td>
                                    <td>${r.cuisineType}</td>
                                    <td>${r.city}</td>
                                    <td>${r.rating} &#9733;</td>
                                    <td>${r.foodItemCount}</td>
                                    <td>${r.active ? 'Active' : 'Inactive'}</td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/restaurants" method="post" onsubmit="return confirm('Delete Restaurant #${r.restaurantId}?');">
                                            <input type="hidden" name="action" value="deleteRestaurant">
                                            <input type="hidden" name="restaurantId" value="${r.restaurantId}">
                                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <c:if test="${activeSection == 'foods'}">
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">Add Food Item</h2></div>
                <form action="${pageContext.request.contextPath}/admin/foods" method="post">
                    <input type="hidden" name="action" value="createFood">
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Restaurant</label>
                            <select name="restaurantId">
                                <c:forEach var="r" items="${restaurants}"><option value="${r.restaurantId}">${r.name}</option></c:forEach>
                            </select>
                        </div>
                        <div class="form-group"><label>Name</label><input type="text" name="name" required></div>
                        <div class="form-group"><label>Category</label><input type="text" name="category" required></div>
                        <div class="form-group"><label>Price (&#8377;)</label><input type="number" step="0.01" min="1" name="price" required></div>
                        <div class="form-group"><label>Veg?</label><select name="isVeg"><option value="true">Veg</option><option value="false">Non-Veg</option></select></div>
                    </div>
                    <div class="form-group"><label>Description</label><input type="text" name="description"></div>
                    <button type="submit" class="btn btn-primary btn-sm">+ Add Food Item</button>
                </form>
            </div>
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">All Food Items (${foods.size()})</h2></div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>ID</th><th>Dish</th><th>Restaurant</th><th>Category</th><th>Price</th><th>Type</th><th>Action</th></tr></thead>
                        <tbody>
                            <c:forEach var="f" items="${foods}">
                                <tr>
                                    <td>#${f.foodId}</td>
                                    <td><strong>${f.name}</strong></td>
                                    <td>${f.restaurantName}</td>
                                    <td>${f.category}</td>
                                    <td>&#8377;${f.price}</td>
                                    <td><span class="veg-badge ${f.veg ? 'veg' : 'nonveg'}">${f.veg ? 'VEG' : 'NON-VEG'}</span></td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/foods" method="post" onsubmit="return confirm('Delete food #${f.foodId}?');">
                                            <input type="hidden" name="action" value="deleteFood">
                                            <input type="hidden" name="foodId" value="${f.foodId}">
                                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <c:if test="${activeSection == 'Orders'}">
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">All Orders (${orders.size()})</h2></div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>ID</th><th>Customer</th><th>Restaurant</th><th>Total</th><th>Status</th><th>Update</th><th>Delete</th></tr></thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <tr>
                                    <td>#${o.orderId}</td>
                                    <td>${o.customerName}</td>
                                    <td>${o.restaurantName}</td>
                                    <td><strong>&#8377;${o.totalAmount}</strong></td>
                                    <td><span class="status-pill status-${o.orderStatus}">${o.orderStatus}</span></td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/orders" method="post" style="display:flex;gap:6px;">
                                            <input type="hidden" name="action" value="updateOrderStatus">
                                            <input type="hidden" name="orderId" value="${o.orderId}">
                                            <select name="orderStatus" class="form-select" style="padding:4px 8px;font-size:0.8rem;">
                                                <option value="PLACED" ${o.orderStatus == 'PLACED' ? 'selected' : ''}>PLACED</option>
                                                <option value="CONFIRMED" ${o.orderStatus == 'CONFIRMED' ? 'selected' : ''}>CONFIRMED</option>
                                                <option value="PREPARING" ${o.orderStatus == 'PREPARING' ? 'selected' : ''}>PREPARING</option>
                                                <option value="OUT_FOR_DELIVERY" ${o.orderStatus == 'OUT_FOR_DELIVERY' ? 'selected' : ''}>OUT_FOR_DELIVERY</option>
                                                <option value="DELIVERED" ${o.orderStatus == 'DELIVERED' ? 'selected' : ''}>DELIVERED</option>
                                                <option value="CANCELLED" ${o.orderStatus == 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
                                            </select>
                                            <button type="submit" class="btn btn-primary btn-sm">Save</button>
                                        </form>
                                    </td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/orders" method="post" onsubmit="return confirm('Delete order #${o.orderId}?');">
                                            <input type="hidden" name="action" value="deleteOrder">
                                            <input type="hidden" name="orderId" value="${o.orderId}">
                                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <c:if test="${activeSection == 'order-items'}">
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">Order Items (${orderItems.size()})</h2></div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>Item ID</th><th>Order ID</th><th>Food Dish</th><th>Quantity</th><th>Purchase Price</th><th>Subtotal</th></tr></thead>
                        <tbody>
                            <c:forEach var="oi" items="${orderItems}">
                                <tr>
                                    <td>#${oi.orderItemId}</td>
                                    <td>Order #${oi.orderId}</td>
                                    <td>${oi.foodName}</td>
                                    <td>${oi.quantity}</td>
                                    <td>&#8377;${oi.itemPrice}</td>
                                    <td><strong>&#8377;${oi.subtotal}</strong></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <c:if test="${activeSection == 'payments'}">
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">Payments Records (${payments.size()})</h2></div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>ID</th><th>Order ID</th><th>Txn Ref</th><th>Method</th><th>Amount</th><th>Status</th><th>Update</th></tr></thead>
                        <tbody>
                            <c:forEach var="p" items="${payments}">
                                <tr>
                                    <td>#${p.paymentId}</td>
                                    <td>Order #${p.orderId}</td>
                                    <td><code>${p.transactionRef}</code></td>
                                    <td>${p.paymentMethod}</td>
                                    <td><strong>&#8377;${p.amount}</strong></td>
                                    <td><span class="status-pill status-${p.paymentStatus}">${p.paymentStatus}</span></td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/payments" method="post" style="display:flex;gap:6px;">
                                            <input type="hidden" name="action" value="updatePaymentStatus">
                                            <input type="hidden" name="paymentId" value="${p.paymentId}">
                                            <select name="paymentStatus" class="form-select" style="padding:4px 8px;font-size:0.8rem;">
                                                <option value="PENDING" ${p.paymentStatus == 'PENDING' ? 'selected' : ''}>PENDING</option>
                                                <option value="SUCCESS" ${p.paymentStatus == 'SUCCESS' ? 'selected' : ''}>SUCCESS</option>
                                                <option value="FAILED" ${p.paymentStatus == 'FAILED' ? 'selected' : ''}>FAILED</option>
                                                <option value="REFUNDED" ${p.paymentStatus == 'REFUNDED' ? 'selected' : ''}>REFUNDED</option>
                                            </select>
                                            <button type="submit" class="btn btn-primary btn-sm">Save</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <c:if test="${activeSection == 'history'}">
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">SQL Query Execution History (${history.size()})</h2></div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>#</th><th>Timestamp</th><th>Database</th><th>Type</th><th>SQL Statement</th><th>Status</th><th>Rows</th><th>Time</th></tr></thead>
                        <tbody>
                            <c:forEach var="h" items="${history}">
                                <tr>
                                    <td>${h.id}</td>
                                    <td>${h.executedAt}</td>
                                    <td><code>${h.databaseName}</code></td>
                                    <td>${h.statementType}</td>
                                    <td><code style="font-size:0.8rem;">${h.sql}</code></td>
                                    <td><span class="status-pill ${h.success ? 'status-SUCCESS' : 'status-FAILED'}">${h.success ? 'OK' : 'ERROR'}</span></td>
                                    <td>${h.rowsReturned > 0 ? h.rowsReturned : h.rowsAffected}</td>
                                    <td>${h.executionTimeMs} ms</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>
    </main>
</div>
</body>
</html>
