-- ============================================================================
-- PROJECT BHARAT-FLOW: ONDC PAN-INDIA RETAIL & KIRANA NETWORK
-- DDL SCHEMA SPECIFICATION & TABLE DEFINITIONS
-- Compatible with: PostgreSQL, SQLite, MySQL 8.0+, DuckDB
-- ============================================================================

-- 1. SUPPLIERS MASTER TABLE
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id VARCHAR(20) PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    zone VARCHAR(30) NOT NULL, -- North, South, East, West, Central, North-East
    reliability_score DECIMAL(4, 2) NOT NULL, -- 0.00 to 1.00
    contract_lead_time_days INTEGER NOT NULL,
    lead_time_std_dev DECIMAL(4, 2) NOT NULL
);

-- 2. FULFILLMENT HUBS MASTER TABLE
CREATE TABLE IF NOT EXISTS fulfillment_hubs (
    hub_id VARCHAR(20) PRIMARY KEY,
    hub_name VARCHAR(150) NOT NULL,
    hub_type VARCHAR(50) NOT NULL, -- Central Warehouse, Regional Hub, Micro-Fulfillment Center, Kirana Network Participant
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    tier VARCHAR(20) NOT NULL, -- Tier-1, Tier-2, Tier-3
    zone VARCHAR(30) NOT NULL,
    storage_capacity_sqft INTEGER NOT NULL,
    operating_cost_per_sqft_inr DECIMAL(8, 2) NOT NULL
);

-- 3. PRODUCTS CATALOG TABLE (SKU MASTER)
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(80) NOT NULL,
    sub_category VARCHAR(80) NOT NULL,
    unit_cost_inr DECIMAL(10, 2) NOT NULL,
    mrp_inr DECIMAL(10, 2) NOT NULL,
    holding_cost_rate_annual DECIMAL(4, 2) NOT NULL, -- e.g., 0.18 (18%)
    ordering_cost_inr DECIMAL(8, 2) NOT NULL,
    min_order_qty INTEGER NOT NULL,
    shelf_life_days INTEGER NOT NULL,
    is_perishable BOOLEAN NOT NULL,
    primary_supplier_id VARCHAR(20) NOT NULL,
    FOREIGN KEY (primary_supplier_id) REFERENCES suppliers(supplier_id)
);

-- 4. CUSTOMERS MASTER TABLE
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    tier VARCHAR(20) NOT NULL,
    zone VARCHAR(30) NOT NULL,
    signup_date DATE NOT NULL,
    customer_type VARCHAR(80) NOT NULL, -- Retail Consumer, Micro-Enterprise / Kirana Reseller, Healthcare Clinic / Dispensary
    preferred_payment_mode VARCHAR(50) NOT NULL, -- UPI, RuPay Debit, NetBanking, Cash on Delivery (COD)
    buyer_app_channel VARCHAR(80) NOT NULL -- ONDC Buyer App - Paytm, Magicpin, Mystore, Direct Hyperlocal Web
);

-- 5. INVENTORY SNAPSHOT TABLE
CREATE TABLE IF NOT EXISTS inventory (
    inventory_id VARCHAR(20) PRIMARY KEY,
    hub_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    current_stock_units INTEGER NOT NULL,
    safety_stock_units INTEGER NOT NULL,
    reorder_point_units INTEGER NOT NULL,
    max_capacity_units INTEGER NOT NULL,
    stockout_events_l90d INTEGER NOT NULL,
    last_replenished_date DATE NOT NULL,
    unit_carrying_cost_annual_inr DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (hub_id) REFERENCES fulfillment_hubs(hub_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 6. ORDERS HEADER TABLE
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    hub_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    delivery_date DATE,
    order_status VARCHAR(40) NOT NULL, -- Delivered, Cancelled_Stockout, Cancelled_Customer, Returned
    payment_method VARCHAR(50) NOT NULL,
    delivery_time_hours DECIMAL(6, 2),
    sla_target_hours DECIMAL(6, 2) NOT NULL,
    sla_breached_flag INTEGER NOT NULL, -- 0 or 1
    customer_rating INTEGER, -- 1 to 5
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (hub_id) REFERENCES fulfillment_hubs(hub_id)
);

-- 7. ORDER LINE ITEMS TABLE
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id VARCHAR(25) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price_inr DECIMAL(10, 2) NOT NULL,
    discount_inr DECIMAL(10, 2) NOT NULL,
    line_total_inr DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- OPTIMIZATION INDEXES
CREATE INDEX IF NOT EXISTS idx_orders_cust ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_hub ON orders(hub_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_items_prod ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_inv_hub_prod ON inventory(hub_id, product_id);
