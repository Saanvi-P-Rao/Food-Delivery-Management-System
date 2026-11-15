(function () {
    const ctx = window.APP_CTX || '';
    const previewContainer = document.getElementById('explorerPreviewBody');
    const previewTitle = document.getElementById('explorerPreviewTitle');

    document.querySelectorAll('.btn-preview-table').forEach(btn => {
        btn.addEventListener('click', async () => {
            const tableName = btn.getAttribute('data-table');
            const sandbox = btn.getAttribute('data-sandbox') === 'true';
            if (previewTitle) previewTitle.textContent = 'Live Records: ' + tableName;
            if (previewContainer) previewContainer.innerHTML = '<p style="padding:20px;color:#64748b;">Loading records from MySQL...</p>';

            try {
                const resp = await fetch(`${ctx}/api/admin/explorer/preview?table=${encodeURIComponent(tableName)}&sandbox=${sandbox}&limit=100`);
                const data = await resp.json();
                if (!data.success) {
                    previewContainer.innerHTML = `<div class="alert alert-error">${escapeHtml(data.errorMessage || data.error)}</div>`;
                    return;
                }
                let html = '<div class="table-wrap"><table class="data-table"><thead><tr>';
                data.columns.forEach(c => { html += `<th>${escapeHtml(c)}</th>`; });
                html += '</tr></thead><tbody>';
                if (!data.rows || data.rows.length === 0) {
                    html += `<tr><td colspan="${data.columns.length}" style="text-align:center;padding:24px;color:#64748b;">Table is empty.</td></tr>`;
                } else {
                    data.rows.forEach(r => {
                        html += '<tr>';
                        r.forEach(cell => {
                            html += cell === null
                                ? '<td><span style="color:#94a3b8;font-style:italic;">NULL</span></td>'
                                : `<td>${escapeHtml(String(cell))}</td>`;
                        });
                        html += '</tr>';
                    });
                }
                html += '</tbody></table></div>';
                previewContainer.innerHTML = html;
            } catch (err) {
                previewContainer.innerHTML = `<div class="alert alert-error">Error loading records: ${escapeHtml(err.message)}</div>`;
            }
        });
    });

    function escapeHtml(str) {
        return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
})();
