<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeSection" value="explorer" scope="request"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Explorer – FoodExpress</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <script>window.APP_CTX = '${pageContext.request.contextPath}';</script>
</head>
<body>
<div class="dash-layout">
    <jsp:include page="/WEB-INF/jsp/includes/admin-sidebar.jsp"/>
    <main class="dash-main">
        <div class="dash-topbar">
            <div>
                <h1 class="dash-title">Database Explorer</h1>
                <p style="color:var(--text-muted);font-size:0.9rem;">
                    Live JDBC <code>DatabaseMetaData</code> &amp; <code>INFORMATION_SCHEMA</code> &bull;
                    Database: <strong>${useSandbox ? sandboxDbName : dbName}</strong> &bull;
                    Status: <strong style="color:${dbConnected ? '#16a34a' : '#dc2626'};">${dbConnected ? 'Connected' : 'Disconnected'}</strong>
                </p>
            </div>
            <div style="display:flex;gap:10px;">
                <a href="${pageContext.request.contextPath}/admin/explorer?sandbox=false" class="btn btn-sm ${!useSandbox ? 'btn-primary' : 'btn-outline'}">Primary DB (${dbName})</a>
                <a href="${pageContext.request.contextPath}/admin/explorer?sandbox=true" class="btn btn-sm ${useSandbox ? 'btn-primary' : 'btn-outline'}">Sandbox DB (${sandboxDbName})</a>
            </div>
        </div>

        <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>

        <div class="panel" id="explorerPreviewPanel">
            <div class="panel-header">
                <h2 class="panel-title" id="explorerPreviewTitle">Select a table below to inspect live MySQL records</h2>
            </div>
            <div id="explorerPreviewBody" style="color:var(--text-muted);font-size:0.9rem;">
                Click <strong>Browse Records</strong> on any table card below to load its actual rows from MySQL.
            </div>
        </div>

        <c:forEach var="t" items="${tables}">
            <div class="panel">
                <div class="panel-header">
                    <div>
                        <h2 class="panel-title">${t.tableName} <span style="font-size:0.8rem;color:#6b7280;font-weight:600;">(${t.tableType} &bull; ${t.recordCount} rows)</span></h2>
                    </div>
                    <button type="button" class="btn btn-primary btn-sm btn-preview-table" data-table="${t.tableName}" data-sandbox="${useSandbox}">Browse Records</button>
                </div>

                <div class="table-wrap" style="margin-bottom:16px;">
                    <table class="data-table">
                        <thead>
                            <tr><th>Column</th><th>Type</th><th>Key</th><th>Nullable</th><th>Default</th><th>Extra</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${t.columns}">
                                <tr>
                                    <td><strong>${c.name}</strong></td>
                                    <td><code>${c.columnType}</code></td>
                                    <td>
                                        <c:if test="${c.primaryKey}"><span class="status-pill" style="background:#fef3c7;color:#92400e;">PK</span></c:if>
                                        <c:if test="${c.foreignKey}"><span class="status-pill" style="background:#e0f2fe;color:#075985;">FK</span></c:if>
                                        <c:if test="${c.unique && !c.primaryKey}"><span class="status-pill" style="background:#f3e8ff;color:#6b21a8;">UQ</span></c:if>
                                    </td>
                                    <td>${c.nullable ? 'YES' : 'NO'}</td>
                                    <td><code>${c.defaultValue}</code></td>
                                    <td>${c.extra}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <c:if test="${not empty t.foreignKeys}">
                    <div style="font-size:0.84rem;color:#4b5563;margin-bottom:8px;">
                        <strong>Foreign Keys:</strong>
                        <c:forEach var="fk" items="${t.foreignKeys}" varStatus="st">
                            <code>${fk.columnName} &rarr; ${fk.referencedTable}(${fk.referencedColumn})</code> [ON DELETE ${fk.deleteRule}]<c:if test="${!st.last}"> &bull; </c:if>
                        </c:forEach>
                    </div>
                </c:if>

                <c:if test="${not empty t.indexes}">
                    <div style="font-size:0.84rem;color:#4b5563;">
                        <strong>Indexes:</strong>
                        <c:forEach var="idx" items="${t.indexes}" varStatus="st">
                            <code>${idx.indexName}(${idx.columnName})</code><c:if test="${!st.last}">, </c:if>
                        </c:forEach>
                    </div>
                </c:if>
            </div>
        </c:forEach>
    </main>
</div>
<script src="${pageContext.request.contextPath}/assets/js/explorer.js"></script>
</body>
</html>
