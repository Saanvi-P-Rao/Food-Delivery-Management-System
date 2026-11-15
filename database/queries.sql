-- ============================================================================
-- FoodExpress - Demonstration & Verification SQL Queries
-- Covers SELECT, WHERE, JOIN, GROUP BY, HAVING, Aggregates, Subqueries, Views
-- ============================================================================

USE food_delivery_db;

-- 1. Verify row counts across all 7 tables
SELECT 'Users' AS table_name, COUNT(*) AS record_count FROM `Users`
UNION ALL SELECT 'Restaurants', COUNT(*) FROM `Restaurants`
UNION ALL SELECT 'Admin', COUNT(*) FROM `Admin`
UNION ALL SELECT 'Food_Items', COUNT(*) FROM `Food_Items`
UNION ALL SELECT 'Orders', COUNT(*) FROM `Orders`
UNION ALL SELECT 'Order_Items', COUNT(*) FROM `Order_Items`
UNION ALL SELECT 'Payments', COUNT(*) FROM `Payments`;

-- 2. Revenue and order breakdown by Restaurants (INNER JOIN + GROUP BY + ORDER BY)
SELECT r.restaurant_id, r.name AS restaurant_name, r.city,
       COUNT(o.order_id) AS total_orders,
       SUM(o.total_amount) AS total_revenue_inr,
       ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM `Restaurants` r
INNER JOIN `Orders` o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status <> 'CANCELLED'
GROUP BY r.restaurant_id, r.name, r.city
HAVING total_orders >= 3
ORDER BY total_revenue_inr DESC;

-- 3. Top 10 best-selling food items by quantity ordered
SELECT f.food_id, f.name AS food_name, r.name AS restaurant_name,
       f.category, f.price AS current_price,
       SUM(oi.quantity) AS total_qty_sold,
       SUM(oi.subtotal) AS total_sales_inr
FROM `Order_Items` oi
INNER JOIN `Food_Items` f ON oi.food_id = f.food_id
INNER JOIN `Restaurants` r ON f.restaurant_id = r.restaurant_id
GROUP BY f.food_id, f.name, r.name, f.category, f.price
ORDER BY total_qty_sold DESC, total_sales_inr DESC
LIMIT 10;

-- 4. Order total integrity verification (must return 0 rows if all totals match)
SELECT o.order_id, o.total_amount, SUM(oi.subtotal) AS computed_subtotal
FROM `Orders` o
INNER JOIN `Order_Items` oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - computed_subtotal) > 0.01;

-- 5. Customers who spent above the average order total (Subquery)
SELECT u.user_id, u.full_name, u.city, COUNT(o.order_id) AS orders_count, SUM(o.total_amount) AS total_spent
FROM `Users` u
INNER JOIN `Orders` o ON u.user_id = o.user_id
WHERE o.order_status <> 'CANCELLED'
GROUP BY u.user_id, u.full_name, u.city
HAVING total_spent > (SELECT AVG(total_amount) * 2 FROM `Orders` WHERE order_status <> 'CANCELLED')
ORDER BY total_spent DESC;

-- 6. Payments method summary
SELECT payment_method, payment_status, COUNT(*) AS txn_count, SUM(amount) AS total_amount_inr
FROM `Payments`
GROUP BY payment_method, payment_status
ORDER BY total_amount_inr DESC;
