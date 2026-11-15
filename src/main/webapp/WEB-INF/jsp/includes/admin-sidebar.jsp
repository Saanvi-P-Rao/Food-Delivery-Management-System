<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="dash-sidebar">
    <div class="dash-brand">
        <span class="brand-badge" style="width:32px;height:32px;font-size:0.95rem;">FE</span>
        <span>FoodExpress Admin</span>
    </div>
    <nav class="dash-nav">
        <div class="dash-nav-label">Operations</div>
        <a class="dash-link ${activeSection == 'overview' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard">Overview</a>
        <a class="dash-link ${activeSection == 'users' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/users">User Management</a>
        <a class="dash-link ${activeSection == 'restaurants' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/restaurants">Restaurant Management</a>
        <a class="dash-link ${activeSection == 'foods' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/foods">Food Management</a>
        <a class="dash-link ${activeSection == 'Orders' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/orders">Order Management</a>
        <a class="dash-link ${activeSection == 'order-items' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/order-items">Order Items</a>
        <a class="dash-link ${activeSection == 'payments' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/payments">Payments Management</a>

        <div class="dash-nav-label">DBMS Tools</div>
        <a class="dash-link ${activeSection == 'explorer' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/explorer">Database Explorer</a>
        <a class="dash-link ${activeSection == 'sql-console' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/sql-console">SQL Query Console</a>
        <a class="dash-link ${activeSection == 'history' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/query-history">Query History</a>

        <div class="dash-nav-label">Account</div>
        <a class="dash-link" href="${pageContext.request.contextPath}/home">Customer Website</a>
        <a class="dash-link" href="${pageContext.request.contextPath}/logout">Logout</a>
    </nav>
</aside>
