/* ============================================================
RETAIL SALES DATABASE 
EXECUTION ORDER SUMMARY
============================================================
01 states
02 categories
03 brands
04 customer_segments
05 customer_status
06 loyalty_tiers
07 courier_partners
08 inventory_movement_type
09 order_channel
10 sales_channel
11 order_status
12 payment_modes
13 payment_status
14 return_reason
15 return_status
16 shipment_status
17 cities
18 subcategories
19 warehouses
20 products
21 customers
22 orders
23 order_items
24 payments
25 shipments
26 returns
27 inventory_movements

============================================================ */

CREATE DATABASE IF NOT EXISTS retail_sales;
USE retail_sales;

-- ============================================================
-- 01. STATES
-- ============================================================
CREATE TABLE IF NOT EXISTS states (
    state_id       INT UNSIGNED NOT NULL,
    country_name   VARCHAR(100) NOT NULL,
    state_name     VARCHAR(100) NOT NULL,
    state_code     VARCHAR(10) NOT NULL,
    PRIMARY KEY (state_id),
    UNIQUE KEY uk_states_code (state_code),
    UNIQUE KEY uk_states_country_name (country_name, state_name)
) ENGINE=InnoDB;

-- ============================================================
-- 02. CATEGORIES
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    category_id    INT UNSIGNED NOT NULL,
    category_name  VARCHAR(100) NOT NULL,
    PRIMARY KEY (category_id),
    UNIQUE KEY uk_categories_name (category_name)
) ENGINE=InnoDB;

-- ============================================================
-- 03. BRANDS
-- ============================================================
CREATE TABLE IF NOT EXISTS brands (
    brand_id       INT UNSIGNED NOT NULL,
    brand_name     VARCHAR(100) NOT NULL,
    brand_country  VARCHAR(100) NOT NULL,
    PRIMARY KEY (brand_id),
    UNIQUE KEY uk_brands_name_country (brand_name, brand_country),
    INDEX idx_brands_name (brand_name)
) ENGINE=InnoDB;

-- ============================================================
-- 04. CUSTOMER SEGMENTS
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_segments (
    customer_segment_id  INT UNSIGNED NOT NULL,
    segment_name         VARCHAR(50) NOT NULL,
    segment_description  VARCHAR(255) NULL,
    PRIMARY KEY (customer_segment_id),
    UNIQUE KEY uk_customer_segments_name (segment_name)
) ENGINE=InnoDB;

-- ============================================================
-- 05. CUSTOMER STATUS
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_status (
    customer_status_id  INT UNSIGNED NOT NULL,
    status_name         VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_status_id),
    UNIQUE KEY uk_customer_status_name (status_name)
) ENGINE=InnoDB;

-- ============================================================
-- 06. LOYALTY TIERS
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS loyalty_tiers (
    loyalty_tier_id   INT UNSIGNED NOT NULL,
    tier_name         VARCHAR(50) NOT NULL,
    tier_rank         TINYINT UNSIGNED NOT NULL,
    benefits_summary  VARCHAR(255) NULL,
    PRIMARY KEY (loyalty_tier_id),
    UNIQUE KEY uk_loyalty_tiers_name (tier_name),
    UNIQUE KEY uk_loyalty_tiers_rank (tier_rank),
    CONSTRAINT chk_loyalty_tier_rank CHECK (tier_rank > 0)
) ENGINE=InnoDB;

-- ============================================================
-- 07. COURIER PARTNERS
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS courier_partners (
    courier_partner_id  INT UNSIGNED NOT NULL,
    courier_partner     VARCHAR(100) NOT NULL,
    PRIMARY KEY (courier_partner_id),
    UNIQUE KEY uk_courier_partner_name (courier_partner)
) ENGINE=InnoDB;

-- ============================================================
-- 08. INVENTORY MOVEMENT TYPES
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS inventory_movement_type (
    movement_type_id  INT UNSIGNED NOT NULL,
    movement_type     VARCHAR(50) NOT NULL,
    PRIMARY KEY (movement_type_id),
    UNIQUE KEY uk_inventory_movement_type_name (movement_type)
) ENGINE=InnoDB;

-- ============================================================
-- 09. ORDER CHANNEL
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS order_channel (
    order_channel_id  INT UNSIGNED NOT NULL,
    order_channel     VARCHAR(50) NOT NULL,
    PRIMARY KEY (order_channel_id),
    UNIQUE KEY uk_order_channel_name (order_channel)
) ENGINE=InnoDB;

