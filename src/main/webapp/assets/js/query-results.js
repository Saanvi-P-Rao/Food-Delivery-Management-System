(function (window) {
    const ctx = window.APP_CTX || '';
    const statsEl = document.getElementById('resultStats');
    const bodyEl = document.getElementById('resultBody');
    const resultSearch = document.getElementById('resultSearch');
    const exportCsvBtn = document.getElementById('btnExportCsv');
    const prevPageBtn = document.getElementById('btnPrevPage');
    const nextPageBtn = document.getElementById('btnNextPage');
    const pageInfo = document.getElementById('pageInfo');
    const historyListEl = document.getElementById('queryHistoryList');
    const clearHistoryBtn = document.getElementById('btnClearHistory');

    let lastResult = null;
    let filteredRows = [];
    let sortColIndex = -1;
    let sortAsc = true;
    let currentPage = 1;
    const pageSize = 25;
    let historyClickCallback = null;

    function escapeHtml(str) {
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function csvEscape(val) {
        if (val.includes(',') || val.includes('"') || val.includes('\n') || val.includes('\r')) {
            return '"' + val.replace(/"/g, '""') + '"';
        }
        return val;
    }

    function sourceLabel(src) {
        if (src === 'VISUAL') return 'Visual Builder';
        if (src === 'MANUAL') return 'Manual Editor';
        return src || 'SQL';
    }

    function renderNetworkError(msg) {
        if (statsEl) {
            statsEl.innerHTML = `<span class="stat-chip err">Connection Error</span>`;
        }
        if (bodyEl) {
            bodyEl.innerHTML = `<div style="padding:20px;"><div class="alert alert-error">${escapeHtml(msg)}</div></div>`;
        }
        if (exportCsvBtn) exportCsvBtn.disabled = true;
        lastResult = null;
    }

    function render(data) {
        if (!data) return;
        const srcChip = data.source ? `<span class="stat-chip src">${escapeHtml(sourceLabel(data.source))}</span>` : '';

        if (!data.success) {
            statsEl.innerHTML =
                `<span class="stat-chip err">Error (${escapeHtml(data.sqlState || 'SQL')})</span>` +
                srcChip +
                `<span class="stat-chip">Time: ${data.executionTimeMs || 0} ms</span>`;
            const errCode = data.errorCode ? `MySQL Error ${data.errorCode}: ` : '';
            bodyEl.innerHTML =
                `<div style="padding:20px;"><div class="alert alert-error"><strong>${escapeHtml(errCode)}</strong>${escapeHtml(data.errorMessage || 'Query failed.')}</div></div>`;
            if (exportCsvBtn) exportCsvBtn.disabled = true;
            if (pageInfo) pageInfo.textContent = 'Page 1 of 1';
            if (prevPageBtn) prevPageBtn.disabled = true;
            if (nextPageBtn) nextPageBtn.disabled = true;
            lastResult = null;
            return;
        }

        if (!data.hasResultSet) {
            statsEl.innerHTML =
                `<span class="stat-chip ok">${escapeHtml(data.statementType || 'SQL')} OK</span>` +
                srcChip +
                `<span class="stat-chip">Affected Rows: ${data.rowsAffected}</span>` +
                `<span class="stat-chip">Time: ${data.executionTimeMs} ms</span>` +
                `<span class="stat-chip">DB: ${escapeHtml(data.databaseName || 'food_delivery_db')}</span>`;
            bodyEl.innerHTML =
                `<div style="padding:24px;"><div class="alert alert-success">${escapeHtml(data.statusMessage || 'Statement executed successfully.')}</div></div>`;
            if (exportCsvBtn) exportCsvBtn.disabled = true;
            if (pageInfo) pageInfo.textContent = 'Page 1 of 1';
            if (prevPageBtn) prevPageBtn.disabled = true;
            if (nextPageBtn) nextPageBtn.disabled = true;
            lastResult = null;
            return;
        }

        lastResult = data;
        sortColIndex = -1;
        sortAsc = true;
        currentPage = 1;
        if (exportCsvBtn) exportCsvBtn.disabled = false;
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
                if (!isNaN(na) && !isNaN(nb) && String(va).trim() !== '' && String(vb).trim() !== '') {
                    return sortAsc ? na - nb : nb - na;
                }
                return sortAsc ? String(va).localeCompare(String(vb)) : String(vb).localeCompare(String(va));
            });
        }

        const totalPages = Math.max(1, Math.ceil(filteredRows.length / pageSize));
        if (currentPage > totalPages) currentPage = totalPages;
        const start = (currentPage - 1) * pageSize;
        const pageRows = filteredRows.slice(start, start + pageSize);

        const srcChip = lastResult.source ? `<span class="stat-chip src">${escapeHtml(sourceLabel(lastResult.source))}</span>` : '';
        statsEl.innerHTML =
            `<span class="stat-chip ok">${escapeHtml(lastResult.statementType || 'SELECT')} OK</span>` +
            srcChip +
            `<span class="stat-chip">Rows: ${filteredRows.length}${term ? ' (filtered from ' + lastResult.rowsReturned + ')' : ''}</span>` +
            `<span class="stat-chip">Time: ${lastResult.executionTimeMs} ms</span>` +
            `<span class="stat-chip">DB: ${escapeHtml(lastResult.databaseName || 'food_delivery_db')}</span>`;

        const cols = lastResult.columns || [];
        let html = '<table class="result-table"><thead><tr><th>#</th>';
        cols.forEach((col, idx) => {
            const arrow = sortColIndex === idx ? (sortAsc ? ' ▲' : ' ▼') : '';
            const type = lastResult.columnTypes && lastResult.columnTypes[idx] ? lastResult.columnTypes[idx] : '';
            html += `<th data-col="${idx}" title="${escapeHtml(type)}">${escapeHtml(col)}${arrow}</th>`;
        });
        html += '</tr></thead><tbody>';

        if (pageRows.length === 0) {
            html += `<tr><td colspan="${cols.length + 1}" style="text-align:center;padding:28px;color:#64748b;">Query returned 0 rows.</td></tr>`;
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

    async function refreshHistory(onSelectSql) {
        if (onSelectSql) historyClickCallback = onSelectSql;
        if (!historyListEl) return;
        try {
            const resp = await fetch(ctx + '/api/query/history');
            const data = await resp.json();
            if (!data.success) return;
            const items = data.history || [];
            if (items.length === 0) {
                historyListEl.innerHTML = `<div style="padding:24px 14px;text-align:center;color:#64748b;font-size:0.82rem;">No queries executed in this session yet.</div>`;
                return;
            }
            historyListEl.innerHTML = items.slice(0, 30).map(h => `
                <div class="history-row" data-sql="${escapeHtml(h.sql)}">
                    <div style="display:flex;justify-content:space-between;align-items:center;font-size:0.75rem;font-weight:700;">
                        <span>
                            <span style="color:${h.success ? '#16a34a' : '#dc2626'}">${escapeHtml(h.statementType || 'SQL')}</span>
                            <span style="color:#64748b;font-weight:600;margin-left:4px;">[${escapeHtml(h.source || 'MANUAL')}]</span>
                        </span>
                        <span style="color:#64748b;">${h.executionTimeMs} ms</span>
                    </div>
                    <div class="history-sql" title="${escapeHtml(h.sql)}">${escapeHtml(h.sql)}</div>
                </div>
            `).join('');
            bindHistoryClicks();
        } catch (ignored) {}
    }

    function bindHistoryClicks() {
        if (!historyListEl) return;
        historyListEl.querySelectorAll('.history-row').forEach(row => {
            row.addEventListener('click', () => {
                const sql = row.getAttribute('data-sql');
                if (sql && historyClickCallback) {
                    historyClickCallback(sql);
                }
            });
        });
    }

    if (resultSearch) {
        resultSearch.addEventListener('input', () => {
            currentPage = 1;
            applyFilterAndRenderTable();
        });
    }
    if (prevPageBtn) {
        prevPageBtn.addEventListener('click', () => {
            if (currentPage > 1) {
                currentPage--;
                applyFilterAndRenderTable();
            }
        });
    }
    if (nextPageBtn) {
        nextPageBtn.addEventListener('click', () => {
            currentPage++;
            applyFilterAndRenderTable();
        });
    }

    if (exportCsvBtn) {
        exportCsvBtn.addEventListener('click', () => {
            if (!lastResult || !lastResult.hasResultSet) return;
            const lines = [];
            lines.push((lastResult.columns || []).map(csvEscape).join(','));
            filteredRows.forEach(r => lines.push(r.map(v => v === null || v === undefined ? '' : csvEscape(String(v))).join(',')));
            const blob = new Blob([lines.join('\n')], { type: 'text/csv;charset=utf-8;' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'foodexpress_query_result.csv';
            a.click();
            URL.revokeObjectURL(url);
        });
    }

    if (clearHistoryBtn) {
        clearHistoryBtn.addEventListener('click', async () => {
            try {
                await fetch(ctx + '/api/query/history?action=clear', { method: 'POST' });
                refreshHistory();
            } catch (ignored) {}
        });
    }

    bindHistoryClicks();

    window.FoodExpressResults = {
        render,
        renderNetworkError,
        refreshHistory,
        setHistoryClickHandler(fn) {
            historyClickCallback = fn;
            bindHistoryClicks();
        }
    };
})(window);
