<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${restaurant.name} – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section style="background:#1c1e26;color:#fff;padding:44px 0;">
    <div class="container" style="display:grid;grid-template-columns:280px 1fr;gap:32px;align-items:center;">
        <img src="${restaurant.imageUrl}" alt="${restaurant.name}" style="width:100%;height:190px;object-fit:cover;border-radius:16px;border:2px solid rgba(255,255,255,0.15);">
        <div>
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                <span class="rating-badge" style="position:static;">${restaurant.rating} &#9733;</span>
                <span style="color:#d1d5db;font-size:0.9rem;">${restaurant.cuisineType}</span>
            </div>
            <h1 style="font-size:2.2rem;font-weight:800;margin-bottom:8px;">${restaurant.name}</h1>
            <p style="color:#d1d5db;margin-bottom:14px;max-width:650px;">${restaurant.description}</p>
            <div style="font-size:0.9rem;color:#9ca3af;">
                &#128205; ${restaurant.address}, ${restaurant.city} &nbsp;&bull;&nbsp; &#9201; ${restaurant.deliveryTimeMins} mins delivery &nbsp;&bull;&nbsp; &#128222; ${restaurant.phone}
            </div>
        </div>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="section-header">
            <div>
                <h2 class="section-title">Menu (${menuItems.size()} items)</h2>
                <p class="section-sub">Freshly prepared and fetched live from MySQL</p>
            </div>
            <a href="${pageContext.request.contextPath}/cart" class="btn btn-primary">Go to Cart &rarr;</a>
        </div>

        <div class="grid-4">
            <c:forEach var="f" items="${menuItems}">
                <div class="card">
                    <div class="card-img-wrap" style="height:165px;">
                        <img src="${f.imageUrl}" alt="${f.name}">
                    </div>
                    <div class="card-body">
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;">
                            <span class="veg-badge ${f.veg ? 'veg' : 'nonveg'}">${f.veg ? 'VEG' : 'NON-VEG'}</span>
                            <span style="font-size:0.78rem;color:var(--text-muted);font-weight:600;">${f.category}</span>
                        </div>
                        <h3 class="card-title" style="font-size:1rem;">${f.name}</h3>
                        <p style="font-size:0.84rem;color:var(--text-muted);min-height:38px;">${f.description}</p>
                        <div class="card-footer">
                            <span class="price">&#8377;${f.price}</span>
                            <c:choose>
                                <c:when test="${f.available}">
                                    <button type="button" class="btn btn-primary btn-sm" onclick="FoodExpress.addToCart(${f.foodId})">+ Add</button>
                                </c:when>
                                <c:otherwise>
                                    <span style="font-size:0.8rem;font-weight:700;color:var(--danger);">Unavailable</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
