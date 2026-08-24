/*01. Sales & Revenue
		SP_Total_Sales
		SP_Monthly_Sales
		SP_Sales_By_Category
		SP_Top_Products
02. Customer Analytics
		SP_Customer_Summary
		SP_Top_Customers
		SP_Repeat_Customers
		SP_Customer_RFM
03. Payments & Finance
		SP_Payment_Summary
		SP_Payment_Method_Performance
		SP_Payment_Failures
04. Logistics & SLA
		SP_Delivery_Performance
		SP_Courier_Performance
		SP_SLA_Breaches
05. Returns
		SP_Return_Summary
		SP_Return_By_Reason
		SP_Product_Return_Performance
06. Inventory
		SP_Current_Stock
		SP_Inventory_Movement
		SP_Low_Stock
*/        

-- --------------------------------- Total_Sales ----------------------------------------------------- 
DELIMITER //
CREATE PROCEDURE SP_Total_Sales()
BEGIN
    SELECT
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS total_customers,
        SUM(grand_total) AS total_revenue,
        ROUND(SUM(grand_total) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
    FROM orders;
END //
DELIMITER ;
CALL SP_Total_Sales();
-- ----------------------------------------------------------------------------------------------------
 DELIMITER //
CREATE PROCEDURE SP_Monthly_Sales()
BEGIN
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS customers,
        SUM(grand_total) AS revenue,
        ROUND(SUM(grand_total) / NULLIF(COUNT(DISTINCT order_id), 0),2) AS average_order_value
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
    ORDER BY sales_month;
END //
DELIMITER ;
CALL SP_Monthly_Sales();

-- --------------------------Sales_By_Date---------------------------------------------- 
DELIMITER //
CREATE PROCEDURE SP_Sales_By_Date(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS customers,
        SUM(grand_total) AS revenue,
        ROUND(SUM(grand_total) / NuLLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
    FROM orders
    WHERE order_date >= p_start_date
      AND order_date < DATE_ADD(p_end_date, INTERVAL 1 DAY);
END //
DELIMITER ;

CALL SP_Sales_By_Date(
    '2026-01-01',
    '2026-03-31'
);
-- ---------------------------Sales by category--------------------------------------------- 
DELIMITER //
CREATE PROCEDURE SP_Sales_By_Category()
BEGIN
    SELECT
        c.category_name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN categories c
        ON p.category_id = c.category_id
    GROUP BY
        c.category_id,
        c.category_name
    ORDER BY revenue DESC;
END //
DELIMITER ;
-- --------------------------Top 10 Products---------------------------------------------- 
DELIMITER //
CREATE PROCEDURE SP_Top_10_Products()
BEGIN
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
    ORDER BY revenue DESC
    LIMIT 10;
END //
DELIMITER ;
-- ---------------------------Customer Analytics--------------------------------------------- 
DELIMITER //
CREATE PROCEDURE SP_Customer_Summary()
BEGIN
    SELECT
        COUNT(*) AS total_customers,
        (SELECT COUNT(DISTINCT customer_id) FROM orders) AS purchasing_customers,
        (SELECT COUNT(*)FROM 
        (SELECT customer_id FROM orders
                GROUP BY customer_id
                HAVING COUNT(DISTINCT order_id) > 1 ) x
        ) AS repeat_customers;
END //
DELIMITER ;


-- ---------------------Top Customers by Revenue--------------------------------------------------- 
DELIMITER //
CREATE PROCEDURE SP_Top_Customers(
    IN p_limit INT
)
BEGIN
    SELECT
        c.customer_id,
        c.full_name,
        c.last_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.grand_total) AS revenue,
        ROUND(SUM(o.grand_total) / NULLIF(COUNT(DISTINCT o.order_id), 0),2) AS average_order_value
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
    ORDER BY revenue DESC
    LIMIT p_limit;
END //
DELIMITER ;

CALL SP_Top_Customers(10);
-- -------------------------------Repeat Customers----------------------------------------- 
DELIMITER //
CREATE PROCEDURE SP_Repeat_Customers()
BEGIN
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(grand_total) AS total_revenue
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
    ORDER BY total_revenue DESC;
END //
DELIMITER ;
-- -------------------------Customer RFM----------------------------------------------- 

DELIMITER //
CREATE PROCEDURE SP_Customer_RFM()
BEGIN
    SELECT
        customer_id,
        DATEDIFF( (SELECT MAX(order_date) FROM orders), MAX(order_date)) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(grand_total) AS monetary_value
    FROM orders
    GROUP BY customer_id
    ORDER BY monetary_value DESC;
END //
DELIMITER ;
-- ---------------------------Payment Summary--------------------------------------------- 

DELIMITER //
CREATE PROCEDURE SP_Payment_Summary()
BEGIN
    SELECT
        payment_status_id,
        COUNT(*) AS transaction_count,
        SUM(payment_amount) AS total_amount,
        ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS transaction_percentage
    FROM payments
    GROUP BY payment_status_id
    ORDER BY transaction_count DESC;
END //
DELIMITER ;
-- ------------------------------Payment Method Performance------------------------------------------ 

DELIMITER //
CREATE PROCEDURE SP_Payment_Method_Performance()
BEGIN
    SELECT
        payment_method_id,
        COUNT(*) AS transactions,
        SUM(payment_amount) AS total_amount,
        ROUND( AVG(payment_amount),2) AS average_transaction_value
    FROM payments
    GROUP BY payment_method_id
    ORDER BY total_amount DESC;
END //
DELIMITER ;
-- -------------------------------Payment Failures----------------------------------------- 

DELIMITER //
CREATE PROCEDURE SP_Payment_Failures()
BEGIN
    SELECT
        payment_status_id,
        COUNT(*) AS failed_transactions,
        SUM(payment_amount) AS failed_amount
    FROM payments
    WHERE payment_status_id <> 1
    GROUP BY payment_status_id
    ORDER BY failed_amount DESC;
END //
DELIMITER ;
-- ----------------------------Logistics — Delivery Performance-------------------------------------------- 

DELIMITER //
CREATE PROCEDURE SP_Delivery_Performance()
BEGIN
    SELECT
        COUNT(DISTINCT shipment_id) AS total_shipments,
        SUM(delivered_datetime IS NOT NULL) AS delivered_shipments,
        ROUND(AVG( DATEDIFF(delivered_datetime,  shipped_datetime )),
        2 ) AS avg_delivery_days,

        ROUND(100.0 *SUM(delivered_datetime <= promised_delivery_date)/ NULLIF(COUNT(delivered_datetime),0),
        2) AS on_time_percentage,

        ROUND(100.0 *SUM(delivered_datetime > promised_delivery_date)/ NULLIF(COUNT(delivered_datetime),0),
            2) AS sla_breach_percentage
            
    FROM shipments
    WHERE delivered_datetime IS NOT NULL;
END //
DELIMITER ;
-- ----------------------------- Courier Performance------------------------------------------- 
DELIMITER //
CREATE PROCEDURE SP_Courier_Performance()
BEGIN
    SELECT
        cp.courier_partner_name,
        COUNT(DISTINCT s.shipment_id) AS shipments,
        ROUND( AVG(DATEDIFF( s.delivered_datetime,s.shipped_datetime)),2) AS avg_delivery_days,

        ROUND( 100.0 *SUM(s.delivered_datetime <=s.promised_delivery_date)/ NULLIF(COUNT(*), 0),
            2) AS on_time_percentage
    FROM shipments s
    JOIN courier_partners cp
        ON s.courier_partner_id = cp.courier_partner_id
    WHERE s.delivered_datetime IS NOT NULL
    GROUP BY
        cp.courier_partner_id,
        cp.courier_partner_name
    ORDER BY on_time_percentage DESC;
END //
DELIMITER ;

-- ------------------------------ SLA Breaches------------------------------------------ 

DELIMITER //

CREATE PROCEDURE SP_SLA_Breaches()
BEGIN

    SELECT

        s.shipment_id,
        s.order_id,
        s.promised_delivery_date,
        s.delivered_datetime,

        DATEDIFF(
            s.delivered_datetime,
            s.promised_delivery_date
        ) AS delay_days

    FROM shipments s

    WHERE s.delivered_datetime IS NOT NULL

      AND s.delivered_datetime >
          s.promised_delivery_date

    ORDER BY delay_days DESC;

END //

DELIMITER ;
-- ------------------------------Returns Summary ------------------------------------------ 
DELIMITER //

CREATE PROCEDURE SP_Return_Summary()
BEGIN

    SELECT

        COUNT(DISTINCT return_id) AS return_transactions,

        SUM(quantity) AS returned_units,

        COUNT(DISTINCT order_id) AS affected_orders

    FROM returns;

END //

DELIMITER ;
-- ------------------------------Return Reasons------------------------------------------ 

DELIMITER //

CREATE PROCEDURE SP_Return_By_Reason()
BEGIN

    SELECT

        rr.reason_name,

        COUNT(DISTINCT r.return_id)
            AS return_transactions,

        SUM(r.quantity)
            AS returned_units

    FROM returns r

    JOIN return_reasons rr
        ON r.return_reason_id =
           rr.return_reason_id

    GROUP BY
        rr.reason_id,
        rr.reason_name

    ORDER BY returned_units DESC;

END //

DELIMITER ;

-- ---------------------------- Product Return Performance-------------------------------------------- 
DELIMITER //

CREATE PROCEDURE SP_Product_Return_Performance()
BEGIN
    WITH sales AS (
        SELECT
            product_id,
            SUM(quantity) AS units_sold
        FROM order_items
        GROUP BY product_id
    ),
    returned AS (
        SELECT
            product_id,
            SUM(quantity) AS returned_units
        FROM returns
        GROUP BY product_id
    )
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(s.units_sold, 0)AS units_sold,
        COALESCE(r.returned_units, 0)AS returned_units,
        ROUND(100.0 *COALESCE(r.returned_units, 0)/ NULLIF(s.units_sold, 0),2
        ) AS return_rate
    FROM products p
    LEFT JOIN sales s
        ON p.product_id = s.product_id
    LEFT JOIN returned r
        ON p.product_id = r.product_id
    WHERE s.units_sold IS NOT NULL
    ORDER BY return_rate DESC;
END //
DELIMITER ;

-- ------------------------------Inventory — Current Stock------------------------------------------ 

DELIMITER //

CREATE PROCEDURE SP_Current_Stock()
BEGIN
    WITH ranked_stock AS (
        SELECT
            product_id,
            warehouse_id,
            closing_stock,
            movement_date,
            movement_id,
            ROW_NUMBER() OVER (PARTITION BY product_id, warehouse_id
                ORDER BY  movement_date DESC,movement_id DESC
            ) AS rn
        FROM inventory_movements
    )
    SELECT
        product_id,
        warehouse_id,
        closing_stock AS current_stock,
        movement_date AS stock_as_of
    FROM ranked_stock
    WHERE rn = 1
    ORDER BY current_stock;
END //
DELIMITER ;

-- -----------=-----------------------Inventory Movement Summary--------------------------------------------------------- 

DELIMITER //
CREATE PROCEDURE SP_Inventory_Movement()
BEGIN
    SELECT
        movement_type_id,
        COUNT(*) AS movement_count,
        SUM(opening_stock) AS opening_stock,
        SUM(closing_stock) AS closing_stock,
        SUM(product_dispatched_qty)
            AS dispatched_quantity
    FROM inventory_movements
    GROUP BY movement_type_id
    ORDER BY movement_count DESC;
END //
DELIMITER ;

-- -----------=---------------------------Inventory by Warehouse----------------------------------------------------- 

DELIMITER //
CREATE PROCEDURE SP_Inventory_By_Warehouse()
BEGIN
    WITH ranked_stock AS (
        SELECT
            product_id,
            warehouse_id,
            closing_stock,
            ROW_NUMBER() OVER (PARTITION BY product_id,warehouse_id ORDER BY movement_date DESC, movement_id DESC
            ) AS rn
        FROM inventory_movements
    )
    
    SELECT
        warehouse_id,
        COUNT(DISTINCT product_id)
            AS products,
        SUM(closing_stock)
            AS current_stock
    FROM ranked_stock
    WHERE rn = 1
    GROUP BY warehouse_id
    ORDER BY current_stock DESC;
END //
DELIMITER ;

-- -----------=------------------ Data Quality SP ------------------------------------------------------------- 

DELIMITER //
CREATE PROCEDURE SP_Data_Quality_Check()
BEGIN
    SELECT
        'Customers' AS table_name,
        COUNT(*) AS total_rows,
        COUNT(DISTINCT customer_id) AS unique_ids
    FROM customers
    UNION ALL
    SELECT
        'Orders',
        COUNT(*),
        COUNT(DISTINCT order_id)
    FROM orders
    UNION ALL
    SELECT
        'Order Items',
        COUNT(*),
        COUNT(DISTINCT order_item_id)
    FROM order_items
    UNION ALL
    SELECT
        'Products',
        COUNT(*),
        COUNT(DISTINCT product_id)
    FROM products
    UNION ALL
    SELECT
        'Payments',
        COUNT(*),
        COUNT(DISTINCT payment_id)
    FROM payments
    UNION ALL
    SELECT
        'Shipments',
        COUNT(*),
        COUNT(DISTINCT shipment_id)
    FROM shipments
    UNION ALL
    SELECT
        'Returns',
        COUNT(*),
        COUNT(DISTINCT return_id)
    FROM returns;
END //
DELIMITER ;

-- -----------=----------------------- Management Executive SP --------------------------------------------------------- 

DELIMITER //
CREATE PROCEDURE SP_Executive_Summary()
BEGIN
    SELECT
        /* SALES */
        (SELECT COUNT(DISTINCT order_id)
            FROM orders) AS total_orders,
        (SELECT COUNT(DISTINCT customer_id)
            FROM orders) AS active_customers,
        (SELECT SUM(grand_total)
            FROM orders) AS total_revenue,
        (SELECT ROUND( SUM(grand_total) /NULLIF(COUNT(DISTINCT order_id), 0),2)
            FROM orders) AS average_order_value,
        
        /* RETURNS */
        (SELECT SUM(quantity)
            FROM returns) AS returned_units,

        /* SHIPMENTS */
        (SELECT COUNT(DISTINCT shipment_id)
            FROM shipments) AS total_shipments,
        (SELECT ROUND(100.0 * SUM( delivered_datetime <= promised_delivery_date) / NULLIF(COUNT(*), 0), 2 )
            FROM shipments   WHERE delivered_datetime IS NOT NULL) AS on_time_delivery_pct,
        
        /* CUSTOMERS */
        (SELECT COUNT(*)FROM (
                SELECT customer_id
                FROM orders
                GROUP BY customer_id
                HAVING COUNT(DISTINCT order_id) > 1
            ) x
        ) AS repeat_customers;
END //
DELIMITER ;
CALL SP_Executive_Summary();