-- ============================================================
-- 10. SALES CHANNEL
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS sales_channel (
    sales_channel_id  INT UNSIGNED NOT NULL,
    sales_channel     VARCHAR(50) NOT NULL,
    PRIMARY KEY (sales_channel_id),
    UNIQUE KEY uk_sales_channel_name (sales_channel)
) ENGINE=InnoDB;

-- ============================================================
-- 11. ORDER STATUS
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS order_status (
    order_status_id  INT UNSIGNED NOT NULL,
    order_status     VARCHAR(50) NOT NULL,
    PRIMARY KEY (order_status_id),
    UNIQUE KEY uk_order_status_name (order_status)
) ENGINE=InnoDB;

-- ============================================================
-- 12. PAYMENT MODES
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS payment_modes (
    payment_mode_id  INT UNSIGNED NOT NULL,
    payment_mode     VARCHAR(50) NOT NULL,
    PRIMARY KEY (payment_mode_id),
    UNIQUE KEY uk_payment_mode_name (payment_mode)
) ENGINE=InnoDB;

-- ============================================================
-- 13. PAYMENT STATUS
-- Dependency: none

-- ============================================================
CREATE TABLE IF NOT EXISTS payment_status (
    payment_status_id  INT UNSIGNED NOT NULL,
    payment_status     VARCHAR(50) NOT NULL,
    PRIMARY KEY (payment_status_id),
    UNIQUE KEY uk_payment_status_name (payment_status)
) ENGINE=InnoDB;

-- ============================================================
-- 14. RETURN REASON
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS return_reason (
    return_reason_id  INT UNSIGNED NOT NULL,
    return_reason     VARCHAR(100) NOT NULL,
    PRIMARY KEY (return_reason_id),
    UNIQUE KEY uk_return_reason_name (return_reason)
) ENGINE=InnoDB;

-- ============================================================
-- 15. RETURN STATUS
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS return_status (
    return_status_id  INT UNSIGNED NOT NULL,
    return_status     VARCHAR(50) NOT NULL,
    PRIMARY KEY (return_status_id),
    UNIQUE KEY uk_return_status_name (return_status)
) ENGINE=InnoDB;

-- ============================================================
-- 16. SHIPMENT STATUS
-- Dependency: none
-- ============================================================
CREATE TABLE IF NOT EXISTS shipment_status (
    shipment_status_id  INT UNSIGNED NOT NULL,
    shipment_status     VARCHAR(50) NOT NULL,
    PRIMARY KEY (shipment_status_id),
    UNIQUE KEY uk_shipment_status_name (shipment_status)
) ENGINE=InnoDB;

