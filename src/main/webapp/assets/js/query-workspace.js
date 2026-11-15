(function () {
    const ctx = window.APP_CTX || '';

    // Mode switching & placeholder trigger
    const placeholderBar = document.getElementById('vbPlaceholderBar');
    const tabVisualBtn = document.getElementById('tabBtnVisual');
    const tabManualBtn = document.getElementById('tabBtnManual');
    const panelVisual = document.getElementById('panelVisualBuilder');
    const panelManual = document.getElementById('panelManualEditor');

    // Visual Builder elements
    const vbTableSelect = document.getElementById('vbTableSelect');
    const vbColumnsList = document.getElementById('vbColumnsList');
    const vbSelectAllCols = document.getElementById('vbSelectAllCols');
    const vbClearCols = document.getElementById('vbClearCols');
    const vbFiltersList = document.getElementById('vbFiltersList');
    const vbAddFilterBtn = document.getElementById('vbAddFilterBtn');
    const vbGroupByList = document.getElementById('vbGroupByList');
    const vbOrderByCol = document.getElementById('vbOrderByCol');
    const vbOrderByDir = document.getElementById('vbOrderByDir');
    const vbLimitInput = document.getElementById('vbLimitInput');
    const vbGeneratedSql = document.getElementById('vbGeneratedSql');
    const vbExecuteBtn = document.getElementById('vbExecuteBtn');
    const vbSendToManualBtn = document.getElementById('vbSendToManualBtn');
    const vbResetBtn = document.getElementById('vbResetBtn');

    // Manual Editor elements
    const manualEditor = document.getElementById('manualSqlEditor');
    const manualLineNums = document.getElementById('manualLineNumbers');
    const manualExecBtn = document.getElementById('btnExecuteManualSql');
    const manualFormatBtn = document.getElementById('btnFormatManualSql');
    const manualClearBtn = document.getElementById('btnClearManualSql');

    // Confirmation Modal
    const confirmModal = document.getElementById('confirmModal');
    const confirmMsg = document.getElementById('confirmModalMsg');
    const confirmYes = document.getElementById('btnConfirmDestructive');
    const confirmNo = document.getElementById('btnCancelDestructive');

    let currentColumns = []; // [{ name, dataType, columnType, primaryKey, foreignKey }]
    let pendingManualSql = null;

    function switchMode(mode, openPanel) {
        const isVisual = mode === 'visual';
        tabVisualBtn.classList.toggle('active', isVisual);
        tabManualBtn.classList.toggle('active', !isVisual);
        if (openPanel !== false) {
            panelVisual.classList.toggle('active', isVisual);
            panelManual.classList.toggle('active', !isVisual);
        }
        if (placeholderBar) {
            placeholderBar.classList.toggle('active', isVisual && panelVisual.classList.contains('active'));
        }
    }

    if (placeholderBar) {
        placeholderBar.addEventListener('click', () => {
            switchMode('visual', true);
            if (vbTableSelect && !vbTableSelect.value && vbTableSelect.options.length > 1) {
                vbTableSelect.selectedIndex = 1;
                loadColumnsForTable(vbTableSelect.value);
            }
            if (vbTableSelect) vbTableSelect.focus();
        });
    }

    if (tabVisualBtn) {
        tabVisualBtn.addEventListener('click', () => switchMode('visual', true));
    }
    if (tabManualBtn) {
        tabManualBtn.addEventListener('click', () => switchMode('manual', true));
    }

    // Table pills in header strip -> open Visual Builder with that table
    document.querySelectorAll('.qms-table-pill[data-table]').forEach(pill => {
        pill.addEventListener('click', () => {
            const tbl = pill.getAttribute('data-table');
            switchMode('visual', true);
            if (vbTableSelect) {
                vbTableSelect.value = tbl;
                loadColumnsForTable(tbl);
            }
        });
    });

    // Dynamically load columns when table changes
    async function loadColumnsForTable(tableName) {
        currentColumns = [];
        vbFiltersList.innerHTML = '';
        if (!tableName) {
            vbColumnsList.innerHTML = '<div style="color:#64748b;font-size:0.82rem;padding:8px;">Select a table to load columns.</div>';
            vbGroupByList.innerHTML = '<span style="color:#64748b;font-size:0.78rem;">Select a table first.</span>';
            vbOrderByCol.innerHTML = '<option value="">-- None --</option>';
            updateGeneratedSqlPreview();
            return;
        }

        vbColumnsList.innerHTML = '<div style="color:#64748b;font-size:0.82rem;padding:8px;">Loading columns from MySQL...</div>';
        try {
            const resp = await fetch(ctx + '/api/query/columns?table=' + encodeURIComponent(tableName));
            const data = await resp.json();
            if (!data.success) {
                vbColumnsList.innerHTML = `<div class="alert alert-error" style="font-size:0.8rem;">${escapeHtml(data.error || 'Failed to load columns')}</div>`;
                return;
            }
            currentColumns = data.columns || [];
            renderColumnsUI();
            renderGroupByUI();
            renderOrderByUI();
            updateGeneratedSqlPreview();
        } catch (err) {
            vbColumnsList.innerHTML = `<div class="alert alert-error" style="font-size:0.8rem;">Error loading columns: ${escapeHtml(err.message)}</div>`;
        }
    }

    function renderColumnsUI() {
        if (currentColumns.length === 0) {
            vbColumnsList.innerHTML = '<div style="color:#64748b;font-size:0.82rem;">No columns available.</div>';
            return;
        }
        vbColumnsList.innerHTML = currentColumns.map(c => {
            const badge = c.primaryKey ? '<span class="key-badge key-pk">PK</span>'
                : (c.foreignKey ? '<span class="key-badge key-fk">FK</span>' : '');
            return `
                <div class="vb-col-item">
                    <label title="${escapeHtml(c.columnType || c.dataType)}">
                        <input type="checkbox" class="vb-col-check" value="${escapeHtml(c.name)}" checked>
                        ${badge}
                        <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${escapeHtml(c.name)}</span>
                    </label>
                    <span class="vb-col-type">${escapeHtml(c.dataType)}</span>
                    <select class="vb-agg-select" data-col="${escapeHtml(c.name)}" title="Aggregate function">
                        <option value="">Raw</option>
                        <option value="COUNT">COUNT</option>
                        <option value="SUM">SUM</option>
                        <option value="AVG">AVG</option>
                        <option value="MIN">MIN</option>
                        <option value="MAX">MAX</option>
                    </select>
                </div>
            `;
        }).join('');

        vbColumnsList.querySelectorAll('.vb-col-check, .vb-agg-select').forEach(el => {
            el.addEventListener('change', updateGeneratedSqlPreview);
        });
    }

    function renderGroupByUI() {
        vbGroupByList.innerHTML = currentColumns.map(c => `
            <label class="vb-groupby-pill">
                <input type="checkbox" class="vb-groupby-check" value="${escapeHtml(c.name)}">
                <span>${escapeHtml(c.name)}</span>
            </label>
        `).join('');
        vbGroupByList.querySelectorAll('.vb-groupby-check').forEach(el => {
            el.addEventListener('change', updateGeneratedSqlPreview);
        });
    }

    function renderOrderByUI() {
        const opts = ['<option value="">-- None --</option>']
            .concat(currentColumns.map(c => `<option value="${escapeHtml(c.name)}">${escapeHtml(c.name)}</option>`));
        vbOrderByCol.innerHTML = opts.join('');
    }

    function addFilterRow() {
        if (!vbTableSelect.value || currentColumns.length === 0) return;
        const idx = vbFiltersList.children.length;
        const row = document.createElement('div');
        row.className = 'vb-filter-row';

        const colOptions = currentColumns.map(c => `<option value="${escapeHtml(c.name)}">${escapeHtml(c.name)}</option>`).join('');
        row.innerHTML = `
            <select class="form-select vb-f-conn" style="padding:5px 6px;font-size:0.8rem;${idx === 0 ? 'visibility:hidden;' : ''}">
                <option value="AND">AND</option>
                <option value="OR">OR</option>
            </select>
            <select class="form-select vb-f-col" style="padding:5px 6px;font-size:0.82rem;">${colOptions}</select>
            <select class="form-select vb-f-op" style="padding:5px 6px;font-size:0.82rem;">
                <option value="=">=</option>
                <option value="!=">!=</option>
                <option value=">">&gt;</option>
                <option value=">=">&gt;=</option>
                <option value="<">&lt;</option>
                <option value="<=">&lt;=</option>
                <option value="LIKE">LIKE</option>
                <option value="NOT LIKE">NOT LIKE</option>
                <option value="IN">IN (a,b)</option>
                <option value="NOT IN">NOT IN</option>
                <option value="BETWEEN">BETWEEN</option>
                <option value="IS NULL">IS NULL</option>
                <option value="IS NOT NULL">IS NOT NULL</option>
            </select>
            <div class="vb-f-vals" style="display:flex;gap:6px;">
                <input type="text" class="form-control vb-f-val1" style="padding:5px 8px;font-size:0.82rem;" placeholder="Value...">
                <input type="text" class="form-control vb-f-val2" style="padding:5px 8px;font-size:0.82rem;display:none;" placeholder="End value...">
            </div>
            <button type="button" class="btn btn-outline btn-xs vb-f-remove" title="Remove condition">&times;</button>
        `;

        const opSel = row.querySelector('.vb-f-op');
        const val1 = row.querySelector('.vb-f-val1');
        const val2 = row.querySelector('.vb-f-val2');

        opSel.addEventListener('change', () => {
            const op = opSel.value;
            if (op === 'IS NULL' || op === 'IS NOT NULL') {
                val1.style.display = 'none';
                val2.style.display = 'none';
            } else if (op === 'BETWEEN') {
                val1.style.display = 'block';
                val1.placeholder = 'Start value...';
                val2.style.display = 'block';
            } else if (op === 'IN' || op === 'NOT IN') {
                val1.style.display = 'block';
                val1.placeholder = 'Comma-separated (e.g. Delhi, Mumbai)';
                val2.style.display = 'none';
            } else {
                val1.style.display = 'block';
                val1.placeholder = op.includes('LIKE') ? 'Pattern (e.g. %Biryani%)' : 'Value...';
                val2.style.display = 'none';
            }
            updateGeneratedSqlPreview();
        });

        row.querySelectorAll('select, input').forEach(el => {
            el.addEventListener('change', updateGeneratedSqlPreview);
            el.addEventListener('input', updateGeneratedSqlPreview);
        });

        row.querySelector('.vb-f-remove').addEventListener('click', () => {
            row.remove();
            // Hide connector on first remaining row
            Array.from(vbFiltersList.children).forEach((r, i) => {
                const c = r.querySelector('.vb-f-conn');
                if (c) c.style.visibility = i === 0 ? 'hidden' : 'visible';
            });
            updateGeneratedSqlPreview();
        });

        vbFiltersList.appendChild(row);
        updateGeneratedSqlPreview();
    }

    function buildVisualQueryPayload() {
        const table = vbTableSelect ? vbTableSelect.value : '';
        const columns = [];
        vbColumnsList.querySelectorAll('.vb-col-item').forEach(item => {
            const chk = item.querySelector('.vb-col-check');
            const aggSel = item.querySelector('.vb-agg-select');
            if (chk && chk.checked) {
                const agg = aggSel ? aggSel.value : '';
                columns.push({
                    column: chk.value,
                    aggregate: agg,
                    alias: agg ? (agg.toLowerCase() + '_' + chk.value) : ''
                });
            }
        });

        const filters = [];
        vbFiltersList.querySelectorAll('.vb-filter-row').forEach(row => {
            const op = row.querySelector('.vb-f-op').value;
            const val1 = row.querySelector('.vb-f-val1').value;
            const val2 = row.querySelector('.vb-f-val2').value;
            if (op !== 'IS NULL' && op !== 'IS NOT NULL' && val1.trim() === '') {
                return; // skip incomplete filter in preview unless null check
            }
            filters.push({
                connector: row.querySelector('.vb-f-conn').value,
                column: row.querySelector('.vb-f-col').value,
                operator: op,
                value: val1,
                value2: val2
            });
        });

        const groupBy = [];
        vbGroupByList.querySelectorAll('.vb-groupby-check:checked').forEach(chk => {
            groupBy.push(chk.value);
        });

        const orderBy = [];
        if (vbOrderByCol && vbOrderByCol.value) {
            orderBy.push({
                column: vbOrderByCol.value,
                direction: vbOrderByDir ? vbOrderByDir.value : 'ASC'
            });
        }

        const limitVal = parseInt(vbLimitInput ? vbLimitInput.value : '100', 10);
        const limit = isNaN(limitVal) ? 100 : Math.max(1, Math.min(limitVal, 1000));

        return { table, columns, filters, groupBy, orderBy, limit };
    }

    function formatLiteralJs(raw) {
        const t = String(raw).trim();
        if (/^(true|false)$/i.test(t)) return t.toUpperCase();
        if (/^-?\d+(\.\d+)?$/.test(t)) return t;
        return "'" + t.replace(/\\/g, '\\\\').replace(/'/g, "''") + "'";
    }

    function generateSqlPreviewText(payload) {
        if (!payload.table) {
            return '-- Select a database table above to generate SQL automatically';
        }
        let selectPart = '*';
        if (payload.columns.length > 0 && payload.columns.length <= currentColumns.length) {
            const allRaw = payload.columns.length === currentColumns.length && payload.columns.every(c => !c.aggregate);
            if (!allRaw) {
                selectPart = payload.columns.map(c => {
                    if (c.aggregate) {
                        return `${c.aggregate}(\`${c.column}\`) AS \`${c.alias}\``;
                    }
                    return `\`${c.column}\``;
                }).join(', ');
            }
        }

        let sql = `SELECT ${selectPart}\nFROM \`${payload.table}\``;

        if (payload.filters.length > 0) {
            const clauses = payload.filters.map((f, idx) => {
                let pred = '';
                if (f.operator === 'IS NULL' || f.operator === 'IS NOT NULL') {
                    pred = `\`${f.column}\` ${f.operator}`;
                } else if (f.operator === 'BETWEEN') {
                    pred = `\`${f.column}\` BETWEEN ${formatLiteralJs(f.value)} AND ${formatLiteralJs(f.value2 || f.value)}`;
                } else if (f.operator === 'IN' || f.operator === 'NOT IN') {
                    const vals = f.value.split(',').map(v => v.trim()).filter(Boolean).map(formatLiteralJs);
                    pred = `\`${f.column}\` ${f.operator} (${vals.join(', ') || "''"})`;
                } else {
                    pred = `\`${f.column}\` ${f.operator} ${formatLiteralJs(f.value)}`;
                }
                return idx === 0 ? pred : `${f.connector} ${pred}`;
            });
            sql += `\nWHERE ${clauses.join('\n  ')}`;
        }

        if (payload.groupBy.length > 0) {
            sql += `\nGROUP BY ${payload.groupBy.map(g => `\`${g}\``).join(', ')}`;
        }

        if (payload.orderBy.length > 0) {
            sql += `\nORDER BY ${payload.orderBy.map(o => `\`${o.column}\` ${o.direction}`).join(', ')}`;
        }

        sql += `\nLIMIT ${payload.limit};`;
        return sql;
    }

    function updateGeneratedSqlPreview() {
        if (!vbGeneratedSql) return;
        const payload = buildVisualQueryPayload();
        vbGeneratedSql.textContent = generateSqlPreviewText(payload);
    }

    if (vbTableSelect) {
        vbTableSelect.addEventListener('change', () => loadColumnsForTable(vbTableSelect.value));
    }
    if (vbSelectAllCols) {
        vbSelectAllCols.addEventListener('click', () => {
            vbColumnsList.querySelectorAll('.vb-col-check').forEach(c => { c.checked = true; });
            updateGeneratedSqlPreview();
        });
    }
    if (vbClearCols) {
        vbClearCols.addEventListener('click', () => {
            vbColumnsList.querySelectorAll('.vb-col-check').forEach(c => { c.checked = false; });
            updateGeneratedSqlPreview();
        });
    }
    if (vbAddFilterBtn) {
        vbAddFilterBtn.addEventListener('click', addFilterRow);
    }
    if (vbOrderByCol) vbOrderByCol.addEventListener('change', updateGeneratedSqlPreview);
    if (vbOrderByDir) vbOrderByDir.addEventListener('change', updateGeneratedSqlPreview);
    if (vbLimitInput) vbLimitInput.addEventListener('input', updateGeneratedSqlPreview);

    if (vbResetBtn) {
        vbResetBtn.addEventListener('click', () => {
            vbFiltersList.innerHTML = '';
            if (vbOrderByCol) vbOrderByCol.value = '';
            if (vbOrderByDir) vbOrderByDir.value = 'ASC';
            if (vbLimitInput) vbLimitInput.value = '100';
            vbGroupByList.querySelectorAll('.vb-groupby-check').forEach(c => { c.checked = false; });
            vbColumnsList.querySelectorAll('.vb-col-check').forEach(c => { c.checked = true; });
            vbColumnsList.querySelectorAll('.vb-agg-select').forEach(s => { s.value = ''; });
            updateGeneratedSqlPreview();
        });
    }

    if (vbSendToManualBtn) {
        vbSendToManualBtn.addEventListener('click', () => {
            const sql = vbGeneratedSql ? vbGeneratedSql.textContent.trim() : '';
            if (!sql || sql.startsWith('--')) return;
            loadIntoManualEditor(sql);
        });
    }

    if (vbExecuteBtn) {
        vbExecuteBtn.addEventListener('click', async () => {
            const payload = buildVisualQueryPayload();
            if (!payload.table) {
                window.FoodExpressResults.renderNetworkError('Please select a database table before executing.');
                return;
            }
            vbExecuteBtn.disabled = true;
            vbExecuteBtn.textContent = 'Executing...';
            try {
                const resp = await fetch(ctx + '/api/query/execute', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        source: 'VISUAL',
                        visualQuery: payload
                    })
                });
                const data = await resp.json();
                window.FoodExpressResults.render(data);
                window.FoodExpressResults.refreshHistory(loadIntoManualEditor);
            } catch (err) {
                window.FoodExpressResults.renderNetworkError('Failed to execute visual query: ' + err.message);
            } finally {
                vbExecuteBtn.disabled = false;
                vbExecuteBtn.textContent = 'Execute Generated Query';
            }
        });
    }

    // Manual SQL Editor logic
    function updateLineNumbers() {
        if (!manualEditor || !manualLineNums) return;
        const lines = manualEditor.value.split('\n').length;
        let nums = '';
        for (let i = 1; i <= lines; i++) nums += i + '\n';
        manualLineNums.textContent = nums.trimEnd();
    }

    function loadIntoManualEditor(sql) {
        if (!manualEditor) return;
        manualEditor.value = sql;
        updateLineNumbers();
        switchMode('manual', true);
        manualEditor.focus();
    }

    async function executeManualSql(confirmDestructive) {
        const sql = manualEditor ? manualEditor.value.trim() : '';
        if (!sql) return;

        manualExecBtn.disabled = true;
        manualExecBtn.textContent = 'Executing...';

        const params = new URLSearchParams();
        params.append('sql', sql);
        params.append('source', 'MANUAL');
        if (confirmDestructive) params.append('confirmDestructive', 'true');

        try {
            const resp = await fetch(ctx + '/api/query/execute', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });
            const data = await resp.json();

            if (resp.status === 409 && data.confirmationRequired) {
                pendingManualSql = sql;
                confirmMsg.textContent = data.errorMessage;
                confirmModal.classList.add('show');
                return;
            }

            window.FoodExpressResults.render(data);
            window.FoodExpressResults.refreshHistory(loadIntoManualEditor);
        } catch (err) {
            window.FoodExpressResults.renderNetworkError('Failed to execute SQL: ' + err.message);
        } finally {
            manualExecBtn.disabled = false;
            manualExecBtn.textContent = 'Execute SQL (Ctrl+Enter)';
        }
    }

    if (manualEditor) {
        manualEditor.addEventListener('input', updateLineNumbers);
        manualEditor.addEventListener('keydown', e => {
            if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
                e.preventDefault();
                executeManualSql(false);
            }
        });
        updateLineNumbers();
    }

    if (manualExecBtn) {
        manualExecBtn.addEventListener('click', () => executeManualSql(false));
    }

    if (manualClearBtn) {
        manualClearBtn.addEventListener('click', () => {
            manualEditor.value = '';
            updateLineNumbers();
            manualEditor.focus();
        });
    }

    if (manualFormatBtn) {
        manualFormatBtn.addEventListener('click', () => {
            const keywords = ['SELECT', 'FROM', 'WHERE', 'INNER JOIN', 'LEFT JOIN', 'RIGHT JOIN', 'JOIN', 'ON', 'GROUP BY', 'HAVING', 'ORDER BY', 'LIMIT', 'INSERT INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE FROM'];
            let formatted = manualEditor.value.trim().replace(/\s+/g, ' ');
            keywords.forEach(kw => {
                const regex = new RegExp('\\b' + kw + '\\b', 'gi');
                formatted = formatted.replace(regex, '\n' + kw);
            });
            manualEditor.value = formatted.trim();
            updateLineNumbers();
        });
    }

    document.querySelectorAll('.sample-sql-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            loadIntoManualEditor(btn.getAttribute('data-sql'));
        });
    });

    document.querySelectorAll('.manual-schema-tbl').forEach(el => {
        el.addEventListener('click', () => {
            const tbl = el.getAttribute('data-table');
            loadIntoManualEditor(`SELECT * FROM \`${tbl}\` LIMIT 50;`);
        });
    });

    if (confirmYes) {
        confirmYes.addEventListener('click', () => {
            confirmModal.classList.remove('show');
            if (pendingManualSql) {
                manualEditor.value = pendingManualSql;
                pendingManualSql = null;
                executeManualSql(true);
            }
        });
    }
    if (confirmNo) {
        confirmNo.addEventListener('click', () => {
            confirmModal.classList.remove('show');
            pendingManualSql = null;
        });
    }

    if (window.FoodExpressResults) {
        window.FoodExpressResults.setHistoryClickHandler(loadIntoManualEditor);
    }

    function escapeHtml(str) {
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }
})();
