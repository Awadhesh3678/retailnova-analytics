SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_order_items
FROM order_items;

SELECT COUNT(*) AS total_products
FROM products;

SELECT COUNT(*) AS total_shipments
FROM shipments;

SELECT COUNT(*) AS total_returns
FROM returns;
-- ------------------------------------------------------------------------
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders;

 SELECT
    MIN(return_datetime) AS first_return_date,
    MAX(return_datetime) AS last_return_date
FROM returns;

SELECT
    MIN(shipped_datetime) AS first_shipment_date,
    MAX(shipped_datetime) AS last_shipment_date
FROM shipments;
 ------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
-- -------------------------------------most valuable customers----------------------------------------------- 

SELECT c.customer_id, c.full_name as customer_name, COUNT(DISTINCT o.order_id) AS total_orders,  SUM(o.grand_total) AS total_spend
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status_id =5
GROUP BY  c.customer_id,   customer_name
ORDER BY total_spend DESC 
LIMIT 10;

--  Repeat customers
SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT
        customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
) x;
 
 -- Repeat customer %
SELECT
    ROUND(
        100.0 *
        SUM(order_count > 1)
        / COUNT(*),
        2
    ) AS repeat_customer_pct
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    GROUP BY customer_id
) x;






























ORDER BY revenue DESC
LIMIT 10; 