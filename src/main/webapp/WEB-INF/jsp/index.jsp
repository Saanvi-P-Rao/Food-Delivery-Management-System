<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="FoodExpress – Database Query Management System" scope="request"/>
<jsp:include page="/WEB-INF/jsp/includes/header.jsp"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sql-console.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/query-workspace.css">

<!-- Live Database Status Header -->
<section class="qms-header-strip">
    <div class="container">
        <div class="qms-title-row">
            <div>
                <h1>FoodExpress &mdash; Database Query Management System</h1>
                <div class="qms-subtitle">
                    Live JDBC Workspace connected to MySQL database <code>${not empty dbName ? dbName : 'food_delivery_db'}</code>
                    &bull; 7 Relational Tables
                </div>
            </div>
            <div class="qms-status-pill">
                <span class="qms-dot ${dbConnected ? 'online' : 'offline'}"></span>
                <span>
                    <c:choose>
                        <c:when test="${dbConnected}">
                            MySQL Connected (${not empty mysqlVersion ? mysqlVersion : '8.0'}) &bull; ${tables.size()} Tables
                        </c:when>
                        <c:otherwise>
                            MySQL Disconnected
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <c:if test="${not empty tables}">
            <div class="qms-table-pills">
                <span style="font-size:0.78rem;color:#94a3b8;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;">Tables:</span>
                <c:forEach var="t" items="${tables}">
                    <button type="button" class="qms-table-pill" data-table="${t.tableName}" title="Click to build a visual query on ${t.tableName}">
                        <span>${t.tableName}</span>
                        <span class="cnt">${t.recordCount}</span>
                    </button>
                </c:forEach>
            </div>
        </c:if>
    </div>
</section>

