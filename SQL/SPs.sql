/*  						RETAILNOVA ANALYTICS
                            STORED PROCEDURE INDEX
-- -----------------------------------------------------------------------------------------------------------
01. SALES & REVENUE
    01. Total_Sales
    02. Monthly_Sales
    03. Sales_By_Date
    04. Sales_By_Category
    05. Top_Products

02. CUSTOMER ANALYTICS
    06. Customer_Summary
    07. Top_Customers
    08. Repeat_Customers
    09. Customer_RFM

03. PAYMENTS & FINANCE
    10. Payment_Summary
    11. Payment_Method_Performance
    12. Payment_Failures

04. LOGISTICS & SLA
    13. Delivery_Performance
    14. Courier_Performance
    15. SLA_Breaches

05. RETURNS
    16. Return_Summary
    17. Return_By_Reason
    18. Product_Return_Performance

06. INVENTORY
    19. Current_Stock
    20. Inventory_Movement
    21. Inventory_By_Warehouse
    22. Low_Stock


07. DATA QUALITY
    23. Data_Quality_Check

08. MANAGEMENT / EXECUTIVE
    24. Executive_Summary
*/

-- ---------------------------------1 Total_Sales ----------------------------------------------------- 
DELIMITER //
CREATE PROCEDURE Total_Sales()
BEGIN
    SELECT
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS total_customers,
        SUM(grand_total) AS total_revenue,
        ROUND(SUM(grand_total) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
    FROM orders;
END //
DELIMITER ;
CALL Total_Sales();
-- ---------------------------------------- 2 Monthly_Sales ------------------------------------------------------------
 DELIMITER //
CREATE PROCEDURE Monthly_Sales()
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
CALL Monthly_Sales();

-- --------------------------3 Sales_By_Date---------------------------------------------- 
DELIMITER //
CREATE PROCEDURE Sales_By_Date(
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

CALL Sales_By_Date(
    '2026-01-01',
    '2026-03-31'
);
-- ---------------------------Sales by category--------------------------------------------- 
DELIMITER //
CREATE PROCEDURE Sales_By_Category()
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
call Sales_By_Category();
-- --------------------------Top 10 Products---------------------------------------------- 
DELIMITER //
CREATE PROCEDURE Top_10_Products()
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
call Top_10_Products();
-- ---------------------------Customer Analytics--------------------------------------------- 
DELIMITER //
CREATE PROCEDURE Customer_Summary()
BEGIN
    SELECT
        /* Customers in master table */
        (SELECT COUNT(*) FROM customers) AS total_customers,
        (SELECT COUNT(DISTINCT customer_id) FROM orders) AS purchasing_customers,
        (SELECT COUNT(*)FROM 
        (SELECT customer_id FROM orders
                GROUP BY customer_id
                HAVING COUNT(DISTINCT order_id) > 1 ) x
        ) AS repeat_customers;
END //
DELIMITER ;
call Customer_Summary();

-- ---------------------Top Customers by Revenue--------------------------------------------------- 
DELIMITER //
CREATE PROCEDURE Top_Customers(
    IN p_limit INT
)
BEGIN
    SELECT
        c.customer_id,c.customer_code,c.full_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.grand_total) AS revenue,
        ROUND(
            SUM(o.grand_total)/NULLIF(COUNT(DISTINCT o.order_id), 0),2) AS average_order_value
    FROM customers c INNER JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,c.customer_code,c.full_name
    ORDER BY
        revenue DESC
    LIMIT p_limit;
END //
DELIMITER ;
CALL Top_Customers(10);
-- -------------------------------Repeat Customers----------------------------------------- 
DELIMITER //
CREATE PROCEDURE Repeat_Customers()
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
call Repeat_Customers();
-- -------------------------Customer RFM----------------------------------------------- 

DELIMITER //
CREATE PROCEDURE Customer_RFM()
BEGIN
    SELECT
        customer_id,
        DATEDIFF( (SELECT MAX(order_date) FROM orders), MAX(order_date)) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(grand_total) AS total_value
    FROM orders
    GROUP BY customer_id
    ORDER BY total_value DESC;
END //
DELIMITER ;
call Customer_RFM();


-- ---------------------------Payment Summary--------------------------------------
DELIMITER //
CREATE PROCEDURE Payment_Summary()
BEGIN
    SELECT
        ps.payment_status_id, ps.payment_status,COUNT(*) AS transaction_count,SUM(p.amount) AS total_amount,
        SUM(p.refund_amount) AS total_refund_amount,
        ROUND(100.0 * COUNT(*)/ NULLIF(SUM(COUNT(*)) OVER (), 0),2 ) AS transaction_percentage
    FROM payments p INNER JOIN payment_status ps ON p.payment_status_id = ps.payment_status_id
    GROUP BY
        ps.payment_status_id, ps.payment_status
    ORDER BY
        transaction_count DESC;
END //
DELIMITER ;
call Payment_Summary();

-- ------------------------------Payment Method Performance------------------------------------------ 

DELIMITER //
CREATE PROCEDURE Payment_Method_Performance()
BEGIN
    SELECT
        payment_mode_id,
        COUNT(*) AS transactions,
        SUM(amount) AS total_amount,
        ROUND( AVG(amount),2) AS average_transaction_value
    FROM payments
    GROUP BY payment_mode_id
    ORDER BY total_amount DESC;
END //
DELIMITER ;
call Payment_Method_Performance();
-- -------------------------------Payment Failures----------------------------------------- 

DELIMITER //
CREATE PROCEDURE Payment_Failures()
BEGIN
    SELECT
        payment_status_id,
        COUNT(*) AS failed_transactions,
        SUM(amount) AS failed_amount
    FROM payments
    WHERE payment_status_id =3
    GROUP BY payment_status_id
    ORDER BY failed_amount DESC;
END //
DELIMITER ;

call Payment_Failures();
-- ----------------------------Logistics — Delivery Performance-------------------------------------------- 

DELIMITER //
CREATE PROCEDURE Delivery_Performance()
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
call Delivery_Performance();
-- ----------------------------- Courier Performance------------------------------------------- 

DELIMITER //
CREATE PROCEDURE Courier_Performance()
BEGIN
    SELECT
        cp.courier_partner,
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
        cp.courier_partner
    ORDER BY on_time_percentage DESC;
END //
DELIMITER ;
call Courier_Performance();
-- ------------------------------ SLA Breaches------------------------------------------ 

DELIMITER //
CREATE PROCEDURE SLA_Breaches()
BEGIN
    SELECT
        s.shipment_id, s.order_id,s.promised_delivery_date,s.delivered_datetime,
        DATEDIFF(s.delivered_datetime,s.promised_delivery_date) AS delay_days
    FROM shipments s
    WHERE s.delivered_datetime IS NOT NULL
      AND s.delivered_datetime >s.promised_delivery_date
    ORDER BY delay_days DESC;
END //
DELIMITER ;
call SLA_Breaches();
-- ------------------------------Returns Summary ------------------------------------------ 

DELIMITER //
CREATE PROCEDURE Return_Summary()
BEGIN
    WITH unique_return_items AS
    (SELECT DISTINCT r.order_id, r.order_item_id FROM returns r)
    SELECT
        /* Number of return transactions */
        (SELECT COUNT(DISTINCT return_id)FROM returns) AS return_transactions,
        /* Number of affected orders */
        ( SELECT COUNT(DISTINCT order_id)FROM returns
        ) AS affected_orders,
        
        /* Number of unique returned line items */
        (SELECT COUNT(*)FROM unique_return_items
        ) AS returned_line_items,

        /* Units associated with returned order items */
        ( SELECT COALESCE(SUM(oi.quantity), 0)FROM unique_return_items uri
            INNER JOIN order_items oi
                ON uri.order_id = oi.order_id
               AND uri.order_item_id = oi.order_item_id
        ) AS returned_units,
        /* Total refund value */
        (SELECT COALESCE(SUM(refund_amount), 0)FROM returns) AS refund_amount;
END //
DELIMITER ;

call Return_Summary();
-- ------------------------------Return Reasons------------------------------------------ 

DELIMITER //
CREATE PROCEDURE Return_By_Reason()
BEGIN
    WITH unique_return_items AS
    ( SELECT DISTINCT
            r.return_id,
            r.order_id,
            r.order_item_id,
            r.return_reason_id
        FROM returns r)

    SELECt
        rr.return_reason_id,rr.return_reason, COUNT(DISTINCT uri.return_id) AS return_transactions,  COUNT(DISTINCT uri.order_item_id) AS returned_line_items,

        COALESCE(   SUM(oi.quantity),0) AS returned_units,
        COALESCE( SUM(r.refund_amount),0 ) AS refund_amount

    FROM unique_return_items uri  INNER JOIN return_reason rr  ON uri.return_reason_id = rr.return_reason_id

    INNER JOIN order_items oi
        ON uri.order_id = oi.order_id
       AND uri.order_item_id = oi.order_item_id INNER JOIN returns r
        ON uri.return_id = r.return_id
    GROUP BY  rr.return_reason_id, rr.return_reason
    ORDER BY  returned_units DESC;
END //
DELIMITER ;
call Return_By_Reason();



-- -------------------------------------- Product Return Performance-------------------------------------------- 

DELIMITER //
CREATE PROCEDURE Product_Return_Performance()
BEGIN
    /* -------------------- Units Sold -------------------- */
    WITH sales AS(
        SELECT product_id, SUM(quantity) AS units_sold
        FROM order_items  GROUP BY product_id
    ),

    /* -------------------- Returned Items -------------------- */
    unique_returns AS(
        SELECT DISTINCT r.return_id, r.order_id, r.order_item_id, r.product_id FROM returns r),
    returned AS 
    
    ( SELECT
            ur.product_id, SUM(oi.quantity) AS returned_units, COUNT(DISTINCT ur.return_id) AS return_transactions
			FROM unique_returns ur INNER JOIN order_items oi
            ON ur.order_id = oi.order_id AND ur.order_item_id = oi.order_item_id
			GROUP BY ur.product_id )

    /* -------------------- Final Product Analysis -------------------- */
    SELECT
        p.product_id,p.sku,p.product_name,s.units_sold,
        COALESCE(r.returned_units, 0) AS returned_units,
        COALESCE(r.return_transactions, 0) AS return_transactions,
        ROUND( 100.0 *COALESCE(r.returned_units, 0)/ NULLIF(s.units_sold, 0),2) AS return_rate
    FROM products p INNER JOIN sales s
        ON p.product_id = s.product_id
    LEFT JOIN returned r
        ON p.product_id = r.product_id
    ORDER BY return_rate DESC;
END //
DELIMITER ;
 call Product_Return_Performance();
 
 
 
-- ------------------------------Inventory — Current Stock------------------------------------------ 
DELIMITER //
CREATE PROCEDURE Current_Stock()
BEGIN
    WITH ranked_stock AS (
        SELECT   product_id, warehouse_id, closing_stock,  movement_date, movement_id,
        
            ROW_NUMBER() OVER (PARTITION BY product_id, warehouse_id
                ORDER BY  movement_date DESC,movement_id DESC) AS rn
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
call Current_Stock();
-- -----------=-----------------------Inventory Movement Summary--------------------------------------------------------- 

DELIMITER //
CREATE PROCEDURE Inventory_Movement()
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

call Inventory_Movement();




	
-- -----------=---------------------------Inventory by Warehouse----------------------------------------------------- 

DELIMITER //
CREATE PROCEDURE 	Inventory_By_Warehouse()
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
call Inventory_By_Warehouse();

-- -----------=------------------ Data Quality SP ------------------------------------------------------------- 
DELIMITER //
CREATE PROCEDURE Data_Quality_Check()
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
call Data_Quality_Check();


-- -----------=----------------------- Management Executive SP --------------------------------------------------------- 

DELIMITER //
CREATE PROCEDURE Executive_Summary()
BEGIN
    SELECT
        /*  SALES */
        (SELECT COUNT(DISTINCT order_id)  FROM orders ) AS total_orders,

        (SELECT COUNT(DISTINCT customer_id) FROM orders) AS purchasing_customers,

        (SELECT SUM(grand_total) FROM orders ) AS total_revenue,
        
        (SELECT ROUND( SUM(grand_total) / NULLIF(COUNT(DISTINCT order_id), 0), 2) FROM orders) AS average_order_value,

        /*  RETURNS */

        (SELECT COALESCE(SUM(oi.quantity), 0) FROM
            ( SELECT DISTINCT order_id, order_item_id FROM returns) r
            INNER JOIN order_items oi
                ON r.order_id = oi.order_id AND r.order_item_id = oi.order_item_id) AS returned_units,


        /* SHIPMENTS */

        (SELECT COUNT(DISTINCT shipment_id)
            FROM shipments) AS total_shipments,

        ( SELECT ROUND( 100.0 *
                SUM(CASE WHEN actual_delivery_date <= promised_delivery_date
                        THEN 1
                        ELSE 0 END) /
                NULLIF( SUM(CASE WHEN actual_delivery_date IS NOT NULL
                            THEN 1
                            ELSE 0
                        END),0), 2  ) FROM shipments ) AS on_time_delivery_pct,


        /* CUSTOMERS */

        (SELECT COUNT(*) FROM
            (SELECT customer_id FROM orders GROUP BY customer_id
                HAVING COUNT(DISTINCT order_id) > 1 ) repeat_customer_set ) AS repeat_customers;

END //

DELIMITER ;
CALL Executive_Summary();
