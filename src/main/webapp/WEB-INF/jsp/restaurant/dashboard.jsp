<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restaurant Dashboard – FoodExpress</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
</head>
<body>
<div class="dash-layout">
    <jsp:include page="/WEB-INF/jsp/includes/Restaurant-sidebar.jsp"/>
    <main class="dash-main">
        <div class="dash-topbar">
            <div>
                <h1 class="dash-title">${sessionScope.loggedRestaurant.name}</h1>
                <p style="color:var(--text-muted);font-size:0.9rem;">${sessionScope.loggedRestaurant.cuisineType} &bull; ${sessionScope.loggedRestaurant.city}</p>
            </div>
            <a href="${pageContext.request.contextPath}/restaurant/details?id=${sessionScope.loggedRestaurant.restaurantId}" class="btn btn-outline btn-sm">View Public Storefront</a>
        </div>

        <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>
        <c:if test="${not empty success}"><div class="alert alert-success">${success}</div></c:if>

        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-label">Menu Items</div>
                <div class="kpi-value">${stats.totalFoodItems}</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-label">Total Orders</div>
                <div class="kpi-value">${stats.totalOrders}</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-label">Active / Pending</div>
                <div class="kpi-value">${stats.pendingOrders}</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-label">Total Revenue</div>
                <div class="kpi-value">&#8377;${stats.totalRevenue}</div>
            </div>
        </div>

        <c:if test="${activeTab == 'overview' || activeTab == 'foods'}">
            <div class="panel">
                <div class="panel-header">
                    <h2 class="panel-title">Add New Food Item</h2>
                </div>
                <form action="${pageContext.request.contextPath}/restaurant/foods" method="post">
                    <input type="hidden" name="action" value="addFood">
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Dish Name</label>
                            <input type="text" name="name" required placeholder="e.g., Paneer Tikka Roll">
                        </div>
                        <div class="form-group">
                            <label>Category</label>
                            <input type="text" name="category" required placeholder="e.g., Starters, Main Course, Biryani">
                        </div>
                        <div class="form-group">
                            <label>Price (&#8377;)</label>
                            <input type="number" step="0.01" min="1" name="price" required placeholder="249.00">
                        </div>
                        <div class="form-group">
                            <label>Type</label>
                            <select name="isVeg">
                                <option value="true">Vegetarian</option>
                                <option value="false">Non-Vegetarian</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-grid" style="margin-top:8px;">
                        <div class="form-group">
                            <label>Description</label>
                            <input type="text" name="description" placeholder="Short appetizing description">
                        </div>
                        <div class="form-group">
                            <label>Image URL (Optional)</label>
                            <input type="url" name="imageUrl" placeholder="https://...">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm">+ Add Food Item</button>
                </form>
            </div>

            <div class="panel">
                <div class="panel-header">
                    <h2 class="panel-title">Your Food Menu (${foods.size()})</h2>
                </div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Dish</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Type</th>
                                <th>Availability</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="f" items="${foods}">
                                <tr>
                                    <td>#${f.foodId}</td>
                                    <td><strong>${f.name}</strong><br><span style="font-size:0.78rem;color:#6b7280;">${f.description}</span></td>
                                    <td>${f.category}</td>
                                    <td><strong>&#8377;${f.price}</strong></td>
                                    <td><span class="veg-badge ${f.veg ? 'veg' : 'nonveg'}">${f.veg ? 'VEG' : 'NON-VEG'}</span></td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/restaurant/foods" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="toggleAvailability">
                                            <input type="hidden" name="foodId" value="${f.foodId}">
                                            <input type="hidden" name="available" value="${!f.available}">
                                            <button type="submit" class="btn btn-sm ${f.available ? 'btn-success' : 'btn-outline'}">
                                                ${f.available ? 'Available' : 'Unavailable'}
                                            </button>
                                        </form>
                                    </td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/restaurant/foods" method="post" style="display:inline;" onsubmit="return confirm('Delete this dish?');">
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

        <c:if test="${activeTab == 'overview' || activeTab == 'Orders'}">
            <div class="panel">
                <div class="panel-header">
                    <h2 class="panel-title">Incoming Orders &amp; History (${orders.size()})</h2>
                </div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Customer</th>
                                <th>Ordered Items</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Update Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <tr>
                                    <td><strong>#${o.orderId}</strong><br><span style="font-size:0.76rem;color:#6b7280;">${o.orderDate}</span></td>
                                    <td>${o.customerName}<br><span style="font-size:0.78rem;color:#6b7280;">${o.customerPhone}</span></td>
                                    <td>
                                        <c:forEach var="it" items="${o.items}">
                                            <div style="font-size:0.82rem;">${it.quantity}x ${it.foodName} (&#8377;${it.subtotal})</div>
                                        </c:forEach>
                                    </td>
                                    <td><strong>&#8377;${o.totalAmount}</strong></td>
                                    <td><span class="status-pill status-${o.orderStatus}">${o.orderStatus}</span></td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/restaurant/orders" method="post" style="display:flex;gap:6px;align-items:center;">
                                            <input type="hidden" name="action" value="updateOrderStatus">
                                            <input type="hidden" name="orderId" value="${o.orderId}">
                                            <select name="orderStatus" class="form-select" style="padding:5px 8px;font-size:0.82rem;">
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
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <c:if test="${activeTab == 'profile'}">
            <div class="panel">
                <div class="panel-header"><h2 class="panel-title">Restaurant Profile</h2></div>
                <form action="${pageContext.request.contextPath}/restaurant/profile" method="post">
                    <input type="hidden" name="action" value="updateProfile">
                    <div class="form-grid">
                        <div class="form-group"><label>Name</label><input type="text" name="name" required value="${sessionScope.loggedRestaurant.name}"></div>
                        <div class="form-group"><label>Phone</label><input type="text" name="phone" required value="${sessionScope.loggedRestaurant.phone}"></div>
                        <div class="form-group"><label>Cuisine Type</label><input type="text" name="cuisineType" required value="${sessionScope.loggedRestaurant.cuisineType}"></div>
                        <div class="form-group"><label>City</label><input type="text" name="city" required value="${sessionScope.loggedRestaurant.city}"></div>
                        <div class="form-group"><label>Delivery Time (mins)</label><input type="number" name="deliveryTimeMins" required value="${sessionScope.loggedRestaurant.deliveryTimeMins}"></div>
                    </div>
                    <div class="form-group"><label>Address</label><input type="text" name="address" required value="${sessionScope.loggedRestaurant.address}"></div>
                    <div class="form-group"><label>Description</label><textarea name="description" rows="2">${sessionScope.loggedRestaurant.description}</textarea></div>
                    <button type="submit" class="btn btn-primary">Update Profile</button>
                </form>
            </div>
        </c:if>
    </main>
</div>
</body>
</html>
