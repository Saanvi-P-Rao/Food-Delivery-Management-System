<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<footer class="footer">
    <div class="container">
        <div class="footer-grid">
            <div>
                <div class="brand" style="color:#fff;margin-bottom:10px;">
                    <span class="brand-badge">FE</span>
                    <span>FoodExpress</span>
                </div>
                <p style="font-size:0.9rem;max-width:340px;">
                    Full-stack Java, Jakarta Servlets, JSP, JDBC &amp; MySQL 8.0 Food Delivery Management System with live Database Explorer and SQL Query Execution Console.
                </p>
            </div>
            <div>
                <h4>Explore</h4>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/restaurants">Browse Restaurant</a></li>
                    <li><a href="${pageContext.request.contextPath}/menu">Food Menu</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart">Shopping Cart</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Order History</a></li>
                </ul>
            </div>
            <div>
                <h4>Portals</h4>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/login">Customer Login</a></li>
                    <li><a href="${pageContext.request.contextPath}/restaurant/login">Restaurant Partner Dashboard</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/login">Admin &amp; SQL Console</a></li>
                </ul>
            </div>
        </div>
        <div style="padding-top:20px;font-size:0.84rem;display:flex;justify-content:space-between;flex-wrap:wrap;gap:10px;">
            <span>&copy; 2026 FoodExpress DBMS Project. Powered by Java 25, JDBC &amp; MySQL 8.0.</span>
            <span>INR (&#8377;) Pricing &bull; Academic Payments Simulation</span>
        </div>
    </div>
</footer>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
