(function () {
    const ctx = window.APP_CTX || '';
    const sqlInput = document.getElementById('sqlEditor');
    const lineNumbersEl = document.getElementById('sqlLineNumbers');
    const executeBtn = document.getElementById('btnExecuteSql');
    const clearBtn = document.getElementById('btnClearSql');
    const formatBtn = document.getElementById('btnFormatSql');
    const tableSelect = document.getElementById('tableSelector');
    const filterColInput = document.getElementById('filterInput');
    const sandboxToggle = document.getElementById('sandboxToggle');
    const resultSearch = document.getElementById('resultSearch');
    const exportCsvBtn = document.getElementById('btnExportCsv');
    const prevPageBtn = document.getElementById('btnPrevPage');
    const nextPageBtn = document.getElementById('btnNextPage');
    const pageInfo = document.getElementById('pageInfo');

    const confirmModal = document.getElementById('confirmModal');
    const confirmMsg = document.getElementById('confirmModalMsg');
    const confirmYes = document.getElementById('btnConfirmDestructive');
    const confirmNo = document.getElementById('btnCancelDestructive');

    let lastResult = null;
    let filteredRows = [];
    let sortColIndex = -1;
    let sortAsc = true;
    let currentPage = 1;
    const pageSize = 25;
    let pendingSql = null;

    // Schema sidebar expand/collapse
    document.querySelectorAll('.schema-table-header').forEach(hdr => {
        hdr.addEventListener('click', () => {
            hdr.parentElement.classList.toggle('open');
        });
    });

    if (tableSelect) {
        tableSelect.addEventListener('change', () => {
            const tbl = tableSelect.value;
            if (!tbl) return;
            const filter = filterColInput ? filterColInput.value.trim() : '';
            sqlInput.value = filter
                ? `SELECT * FROM \`${tbl}\` WHERE ${filter} LIMIT 100;`
                : `SELECT * FROM \`${tbl}\` LIMIT 100;`;
        });
    }

    if (clearBtn) {
        clearBtn.addEventListener('click', () => {
            sqlInput.value = '';
            sqlInput.focus();
        });
    }

    if (formatBtn) {
        formatBtn.addEventListener('click', () => {
            const keywords = ['SELECT', 'FROM', 'WHERE', 'INNER JOIN', 'LEFT JOIN', 'RIGHT JOIN', 'JOIN', 'ON', 'GROUP BY', 'HAVING', 'ORDER BY', 'LIMIT', 'INSERT INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE FROM'];
            let formatted = sqlInput.value.trim().replace(/\s+/g, ' ');
            keywords.forEach(kw => {
                const regex = new RegExp('\\b' + kw + '\\b', 'gi');
                formatted = formatted.replace(regex, '\n' + kw);
            });
            sqlInput.value = formatted.trim();
        });
    }

    async function runQuery(confirmDestructive = false) {
        const sql = sqlInput.value.trim();
        if (!sql) return;

        executeBtn.disabled = true;
        executeBtn.textContent = 'Running...';

        const params = new URLSearchParams();
        params.append('sql', sql);
        params.append('sandbox', sandboxToggle && sandboxToggle.checked ? 'true' : 'false');
        if (confirmDestructive) params.append('confirmDestructive', 'true');

        try {
            const resp = await fetch(ctx + '/api/admin/sql/execute', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });
            const data = await resp.json();

            if (resp.status === 409 && data.confirmationRequired) {
                pendingSql = sql;
                confirmMsg.textContent = data.errorMessage;
                confirmModal.classList.add('show');
                return;
            }

            renderResult(data);
            refreshHistory();
            if (data.success && !data.hasResultSet && ['CREATE', 'ALTER', 'DROP', 'INSERT', 'UPDATE', 'DELETE'].includes(data.statementType)) {
                refreshSchemaSidebar();
            }
        } catch (err) {
            renderError('Network or server error: ' + err.message);
        } finally {
            executeBtn.disabled = false;
            executeBtn.textContent = 'Execute SQL (Ctrl+Enter)';
        }
    }

    if (executeBtn) {
        executeBtn.addEventListener('click', () => runQuery(false));
    }

    if (sqlInput) {
        function updateLineNumbers() {
            if (!lineNumbersEl) return;
            const lines = sqlInput.value.split('\n').length;
            let nums = '';
            for (let i = 1; i <= lines; i++) nums += i + '\n';
            lineNumbersEl.textContent = nums.trimEnd();
        }
        sqlInput.addEventListener('input', updateLineNumbers);
        updateLineNumbers();

        sqlInput.addEventListener('keydown', (e) => {
            if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
                e.preventDefault();
                runQuery(false);
            }
        });
    }

    if (confirmYes) {
        confirmYes.addEventListener('click', () => {
            confirmModal.classList.remove('show');
            if (pendingSql) {
                sqlInput.value = pendingSql;
                pendingSql = null;
                runQuery(true);
            }
        });
    }
    if (confirmNo) {
        confirmNo.addEventListener('click', () => {
            confirmModal.classList.remove('show');
            pendingSql = null;
        });
    }

    function renderError(msg) {
        const statsEl = document.getElementById('resultStats');
        const bodyEl = document.getElementById('resultBody');
        statsEl.innerHTML = `<span class="stat-chip err">SQL Error</span>`;
        bodyEl.innerHTML = `<div style="padding:20px;"><div class="alert alert-error">${escapeHtml(msg)}</div></div>`;
        lastResult = null;
    }

    function renderResult(data) {
        const statsEl = document.getElementById('resultStats');
        const bodyEl = document.getElementById('resultBody');

        if (!data.success) {
            statsEl.innerHTML = `<span class="stat-chip err">Error (${data.sqlState || 'SQL'})</span><span class="stat-chip">${data.executionTimeMs || 0} ms</span>`;
            bodyEl.innerHTML = `<div style="padding:20px;"><div class="alert alert-error"><strong>MySQL Error ${data.errorCode || ''}:</strong> ${escapeHtml(data.errorMessage)}</div></div>`;
            lastResult = null;
            return;
        }

        if (!data.hasResultSet) {
            statsEl.innerHTML = `<span class="stat-chip ok">${escapeHtml(data.statementType)} OK</span>` +
                `<span class="stat-chip">Rows Affected: ${data.rowsAffected}</span>` +
                `<span class="stat-chip">Time: ${data.executionTimeMs} ms</span>`;
            bodyEl.innerHTML = `<div style="padding:24px;"><div class="alert alert-success">${escapeHtml(data.statusMessage)}</div></div>`;
            lastResult = null;
            return;
        }

        lastResult = data;
        sortColIndex = -1;
        sortAsc = true;
        currentPage = 1;
        applyFilterAndRenderTable();
    }

    function applyFilterAndRenderTable() {
        if (!lastResult || !lastResult.hasResultSet) return;
        const term = resultSearch ? resultSearch.value.trim().toLowerCase() : '';
        const rows = lastResult.rows || [];
        filteredRows = term
            ? rows.filter(r => r.some(cell => cell !== null && String(cell).toLowerCase().includes(term)))
            : rows.slice();

        if (sortColIndex >= 0) {
            filteredRows.sort((a, b) => {
                const va = a[sortColIndex];
                const vb = b[sortColIndex];
                if (va === null && vb === null) return 0;
                if (va === null) return sortAsc ? -1 : 1;
                if (vb === null) return sortAsc ? 1 : -1;
                const na = Number(va), nb = Number(vb);
                if (!isNaN(na) && !isNaN(nb)) return sortAsc ? na - nb : nb - na;
                return sortAsc ? String(va).localeCompare(String(vb)) : String(vb).localeCompare(String(va));
            });
        }

        const totalPages = Math.max(1, Math.ceil(filteredRows.length / pageSize));
        if (currentPage > totalPages) currentPage = totalPages;
        const start = (currentPage - 1) * pageSize;
        const pageRows = filteredRows.slice(start, start + pageSize);

        const statsEl = document.getElementById('resultStats');
        statsEl.innerHTML = `<span class="stat-chip ok">${escapeHtml(lastResult.statementType)} OK</span>` +
            `<span class="stat-chip">Rows: ${filteredRows.length}${term ? ' (filtered from ' + lastResult.rowsReturned + ')' : ''}</span>` +
            `<span class="stat-chip">Time: ${lastResult.executionTimeMs} ms</span>` +
            `<span class="stat-chip">DB: ${escapeHtml(lastResult.databaseName)}</span>`;

        let html = '<table class="result-table"><thead><tr><th>#</th>';
        lastResult.columns.forEach((col, idx) => {
            const arrow = sortColIndex === idx ? (sortAsc ? ' ▲' : ' ▼') : '';
            const type = lastResult.columnTypes && lastResult.columnTypes[idx] ? lastResult.columnTypes[idx] : '';
            html += `<th data-col="${idx}" title="${escapeHtml(type)}">${escapeHtml(col)}${arrow}</th>`;
        });
        html += '</tr></thead><tbody>';

        if (pageRows.length === 0) {
            html += `<tr><td colspan="${lastResult.columns.length + 1}" style="text-align:center;padding:28px;color:#64748b;">No matching records returned.</td></tr>`;
        } else {
            pageRows.forEach((row, rIdx) => {
                html += `<tr><td style="color:#94a3b8;font-weight:600;">${start + rIdx + 1}</td>`;
                row.forEach(cell => {
                    if (cell === null || cell === undefined) {
                        html += '<td><span class="null-pill">NULL</span></td>';
                    } else {
                        html += `<td title="${escapeHtml(String(cell))}">${escapeHtml(String(cell))}</td>`;
                    }
                });
                html += '</tr>';
            });
        }
        html += '</tbody></table>';

        const bodyEl = document.getElementById('resultBody');
        bodyEl.innerHTML = html;

        bodyEl.querySelectorAll('th[data-col]').forEach(th => {
            th.addEventListener('click', () => {
                const colIdx = parseInt(th.getAttribute('data-col'), 10);
                if (sortColIndex === colIdx) {
                    sortAsc = !sortAsc;
                } else {
                    sortColIndex = colIdx;
                    sortAsc = true;
                }
                applyFilterAndRenderTable();
            });
        });

        if (pageInfo) pageInfo.textContent = `Page ${currentPage} of ${totalPages}`;
        if (prevPageBtn) prevPageBtn.disabled = currentPage <= 1;
        if (nextPageBtn) nextPageBtn.disabled = currentPage >= totalPages;
    }

    if (resultSearch) resultSearch.addEventListener('input', () => { currentPage = 1; applyFilterAndRenderTable(); });
    if (prevPageBtn) prevPageBtn.addEventListener('click', () => { if (currentPage > 1) { currentPage--; applyFilterAndRenderTable(); } });
    if (nextPageBtn) nextPageBtn.addEventListener('click', () => { currentPage++; applyFilterAndRenderTable(); });

    if (exportCsvBtn) {
        exportCsvBtn.addEventListener('click', () => {
            if (!lastResult || !lastResult.hasResultSet) return;
            const lines = [];
            lines.push(lastResult.columns.map(csvEscape).join(','));
            filteredRows.forEach(r => lines.push(r.map(v => v === null ? '' : csvEscape(String(v))).join(',')));
            const blob = new Blob([lines.join('\n')], { type: 'text/csv;charset=utf-8;' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'foodexpress_query_result.csv';
            a.click();
            URL.revokeObjectURL(url);
        });
    }

    async function refreshHistory() {
        const listEl = document.getElementById('queryHistoryList');
        if (!listEl) return;
        try {
            const resp = await fetch(ctx + '/api/admin/sql/history');
            const data = await resp.json();
            if (!data.success) return;
            listEl.innerHTML = data.history.slice(0, 12).map(h => `
                <div class="history-item" data-sql="${escapeHtml(h.sql)}" style="padding:8px 10px;border-bottom:1px solid #e5e7eb;cursor:pointer;font-size:0.8rem;">
                    <div style="display:flex;justify-content:space-between;font-weight:700;">
                        <span style="color:${h.success ? '#16a34a' : '#dc2626'}">${escapeHtml(h.statementType)}</span>
                        <span style="color:#6b7280;">${h.executionTimeMs}ms</span>
                    </div>
                    <div style="font-family:monospace;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;color:#334155;">${escapeHtml(h.sql)}</div>
                </div>
            `).join('');
            listEl.querySelectorAll('.history-item').forEach(el => {
                el.addEventListener('click', () => {
                    sqlInput.value = el.getAttribute('data-sql');
                });
            });
        } catch (ignored) {}
    }

    async function refreshSchemaSidebar() {
        try {
            const sandbox = sandboxToggle && sandboxToggle.checked ? 'true' : 'false';
            const resp = await fetch(ctx + '/api/admin/explorer/tables?sandbox=' + sandbox);
            const data = await resp.json();
            if (!data.success) return;
            const dbNameLabel = document.getElementById('sidebarDbName');
            if (dbNameLabel) dbNameLabel.textContent = data.databaseName;
            const tree = document.getElementById('schemaTree');
            if (!tree) return;
            tree.innerHTML = data.tables.map(t => `
                <div class="schema-table-item">
                    <div class="schema-table-header">
                        <span>${escapeHtml(t.tableName)}</span>
                        <span style="font-size:0.74rem;color:#94a3b8;">${t.recordCount}</span>
                    </div>
                    <div class="schema-cols">
                        ${t.columns.map(c => `
                            <div class="schema-col-row">
                                <span>
                                    ${c.primaryKey ? '<span class="key-badge key-pk">PK</span>' : ''}
                                    ${c.foreignKey ? '<span class="key-badge key-fk">FK</span>' : ''}
                                    ${escapeHtml(c.name)}
                                </span>
                                <span class="col-type">${escapeHtml(c.dataType)}</span>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `).join('');
            tree.querySelectorAll('.schema-table-header').forEach(hdr => {
                hdr.addEventListener('click', () => hdr.parentElement.classList.toggle('open'));
            });
        } catch (ignored) {}
    }

    if (sandboxToggle) {
        sandboxToggle.addEventListener('change', refreshSchemaSidebar);
    }

    // Sample query quick-load buttons
    document.querySelectorAll('.sample-sql-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            sqlInput.value = btn.getAttribute('data-sql');
        });
    });

    function csvEscape(val) {
        if (val.includes(',') || val.includes('"') || val.includes('\n')) {
            return '"' + val.replace(/"/g, '""') + '"';
        }
        return val;
    }

    function escapeHtml(str) {
        return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
})();
