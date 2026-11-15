window.FoodExpress = (function () {
    function getContextPath() {
        return window.APP_CTX || '';
    }

    function showToast(message) {
        let container = document.getElementById('toastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toastContainer';
            container.className = 'toast-container';
            document.body.appendChild(container);
        }
        const el = document.createElement('div');
        el.className = 'toast';
        el.textContent = message;
        container.appendChild(el);
        setTimeout(() => {
            el.style.opacity = '0';
            el.style.transition = 'opacity 0.25s';
            setTimeout(() => el.remove(), 260);
        }, 2800);
    }

    async function addToCart(foodId, quantity = 1, replace = false) {
        const params = new URLSearchParams();
        params.append('action', 'add');
        params.append('foodId', foodId);
        params.append('quantity', quantity);
        if (replace) params.append('replace', 'true');

        try {
            const resp = await fetch(getContextPath() + '/api/cart', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });
            const data = await resp.json();
            if (resp.status === 409 && data.differentRestaurant) {
                if (confirm(data.error)) {
                    return addToCart(foodId, quantity, true);
                }
                return;
            }
            if (data.success) {
                const badge = document.getElementById('navCartCount');
                if (badge) badge.textContent = data.count;
                showToast('Added to cart (' + data.count + ' items)');
            } else {
                showToast(data.error || 'Could not add item');
            }
        } catch (err) {
            showToast('Network error adding item to cart');
        }
    }

    return { addToCart, showToast };
})();
