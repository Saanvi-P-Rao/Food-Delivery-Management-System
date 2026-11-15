<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<section class="results-shell" id="sharedResultsComponent">
    <!-- Left: Dynamic Query Results Grid & Execution Messages -->
    <div class="results-card">
        <div class="results-toolbar">
            <div class="results-stats" id="resultStats">
                <span class="stat-chip">Ready</span>
                <span style="font-size:0.84rem;color:#64748b;">Run a Visual Query or Manual SQL statement to view live MySQL results.</span>
            </div>
            <div style="display:flex;gap:8px;align-items:center;">
                <input type="text" id="resultSearch" class="form-control" style="padding:5px 10px;font-size:0.82rem;width:190px;" placeholder="Filter returned rows...">
                <button type="button" id="btnExportCsv" class="btn btn-outline btn-sm" disabled>Export CSV</button>
            </div>
        </div>

        <div class="results-body" id="resultBody">
            <div style="padding:36px 20px;text-align:center;color:#64748b;font-size:0.9rem;">
                No query executed yet. Click the search bar above to open the <strong>Visual SQL Query Builder</strong> or switch to the <strong>Manual SQL Editor</strong>.
            </div>
        </div>

        <div class="results-footer">
            <div id="pageInfo" style="color:#64748b;">Page 1 of 1</div>
            <div style="display:flex;gap:6px;">
                <button type="button" id="btnPrevPage" class="btn btn-outline btn-xs" disabled>&larr; Prev</button>
                <button type="button" id="btnNextPage" class="btn btn-outline btn-xs" disabled>Next &rarr;</button>
            </div>
        </div>
    </div>

    <!-- Right: Shared Query History -->
    <aside class="history-card">
        <div class="results-toolbar">
            <strong style="font-size:0.88rem;color:#0f172a;">Query History</strong>
            <button type="button" id="btnClearHistory" class="btn btn-outline btn-xs">Clear</button>
        </div>
        <div class="history-list" id="queryHistoryList">
            <c:choose>
                <c:when test="${empty history}">
                    <div style="padding:24px 14px;text-align:center;color:#64748b;font-size:0.82rem;">
                        No queries executed in this session yet.
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="h" items="${history}">
                        <div class="history-row" data-sql="${h.sql}">
                            <div style="display:flex;justify-content:space-between;align-items:center;font-size:0.75rem;font-weight:700;">
                                <span>
                                    <span style="color:${h.success ? '#16a34a' : '#dc2626'}">${h.statementType}</span>
                                    <span style="color:#64748b;font-weight:600;margin-left:4px;">[${not empty h.source ? h.source : 'MANUAL'}]</span>
                                </span>
                                <span style="color:#64748b;">${h.executionTimeMs} ms</span>
                            </div>
                            <div class="history-sql" title="${h.sql}">${h.sql}</div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </aside>
</section>
