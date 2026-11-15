<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeSection" value="sql-console" scope="request"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SQL Query Execution Console – FoodExpress</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sql-console.css">
    <script>window.APP_CTX = '${pageContext.request.contextPath}';</script>
</head>
<body>
<div class="dash-layout">
    <jsp:include page="/WEB-INF/jsp/includes/admin-sidebar.jsp"/>
    <main class="dash-main" style="padding:20px 24px;">
        <div class="dash-topbar" style="margin-bottom:16px;">
            <div>
                <h1 class="dash-title" style="font-size:1.4rem;">SQL Query Execution Console</h1>
                <p style="color:var(--text-muted);font-size:0.86rem;">Execute live SQL queries against MySQL via JDBC <code>Statement.execute()</code> &amp; <code>ResultSetMetaData</code></p>
            </div>
            <label style="display:flex;align-items:center;gap:8px;background:#fff;padding:8px 14px;border-radius:10px;border:1px solid #e5e7eb;font-size:0.86rem;font-weight:700;cursor:pointer;">
                <input type="checkbox" id="sandboxToggle">
                <span>Use Disposable Sandbox DB (<code>${sandboxDbName}</code>)</span>
            </label>
        </div>

        <div class="console-shell">
            <!-- LEFT SIDEBAR: Schema Explorer -->
            <aside class="schema-sidebar">
                <div class="db-status-box">
                    <div style="font-weight:700;color:#fff;margin-bottom:4px;">
                        <span class="db-status-dot ${dbConnected ? 'dot-online' : 'dot-offline'}"></span>
                        <span id="sidebarDbName">${dbName}</span>
                    </div>
                    <div style="color:#94a3b8;font-size:0.78rem;">
                        Status: ${dbConnected ? 'Connected' : 'Disconnected'}<br>
                        MySQL Version: <strong>${not empty mysqlVersion ? mysqlVersion : 'N/A'}</strong><br>
                        Total Tables: <strong>${tables.size()}</strong>
                    </div>
                </div>
                <div style="font-size:0.74rem;text-transform:uppercase;letter-spacing:0.06em;color:#94a3b8;font-weight:700;margin-bottom:8px;">
                    Tables &amp; Columns
                </div>
                <div class="schema-tree" id="schemaTree">
                    <c:forEach var="t" items="${tables}">
                        <div class="schema-table-item">
                            <div class="schema-table-header">
                                <span>${t.tableName}</span>
                                <span style="font-size:0.74rem;color:#94a3b8;">${t.recordCount}</span>
                            </div>
                            <div class="schema-cols">
                                <c:forEach var="c" items="${t.columns}">
                                    <div class="schema-col-row">
                                        <span>
                                            <c:if test="${c.primaryKey}"><span class="key-badge key-pk">PK</span></c:if>
                                            <c:if test="${c.foreignKey}"><span class="key-badge key-fk">FK</span></c:if>
                                            ${c.name}
                                        </span>
                                        <span class="col-type">${c.dataType}</span>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div style="margin-top:12px;border-top:1px solid #1e293b;padding-top:10px;">
                    <div style="font-size:0.74rem;text-transform:uppercase;color:#94a3b8;font-weight:700;margin-bottom:6px;">Recent History</div>
                    <div id="queryHistoryList" style="max-height:150px;overflow-y:auto;background:#fff;border-radius:8px;color:#111827;">
                        <c:forEach var="h" items="${history}">
                            <div class="history-item" data-sql="${h.sql}" style="padding:8px 10px;border-bottom:1px solid #e5e7eb;cursor:pointer;font-size:0.8rem;">
                                <div style="display:flex;justify-content:space-between;font-weight:700;">
                                    <span style="color:${h.success ? '#16a34a' : '#dc2626'}">${h.statementType}</span>
                                    <span style="color:#6b7280;">${h.executionTimeMs}ms</span>
                                </div>
                                <div style="font-family:monospace;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;color:#334155;">${h.sql}</div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </aside>

            <!-- MAIN EDITOR & RESULT GRID -->
            <div class="console-main">
                <div class="editor-card">
                    <div class="editor-toolbar">
                        <div class="editor-controls">
                            <select id="tableSelector" class="form-select" style="padding:7px 10px;font-size:0.84rem;">
                                <option value="">Quick Select Table...</option>
                                <c:forEach var="t" items="${tables}">
                                    <option value="${t.tableName}">${t.tableName}</option>
                                </c:forEach>
                            </select>
                            <input type="text" id="filterInput" class="form-control" style="padding:7px 10px;font-size:0.84rem;width:200px;" placeholder="Optional WHERE condition...">
                            <button type="button" id="btnFormatSql" class="btn btn-outline btn-sm">Format SQL</button>
                            <button type="button" id="btnClearSql" class="btn btn-outline btn-sm">Clear</button>
                        </div>
                        <button type="button" id="btnExecuteSql" class="btn btn-primary btn-sm">Execute SQL (Ctrl+Enter)</button>
                    </div>

                    <div style="padding:8px 14px;background:#f8fafc;border-bottom:1px solid #e5e7eb;display:flex;flex-wrap:wrap;gap:6px;">
                        <button type="button" class="btn btn-outline btn-sm sample-sql-btn" data-sql="SELECT * FROM Food_Items;">SELECT * FROM Food_Items</button>
                        <button type="button" class="btn btn-outline btn-sm sample-sql-btn" data-sql="SELECT r.name AS restaurant_name, COUNT(f.food_id) AS item_count FROM Restaurants r LEFT JOIN Food_Items f ON r.restaurant_id = f.restaurant_id GROUP BY r.restaurant_id, r.name;">Restaurants + FOOD COUNT</button>
                        <button type="button" class="btn btn-outline btn-sm sample-sql-btn" data-sql="SELECT r.name AS Restaurants, COUNT(o.order_id) AS Orders, SUM(o.total_amount) AS revenue_inr FROM Restaurants r INNER JOIN Orders o ON r.restaurant_id = o.restaurant_id WHERE o.order_status <> 'CANCELLED' GROUP BY r.restaurant_id, r.name ORDER BY revenue_inr DESC;">JOIN + GROUP BY</button>
                        <button type="button" class="btn btn-outline btn-sm sample-sql-btn" data-sql="SELECT u.full_name, u.city, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS spent FROM USER u JOIN Orders o ON u.user_id = o.user_id GROUP BY u.user_id, u.full_name, u.city HAVING spent > (SELECT AVG(total_amount) FROM Orders) ORDER BY spent DESC;">Subquery + HAVING</button>
                    </div>

                    <div style="display:flex;background:#0f172a;">
                        <div id="sqlLineNumbers" style="padding:16px 10px;background:#0b1120;color:#64748b;font-family:'JetBrains Mono','Fira Code',Consolas,monospace;font-size:0.94rem;line-height:1.55;text-align:right;user-select:none;min-width:44px;border-right:1px solid #1e293b;">1</div>
                        <textarea id="sqlEditor" class="sql-textarea" spellcheck="false">SELECT * FROM Food_Items;</textarea>
                    </div>
                </div>

                <div class="result-card">
                    <div class="result-topbar">
                        <div class="result-stats" id="resultStats">
                            <span class="stat-chip">Ready to execute SQL</span>
                        </div>
                        <div style="display:flex;gap:8px;align-items:center;">
                            <input type="text" id="resultSearch" class="form-control" style="padding:6px 10px;font-size:0.82rem;width:190px;" placeholder="Filter result rows...">
                            <button type="button" id="btnExportCsv" class="btn btn-outline btn-sm">Export CSV</button>
                        </div>
                    </div>
                    <div class="result-grid-wrap" id="resultBody">
                        <div style="padding:36px;text-align:center;color:#64748b;font-size:0.92rem;">
                            Write any valid MySQL query above and click <strong>Execute SQL</strong> (or press <code>Ctrl+Enter</code>).
                        </div>
                    </div>
                    <div class="result-footer">
                        <span id="pageInfo">Page 1 of 1</span>
                        <div style="display:flex;gap:6px;">
                            <button type="button" id="btnPrevPage" class="btn btn-outline btn-sm" disabled>Prev</button>
                            <button type="button" id="btnNextPage" class="btn btn-outline btn-sm" disabled>Next</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Destructive Query Confirmation Modal -->
<div class="modal-backdrop" id="confirmModal">
    <div class="modal-box">
        <h3 style="margin-bottom:10px;color:#b91c1c;">Confirm Destructive SQL Operation</h3>
        <p id="confirmModalMsg" style="font-size:0.92rem;color:#374151;margin-bottom:20px;"></p>
        <div style="display:flex;justify-content:flex-end;gap:10px;">
            <button type="button" id="btnCancelDestructive" class="btn btn-outline btn-sm">Cancel</button>
            <button type="button" id="btnConfirmDestructive" class="btn btn-danger btn-sm">Yes, Execute Query</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/sql-console.js"></script>
</body>
</html>
