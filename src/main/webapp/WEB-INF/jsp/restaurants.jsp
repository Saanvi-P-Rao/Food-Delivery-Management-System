<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Restaurant – FoodExpress" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>

<section class="section">
    <div class="container">
        <div class="section-header">
            <div>
                <h1 class="section-title">All Restaurant</h1>
                <p class="section-sub">Discover curated kitchens delivering fresh Indian &amp; global cuisines</p>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/restaurants" method="get" class="filter-bar">
            <input type="text" name="search" class="form-control" style="flex:1;min-width:220px;" placeholder="Search Restaurant name, cuisine, or city..." value="${selectedSearch}">
            <select name="city" class="form-select">
                <option value="">All Cities</option>
                <c:forEach var="c" items="${cities}">
                    <option value="${c}" ${selectedCity == c ? 'selected' : ''}>${c}</option>
                </c:forEach>
            </select>
            <select name="cuisine" class="form-select">
                <option value="">All Cuisines</option>
                <c:forEach var="cu" items="${cuisines}">
                    <option value="${cu}" ${selectedCuisine == cu ? 'selected' : ''}>${cu}</option>
                </c:forEach>
            </select>
            <button type="submit" class="btn btn-primary">Apply Filters</button>
            <a href="${pageContext.request.contextPath}/restaurants" class="btn btn-outline">Reset</a>
        </form>

        <c:choose>
            <c:when test="${empty restaurants}">
                <div class="panel" style="text-align:center;padding:48px;background:#fff;border-radius:14px;border:1px solid var(--border);">
                    <h3>No restaurants found</h3>
                    <p style="color:var(--text-muted);margin-top:6px;">Try clearing your filters or searching a different city.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="grid-3">
                    <c:forEach var="r" items="${restaurants}">
                        <a href="${pageContext.request.contextPath}/restaurant/details?id=${r.restaurantId}" class="card">
                            <div class="card-img-wrap">
                                <img src="${r.imageUrl}" alt="${r.name}">
                                <span class="time-badge">${r.deliveryTimeMins} mins</span>
                                <span class="rating-badge">${r.rating} &#9733;</span>
                            </div>
                            <div class="card-body">
                                <h3 class="card-title">${r.name}</h3>
                                <div class="card-meta">${r.cuisineType} &bull; ${r.city}</div>
                                <p style="font-size:0.88rem;color:var(--text-muted);">${r.description}</p>
                                <div class="card-footer">
                                    <span style="font-size:0.84rem;color:var(--text-muted);font-weight:600;">${r.foodItemCount} dishes available</span>
                                    <span style="color:var(--primary);font-weight:700;font-size:0.88rem;">View Menu &rarr;</span>
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
