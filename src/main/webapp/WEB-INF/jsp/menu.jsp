<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Food Menu – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section class="section">
    <div class="container">
        <div class="section-header">
            <div>
                <h1 class="section-title">Explore Food Menu</h1>
                <p class="section-sub">Search and filter across 100+ authentic dishes</p>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/menu" method="get" class="filter-bar">
            <input type="text" name="search" class="form-control" style="flex:1;min-width:200px;" placeholder="Search dish, Restaurant, or flavor..." value="${selectedSearch}">
            <select name="category" class="form-select">
                <option value="">All Categories</option>
                <c:forEach var="cat" items="${categories}">
                    <option value="${cat}" ${selectedCategory == cat ? 'selected' : ''}>${cat}</option>
                </c:forEach>
            </select>
            <select name="veg" class="form-select">
                <option value="">Veg &amp; Non-Veg</option>
                <option value="veg" ${selectedVeg == 'veg' ? 'selected' : ''}>Pure Veg Only</option>
                <option value="nonveg" ${selectedVeg == 'nonveg' ? 'selected' : ''}>Non-Veg Only</option>
            </select>
            <select name="restaurantId" class="form-select">
                <option value="">All Restaurant</option>
                <c:forEach var="r" items="${restaurants}">
                    <option value="${r.restaurantId}" ${selectedRestaurantId == r.restaurantId ? 'selected' : ''}>${r.name}</option>
                </c:forEach>
            </select>
            <input type="number" name="maxPrice" class="form-control" style="width:130px;" placeholder="Max &#8377;" value="${selectedMaxPrice}">
            <select name="sort" class="form-select">
                <option value="">Sort: Top Rated</option>
                <option value="price_asc" ${selectedSort == 'price_asc' ? 'selected' : ''}>Price: Low to High</option>
                <option value="price_desc" ${selectedSort == 'price_desc' ? 'selected' : ''}>Price: High to Low</option>
            </select>
            <button type="submit" class="btn btn-primary">Filter</button>
            <a href="${pageContext.request.contextPath}/menu" class="btn btn-outline">Reset</a>
        </form>

        <c:choose>
            <c:when test="${empty foodItems}">
                <div style="text-align:center;padding:56px;background:#fff;border-radius:14px;border:1px solid var(--border);">
                    <h3>No dishes match your filters</h3>
                    <p style="color:var(--text-muted);margin-top:6px;">Try broadening your search or resetting the filters.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="grid-4">
                    <c:forEach var="f" items="${foodItems}">
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
                                <div class="card-meta">
                                    <a href="${pageContext.request.contextPath}/restaurant/details?id=${f.restaurantId}" style="color:var(--primary);font-weight:600;">${f.restaurantName}</a>
                                </div>
                                <p style="font-size:0.82rem;color:var(--text-muted);min-height:36px;">${f.description}</p>
                                <div class="card-footer">
                                    <span class="price">&#8377;${f.price}</span>
                                    <button type="button" class="btn btn-primary btn-sm" onclick="FoodExpress.addToCart(${f.foodId})">+ Add</button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