<main class="container qms-workspace">
    <c:if test="${not empty dbError}">
        <div class="alert alert-error" style="margin-bottom:16px;">${dbError}</div>
    </c:if>

    <!-- 1. Clickable Search-Style Placeholder (Opens Visual Query Builder) -->
    <div class="vb-placeholder-bar" id="vbPlaceholderBar" role="button" tabindex="0" title="Click to open Visual SQL Query Builder">
        <div class="vb-placeholder-left">
            <span class="vb-placeholder-icon">&#128269;</span>
            <span>Search or click to build a <strong>Visual SQL Query</strong> on <code>food_delivery_db</code> (tables, columns, AND/OR filters, grouping, sorting &amp; limits)...</span>
        </div>
        <span class="btn btn-primary btn-sm">Open Query Builder</span>
    </div>

    <!-- Mode Switcher Tabs -->
    <div class="qms-tabs">
        <button type="button" class="qms-tab-btn" id="tabBtnVisual">Visual SQL Query Builder</button>
        <button type="button" class="qms-tab-btn active" id="tabBtnManual">Manual SQL Editor</button>
    </div>

    <!-- PANEL A: Visual SQL Query Builder (opened on clicking placeholder or tab) -->
    <section class="qms-panel" id="panelVisualBuilder">
        <div class="vb-grid">
            <!-- Left Column: Table & Dynamic Columns -->
            <div>
                <div class="vb-section">
                    <div class="vb-section-title">
                        <span>1. Select Table</span>
                    </div>
                    <select id="vbTableSelect" class="form-select" style="width:100%;">
                        <option value="">-- Choose a Table --</option>
                        <c:forEach var="t" items="${tables}">
                            <option value="${t.tableName}">${t.tableName} (${t.recordCount} rows)</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="vb-section" style="margin-bottom:0;">
                    <div class="vb-section-title">
                        <span>2. Select Columns &amp; Aggregates</span>
                        <span style="display:flex;gap:6px;">
                            <button type="button" id="vbSelectAllCols" class="btn btn-outline btn-xs">All</button>
                            <button type="button" id="vbClearCols" class="btn btn-outline btn-xs">None</button>
                        </span>
                    </div>
                    <div class="vb-col-list" id="vbColumnsList">
                        <div style="color:#64748b;font-size:0.82rem;padding:8px;">Select a table to dynamically load its columns.</div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Filters (AND/OR), Grouping, Sorting, Limit, Live SQL & Execute -->
            <div>
                <div class="vb-section">
                    <div class="vb-section-title">
                        <span>3. Filter Conditions (WHERE &mdash; AND / OR)</span>
                        <button type="button" id="vbAddFilterBtn" class="btn btn-primary btn-xs">+ Add Condition</button>
                    </div>
                    <div id="vbFiltersList"></div>
                    <div style="font-size:0.78rem;color:#64748b;">Supports =, !=, &gt;, &gt;=, &lt;, &lt;=, LIKE, NOT LIKE, IN, NOT IN, BETWEEN, IS NULL, IS NOT NULL.</div>
                </div>

                <div class="vb-section">
                    <div class="vb-section-title">
                        <span>4. Grouping, Sorting &amp; Limit</span>
                    </div>
                    <div class="vb-options-row">
                        <div>
                            <label style="font-size:0.78rem;font-weight:700;color:#475569;display:block;margin-bottom:4px;">GROUP BY</label>
                            <div class="vb-groupby-pills" id="vbGroupByList">
                                <span style="color:#64748b;font-size:0.78rem;">Select a table first.</span>
                            </div>
                        </div>
                        <div>
                            <label style="font-size:0.78rem;font-weight:700;color:#475569;display:block;margin-bottom:4px;">ORDER BY</label>
                            <div style="display:flex;gap:6px;">
                                <select id="vbOrderByCol" class="form-select" style="font-size:0.82rem;">
                                    <option value="">-- None --</option>
                                </select>
                                <select id="vbOrderByDir" class="form-select" style="width:95px;font-size:0.82rem;">
                                    <option value="ASC">ASC</option>
                                    <option value="DESC">DESC</option>
                                </select>
                            </div>
                        </div>
                        <div>
                            <label for="vbLimitInput" style="font-size:0.78rem;font-weight:700;color:#475569;display:block;margin-bottom:4px;">LIMIT</label>
                            <input type="number" id="vbLimitInput" class="form-control" value="100" min="1" max="1000" style="font-size:0.84rem;">
                        </div>
                    </div>
                </div>

                <div class="vb-section" style="margin-bottom:0;">
                    <div class="vb-section-title">
                        <span>5. Generated SQL Preview (Before Execution)</span>
                    </div>
                    <pre class="vb-sql-preview-box" id="vbGeneratedSql">-- Select a database table above to generate SQL automatically</pre>
                    <div style="display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap;">
                        <div style="display:flex;gap:8px;flex-wrap:wrap;">
                            <button type="button" id="vbSendToManualBtn" class="btn btn-outline btn-sm">Open in Manual Editor</button>
                            <button type="button" id="vbResetBtn" class="btn btn-outline btn-sm">Reset</button>
                        </div>
                        <button type="button" id="vbExecuteBtn" class="btn btn-primary">Execute Generated Query</button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- PANEL B: Manual SQL Editor -->
    <section class="qms-panel active" id="panelManualEditor">
        <div class="manual-grid">
            <aside class="manual-schema-box">
                <div style="font-size:0.74rem;text-transform:uppercase;letter-spacing:0.06em;color:#94a3b8;font-weight:700;margin-bottom:8px;">
                    food_delivery_db Schema
                </div>
                <c:forEach var="t" items="${tables}">
                    <div style="margin-bottom:10px;border-bottom:1px solid #1e293b;padding-bottom:8px;">
                        <div class="manual-schema-tbl" data-table="${t.tableName}" style="display:flex;justify-content:space-between;font-weight:700;color:#f8fafc;cursor:pointer;">
                            <span>${t.tableName}</span>
                            <span style="color:#94a3b8;font-size:0.74rem;">${t.recordCount}</span>
                        </div>
                        <div style="margin-top:4px;padding-left:6px;">
                            <c:forEach var="c" items="${t.columns}">
                                <div style="display:flex;justify-content:space-between;font-size:0.75rem;color:#cbd5e1;padding:1px 0;">
                                    <span>
                                        <c:if test="${c.primaryKey}"><span class="key-badge key-pk">PK</span></c:if>
                                        <c:if test="${c.foreignKey}"><span class="key-badge key-fk">FK</span></c:if>
                                        ${c.name}
                                    </span>
                                    <span style="color:#64748b;">${c.dataType}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:forEach>
            </aside>

            <div>
                <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:10px;">
                    <div style="display:flex;gap:6px;flex-wrap:wrap;">
                        <button type="button" class="btn btn-outline btn-xs sample-sql-btn" data-sql="SHOW TABLES;">SHOW TABLES</button>
                        <button type="button" class="btn btn-outline btn-xs sample-sql-btn" data-sql="SELECT r.restaurant_name, COUNT(o.order_id) AS total_orders, COALESCE(SUM(o.total_amount), 0) AS revenue&#10;FROM restaurants r&#10;LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id&#10;GROUP BY r.restaurant_id, r.restaurant_name&#10;ORDER BY revenue DESC&#10;LIMIT 20;">Revenue by Restaurant</button>
                        <button type="button" class="btn btn-outline btn-xs sample-sql-btn" data-sql="SELECT o.order_id, u.name AS customer, r.restaurant_name, o.order_status, o.total_amount, p.payment_method, p.payment_status&#10;FROM orders o&#10;JOIN users u ON o.user_id = u.user_id&#10;JOIN restaurants r ON o.restaurant_id = r.restaurant_id&#10;LEFT JOIN payments p ON o.order_id = p.order_id&#10;ORDER BY o.order_date DESC&#10;LIMIT 25;">Orders &amp; Payments JOIN</button>
                        <button type="button" class="btn btn-outline btn-xs sample-sql-btn" data-sql="DESCRIBE food_items;">DESCRIBE food_items</button>
                    </div>
                    <div style="display:flex;gap:6px;">
                        <button type="button" id="btnFormatManualSql" class="btn btn-outline btn-xs">Format SQL</button>
                        <button type="button" id="btnClearManualSql" class="btn btn-outline btn-xs">Clear</button>
                    </div>
                </div>

                <div class="manual-editor-wrap">
                    <div class="manual-line-nums" id="manualLineNumbers">1</div>
                    <textarea id="manualSqlEditor" class="manual-textarea" spellcheck="false" placeholder="Write a SQL query against food_delivery_db (SELECT, SHOW, DESCRIBE, EXPLAIN, INSERT, UPDATE, DELETE)...">SELECT * FROM `Restaurants` ORDER BY `rating` DESC LIMIT 15;</textarea>
                </div>

                <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;">
                    <span style="font-size:0.8rem;color:#64748b;">
                        Supported: <code>SELECT</code>, <code>WITH</code>, <code>SHOW</code>, <code>DESCRIBE</code>, <code>EXPLAIN</code>, <code>INSERT</code>, <code>UPDATE</code>, <code>DELETE</code>. Press <code>Ctrl+Enter</code> to run.
                    </span>
                    <button type="button" id="btnExecuteManualSql" class="btn btn-primary">Execute SQL (Ctrl+Enter)</button>
                </div>
            </div>
        </div>
    </section>

    <!-- SHARED RESULTS COMPONENT (Common for both Visual Query Builder & Manual SQL Editor) -->
    <jsp:include page="/WEB-INF/jsp/includes/query-results.jsp"/>
</main>

<!-- Confirmation Modal for Unfiltered UPDATE/DELETE -->
<div class="modal-backdrop" id="confirmModal">
    <div class="modal-card">
        <h3 style="margin-bottom:8px;color:#b91c1c;">Confirm Potentially Destructive Query</h3>
        <p id="confirmModalMsg" style="color:#475569;font-size:0.9rem;margin-bottom:16px;"></p>
        <div style="display:flex;justify-content:flex-end;gap:10px;">
            <button type="button" id="btnCancelDestructive" class="btn btn-outline btn-sm">Cancel</button>
            <button type="button" id="btnConfirmDestructive" class="btn btn-primary btn-sm" style="background:#dc2626;border-color:#dc2626;">Yes, Execute</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/query-results.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/query-workspace.js"></script>
<jsp:include page="/WEB-INF/jsp/includes/footer.jsp"/>
