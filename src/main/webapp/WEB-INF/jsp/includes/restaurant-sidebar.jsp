<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<aside class="dash-sidebar">
    <div class="dash-brand">
        <span class="brand-badge" style="width:32px;height:32px;font-size:0.95rem;">FE</span>
        <span>Partner Portal</span>
    </div>
    <nav class="dash-nav">
        <div class="dash-nav-label">Restaurant</div>
        <a class="dash-link ${activeTab == 'overview' ? 'active' : ''}" href="${pageContext.request.contextPath}/restaurant/dashboard">Overview</a>
        <a class="dash-link ${activeTab == 'foods' ? 'active' : ''}" href="${pageContext.request.contextPath}/restaurant/foods">Manage Food Items</a>
        <a class="dash-link ${activeTab == 'Orders' ? 'active' : ''}" href="${pageContext.request.contextPath}/restaurant/orders">Orders &amp; History</a>
        <a class="dash-link ${activeTab == 'profile' ? 'active' : ''}" href="${pageContext.request.contextPath}/restaurant/profile">Restaurant Profile</a>
        <div class="dash-nav-label">System</div>
        <a class="dash-link" href="${pageContext.request.contextPath}/home">Customer Website</a>
        <a class="dash-link" href="${pageContext.request.contextPath}/logout">Logout</a>
    </nav>
</aside>