-- ============================================================
-- 17. CITIES
-- Dependency: states
-- ============================================================
CREATE TABLE IF NOT EXISTS cities (
    city_id       INT UNSIGNED NOT NULL,
    state_id      INT UNSIGNED NOT NULL,
    city_name     VARCHAR(100) NOT NULL,
    city_type     VARCHAR(30) NOT NULL,
    PRIMARY KEY (city_id),
    UNIQUE KEY uk_cities_state_city (state_id, city_id),
    UNIQUE KEY uk_cities_state_name (state_id, city_name),
    CONSTRAINT fk_cities_state
        FOREIGN KEY (state_id)
        REFERENCES states(state_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================
-- 18. SUBCATEGORIES
-- Dependency: categories
-- ============================================================
CREATE TABLE IF NOT EXISTS subcategories (
    subcategory_id    INT UNSIGNED NOT NULL,
    category_id       INT UNSIGNED NOT NULL,
    subcategory_name  VARCHAR(100) NOT NULL,
    PRIMARY KEY (subcategory_id),
    UNIQUE KEY uk_subcategories_category_name (category_id, subcategory_name),
    UNIQUE KEY uk_subcategories_id_category (subcategory_id, category_id),
    CONSTRAINT fk_subcategories_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================
-- 19. WAREHOUSES
-- Dependency: cities
-- ============================================================
CREATE TABLE IF NOT EXISTS warehouses (
    warehouse_id    INT UNSIGNED NOT NULL,
    warehouse_code  VARCHAR(30) NOT NULL,
    warehouse_name  VARCHAR(150) NOT NULL,
    city_id         INT UNSIGNED NOT NULL,
    capacity_units  INT UNSIGNED NOT NULL,
    manager_name    VARCHAR(150) NULL,
    active_flag     TINYINT(1) NOT NULL DEFAULT 1,
    created_at      DATE NOT NULL,
    PRIMARY KEY (warehouse_id),
    UNIQUE KEY uk_warehouses_code (warehouse_code),
    UNIQUE KEY uk_warehouses_city_name (city_id, warehouse_name),
    CONSTRAINT fk_warehouses_city
        FOREIGN KEY (city_id)
        REFERENCES cities(city_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_warehouses_capacity CHECK (capacity_units >= 0),
    CONSTRAINT chk_warehouses_active CHECK (active_flag IN (0,1))
) ENGINE=InnoDB;

-- ============================================================
-- 20. PRODUCTS
-- Dependency: categories, subcategories, brands
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    product_id      INT UNSIGNED NOT NULL,
    sku             VARCHAR(50) NOT NULL,
    product_name    VARCHAR(200) NOT NULL,
    category_id     INT UNSIGNED NOT NULL,
    subcategory_id  INT UNSIGNED NOT NULL,
    brand_id        INT UNSIGNED NOT NULL,
    hsn_code        VARCHAR(20) NOT NULL,
    gst_rate        DECIMAL(5,2) NOT NULL,
    cost_price      DECIMAL(12,2) NOT NULL,
    list_price      DECIMAL(12,2) NOT NULL,
    mrp             DECIMAL(12,2) NOT NULL,
    active_flag     TINYINT(1) NOT NULL DEFAULT 1,
    created_at      DATETIME NOT NULL,
    updated_at      DATETIME NOT NULL,
    PRIMARY KEY (product_id),
    UNIQUE KEY uk_products_sku (sku),
    INDEX idx_products_category (category_id),
    INDEX idx_products_subcategory (subcategory_id),
    INDEX idx_products_brand (brand_id),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_products_subcategory_category
        FOREIGN KEY (subcategory_id, category_id)
        REFERENCES subcategories(subcategory_id, category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_products_brand
        FOREIGN KEY (brand_id)
        REFERENCES brands(brand_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_products_gst CHECK (gst_rate BETWEEN 0 AND 100),
    CONSTRAINT chk_products_cost CHECK (cost_price >= 0),
    CONSTRAINT chk_products_list CHECK (list_price >= 0),
    CONSTRAINT chk_products_mrp CHECK (mrp >= 0),
    CONSTRAINT chk_products_prices CHECK (cost_price <= list_price AND list_price <= mrp),
    CONSTRAINT chk_products_active CHECK (active_flag IN (0,1)),
    CONSTRAINT chk_products_dates CHECK (updated_at >= created_at)
) ENGINE=InnoDB;

-- ============================================================

ALTER TABLE cities
ADD INDEX idx_cities_city_state (city_id, state_id);
-- 21. CUSTOMERS
-- Dependency: cities, customer_segments, loyalty_tiers, customer_status
-- ============================================================
CREATE TABLE IF NOT EXISTS customers (
    customer_id          INT UNSIGNED NOT NULL,
    customer_code        VARCHAR(20) NOT NULL,
    full_name            VARCHAR(150) NOT NULL,
    gender               VARCHAR(20) NOT NULL,
    dob                  DATE NOT NULL,
    mobile               VARCHAR(20) NOT NULL,
    email                VARCHAR(255) NOT NULL,
    address_line1        VARCHAR(255) NOT NULL,
    area                 VARCHAR(100) NOT NULL,
    landmark             VARCHAR(150) NULL,
    city_id              INT UNSIGNED NOT NULL,
    state_id             INT UNSIGNED NOT NULL,
    pincode              VARCHAR(10) NOT NULL,
    join_date            DATE NOT NULL,
    customer_segment_id  INT UNSIGNED NOT NULL,
    loyalty_tier_id      INT UNSIGNED NOT NULL,
    customer_status_id   INT UNSIGNED NOT NULL,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uk_customers_code (customer_code),
    UNIQUE KEY uk_customers_mobile (mobile),
    UNIQUE KEY uk_customers_email (email),
    INDEX idx_customers_city_state (city_id, state_id),
    INDEX idx_customers_segment (customer_segment_id),
    INDEX idx_customers_loyalty (loyalty_tier_id),
    INDEX idx_customers_status (customer_status_id),
    CONSTRAINT fk_customers_city_state
        FOREIGN KEY (city_id, state_id)
        REFERENCES cities(city_id, state_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_customers_segment
        FOREIGN KEY (customer_segment_id)
        REFERENCES customer_segments(customer_segment_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_customers_loyalty
        FOREIGN KEY (loyalty_tier_id)
        REFERENCES loyalty_tiers(loyalty_tier_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_customers_status
        FOREIGN KEY (customer_status_id)
        REFERENCES customer_status(customer_status_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_customers_gender CHECK (gender IN ('Male','Female','Other')),
    CONSTRAINT chk_customers_pincode CHECK (pincode REGEXP '^[0-9]{5,10}$')
) ENGINE=InnoDB;

-- ============================================================
-- 22. ORDERS
-- Dependency: customers, cities, order_channel, sales_channel, order_status
-- ============================================================
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (

    order_id                    INT UNSIGNED NOT NULL,
    order_number                VARCHAR(30) NOT NULL,
    customer_id                 INT UNSIGNED NOT NULL,

    order_date                  DATE NOT NULL,
    order_time                  TIME NOT NULL,

    billing_city_id             INT UNSIGNED NOT NULL,
    shipping_city_id            INT UNSIGNED NOT NULL,

    billing_state_id            INT UNSIGNED NOT NULL,
    shipping_state_id           INT UNSIGNED NOT NULL,

    order_channel_id            INT UNSIGNED NOT NULL,
    sales_channel_id            INT UNSIGNED NOT NULL,

    sub_total                   DECIMAL(14,2) NOT NULL,
    discount_rate               DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    discount_amount             DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    shipping_charge             DECIMAL(14,2) NOT NULL DEFAULT 0.00,

    tax_rate                    DECIMAL(5,2) NULL,
    tax_amount                  DECIMAL(14,2) NOT NULL DEFAULT 0.00,

    grand_total                 DECIMAL(14,2) NOT NULL,

    order_status_id             INT UNSIGNED NOT NULL,

    packed_datetime             DATETIME NULL,
    shipped_datetime            DATETIME NULL,
    out_for_delivery_datetime   DATETIME NULL,
    delivered_datetime          DATETIME NULL,
    cancelled_datetime          DATETIME NULL,

    created_order_number        BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (order_id),

    UNIQUE KEY uk_orders_order_number (order_number),
    UNIQUE KEY uk_orders_created_number (created_order_number),

    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_order_date (order_date),
    INDEX idx_orders_billing_city (billing_city_id),
    INDEX idx_orders_shipping_city (shipping_city_id),
    INDEX idx_orders_billing_state (billing_state_id),
    INDEX idx_orders_shipping_state (shipping_state_id),
    INDEX idx_orders_order_channel (order_channel_id),
    INDEX idx_orders_sales_channel (sales_channel_id),
    INDEX idx_orders_status (order_status_id),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_billing_city
        FOREIGN KEY (billing_city_id)
        REFERENCES cities(city_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_shipping_city
        FOREIGN KEY (shipping_city_id)
        REFERENCES cities(city_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_billing_state
        FOREIGN KEY (billing_state_id)
        REFERENCES states(state_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_shipping_state
        FOREIGN KEY (shipping_state_id)
        REFERENCES states(state_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_order_channel
        FOREIGN KEY (order_channel_id)
        REFERENCES order_channel(order_channel_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_sales_channel
        FOREIGN KEY (sales_channel_id)
        REFERENCES sales_channel(sales_channel_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_status
        FOREIGN KEY (order_status_id)
        REFERENCES order_status(order_status_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_orders_discount_rate
        CHECK (discount_rate BETWEEN 0 AND 100),

    CONSTRAINT chk_orders_tax_rate
        CHECK (tax_rate IS NULL OR tax_rate BETWEEN 0 AND 100),

    CONSTRAINT chk_orders_subtotal
        CHECK (sub_total >= 0),

    CONSTRAINT chk_orders_discount_amount
        CHECK (discount_amount >= 0),

    CONSTRAINT chk_orders_shipping_charge
        CHECK (shipping_charge >= 0),

    CONSTRAINT chk_orders_tax_amount
        CHECK (tax_amount >= 0),

    CONSTRAINT chk_orders_grand_total
        CHECK (grand_total >= 0),

    CONSTRAINT chk_orders_discount_not_exceed_subtotal
        CHECK (discount_amount <= sub_total)

) ENGINE=InnoDB;

-- ============================================================
-- 23. ORDER ITEMS
-- Dependency: orders, products, warehouses
-- ============================================================
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id      BIGINT UNSIGNED NOT NULL,
    order_id           INT UNSIGNED NOT NULL,
    product_id         INT UNSIGNED NOT NULL,
    warehouse_id       INT UNSIGNED NOT NULL,
    quantity           INT UNSIGNED NOT NULL,
    unit_price         DECIMAL(14,2) NOT NULL,
    net_amount         DECIMAL(14,2) NOT NULL,
    discount_percent   DECIMAL(6,2) NOT NULL DEFAULT 0,
    discount_amount    DECIMAL(14,2) NOT NULL DEFAULT 0,
    line_total         DECIMAL(14,2) NOT NULL,
    cost_price         DECIMAL(14,2) NOT NULL,
    cost_total         DECIMAL(14,2) NOT NULL,
    PRIMARY KEY (order_item_id),
    UNIQUE KEY uk_order_items_order_item (order_id, order_item_id),
    INDEX idx_order_items_order (order_id),
    INDEX idx_order_items_product (product_id),
    INDEX idx_order_items_warehouse (warehouse_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_order_items_net CHECK (net_amount >= 0),
    CONSTRAINT chk_order_items_discount_percent CHECK (discount_percent BETWEEN 0 AND 100),
    CONSTRAINT chk_order_items_discount_amount CHECK (discount_amount >= 0),
    CONSTRAINT chk_order_items_line_total CHECK (line_total >= 0),
    CONSTRAINT chk_order_items_cost_price CHECK (cost_price >= 0),
    CONSTRAINT chk_order_items_cost_total CHECK (cost_total >= 0),
    CONSTRAINT chk_order_items_net_logic CHECK (net_amount = ROUND(quantity * unit_price, 2)),
    CONSTRAINT chk_order_items_line_logic CHECK (line_total = ROUND(net_amount - discount_amount, 2)),
    CONSTRAINT chk_order_items_cost_logic CHECK (cost_total = ROUND(quantity * cost_price, 2))
) ENGINE=InnoDB;

-- ============================================================
-- 24. PAYMENTS
-- Dependency: orders, payment_modes, payment_status
-- ============================================================
CREATE TABLE IF NOT EXISTS payments (
    payment_id          BIGINT UNSIGNED NOT NULL,
    order_id            int UNSIGNED NOT NULL,
    payment_datetime    DATETIME NOT NULL,
    payment_mode_id     INT UNSIGNED NOT NULL,
    payment_status_id   INT UNSIGNED NOT NULL,
    amount              DECIMAL(14,2) NOT NULL,
    refund_amount       DECIMAL(14,2) NOT NULL DEFAULT 0,
    payment_gateway_ref VARCHAR(100) NULL,
    bank_reference      VARCHAR(100) NULL,
    PRIMARY KEY (payment_id),
    UNIQUE KEY uk_payments_gateway_ref (payment_gateway_ref),
    INDEX idx_payments_order_datetime (order_id, payment_datetime),
    INDEX idx_payments_status (payment_status_id),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_payments_mode
        FOREIGN KEY (payment_mode_id)
        REFERENCES payment_modes(payment_mode_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_payments_status
        FOREIGN KEY (payment_status_id)
        REFERENCES payment_status(payment_status_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_payments_amount CHECK (amount >= 0),
    CONSTRAINT chk_payments_refund CHECK (refund_amount BETWEEN 0 AND amount)
) ENGINE=InnoDB;

-- ============================================================
-- 25. SHIPMENTS
-- Dependency: orders, warehouses, shipment_status, courier_partners
-- ============================================================
CREATE TABLE IF NOT EXISTS shipments (
    shipment_id            BIGINT UNSIGNED NOT NULL,
    order_id               INT UNSIGNED NOT NULL,
    warehouse_id            INT UNSIGNED NOT NULL,
    shipment_status_id      INT UNSIGNED NOT NULL,
    courier_partner_id      INT UNSIGNED NOT NULL,
    tracking_number         VARCHAR(100) NOT NULL,
    shipped_datetime        DATETIME NULL,
    delivered_datetime      DATETIME NULL,
    promised_delivery_date  DATE NULL,
    actual_delivery_date    DATE NULL,
    delivery_delay_days     INT NULL,
    PRIMARY KEY (shipment_id),
    UNIQUE KEY uk_shipments_tracking_number (tracking_number),
    INDEX idx_shipments_order (order_id),
    INDEX idx_shipments_warehouse (warehouse_id),
    INDEX idx_shipments_status (shipment_status_id),
    INDEX idx_shipments_courier (courier_partner_id),
    CONSTRAINT fk_shipments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_shipments_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_shipments_status
        FOREIGN KEY (shipment_status_id)
        REFERENCES shipment_status(shipment_status_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_shipments_courier
        FOREIGN KEY (courier_partner_id)
        REFERENCES courier_partners(courier_partner_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_shipments_delay CHECK (delivery_delay_days IS NULL OR delivery_delay_days >= 0)
) ENGINE=InnoDB;

-- ============================================================
-- 26. RETURNS
-- Dependency: orders, order_items, products, return_reason, return_status
-- ============================================================
CREATE TABLE IF NOT EXISTS returns (
    return_id         INT UNSIGNED NOT NULL,
    order_id          INT UNSIGNED NOT NULL,
    order_item_id     BIGINT UNSIGNED NOT NULL,
    product_id        INT UNSIGNED NOT NULL,
    return_reason_id  INT UNSIGNED NOT NULL,
    return_status_id  INT UNSIGNED NOT NULL,
    return_datetime   DATETIME NOT NULL,
    refund_amount     DECIMAL(14,2) NOT NULL DEFAULT 0,
    restock_flag      TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (return_id),
    INDEX idx_returns_order (order_id),
    INDEX idx_returns_item (order_item_id),
    INDEX idx_returns_product (product_id),
    INDEX idx_returns_status (return_status_id),
    INDEX idx_returns_reason (return_reason_id),
    CONSTRAINT fk_returns_order_item
        FOREIGN KEY (order_id, order_item_id)
        REFERENCES order_items(order_id, order_item_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_returns_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_returns_reason
        FOREIGN KEY (return_reason_id)
        REFERENCES return_reason(return_reason_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_returns_status
        FOREIGN KEY (return_status_id)
        REFERENCES return_status(return_status_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_returns_refund CHECK (refund_amount >= 0),
    CONSTRAINT chk_returns_restock CHECK (restock_flag IN (0,1))
) ENGINE=InnoDB;

-- ============================================================
-- 27. INVENTORY MOVEMENTS
-- Dependency: orders, products, warehouses, order_items, movement type
-- ============================================================
CREATE TABLE IF NOT EXISTS inventory_movements (
    movement_id              BIGINT UNSIGNED NOT NULL,
    order_id                 INT UNSIGNED NULL,
    product_id               INT UNSIGNED NOT NULL,
    warehouse_id             INT UNSIGNED NOT NULL,
    order_item_id            BIGINT UNSIGNED NULL,
    movement_type_id         INT UNSIGNED NOT NULL,
    movement_date            DATE NOT NULL,
    movement_time            TIME NOT NULL,
    opening_stock            INT UNSIGNED NOT NULL,
    closing_stock            INT UNSIGNED NOT NULL,
    remarks                  VARCHAR(255) NULL,
    product_dispatched_qty   INT UNSIGNED NULL,
    PRIMARY KEY (movement_id),
    INDEX idx_inventory_product_warehouse_date (product_id, warehouse_id, movement_date),
    INDEX idx_inventory_order (order_id),
    INDEX idx_inventory_item (order_item_id),
    INDEX idx_inventory_type (movement_type_id),
    CONSTRAINT fk_inventory_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_order_item
        FOREIGN KEY (order_id, order_item_id)
        REFERENCES order_items(order_id, order_item_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_movement_type
        FOREIGN KEY (movement_type_id)
        REFERENCES inventory_movement_type(movement_type_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_inventory_opening CHECK (opening_stock >= 0),
    CONSTRAINT chk_inventory_closing CHECK (closing_stock >= 0),
    CONSTRAINT chk_inventory_dispatched CHECK (
        product_dispatched_qty IS NULL OR product_dispatched_qty >= 0
    )
) ENGINE=InnoDB;

