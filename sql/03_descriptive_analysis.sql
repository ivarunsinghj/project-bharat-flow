-- ============================================================================
-- PROJECT BHARAT-FLOW: TYPE 1 - DESCRIPTIVE ANALYSIS
-- Focus: Establishing baseline operational health, macro inventory valuation,
-- customer transaction patterns, and fulfillment performance across Indian tiers.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 1.1: Macro Inventory Health & Working Capital Tied Up Across Hubs
-- Evaluates total physical units, inventory valuation in INR, carrying costs,
-- and stockout frequency by facility archetype and city tier.
-- ----------------------------------------------------------------------------
SELECT 
    h.hub_type,
    h.tier,
    h.zone,
    COUNT(DISTINCT i.product_id) AS total_skus_stocked,
    SUM(i.current_stock_units) AS total_on_hand_units,
    ROUND(SUM(i.current_stock_units * p.unit_cost_inr), 2) AS total_inventory_value_inr,
    ROUND(SUM(i.current_stock_units * i.unit_carrying_cost_annual_inr), 2) AS annual_carrying_cost_inr,
    ROUND(AVG(CAST(i.current_stock_units AS FLOAT) / i.max_capacity_units) * 100, 2) AS avg_capacity_utilization_pct,
    SUM(i.stockout_events_l90d) AS total_stockout_events_l90d
FROM inventory i
JOIN fulfillment_hubs h ON i.hub_id = h.hub_id
JOIN products p ON i.product_id = p.product_id
GROUP BY h.hub_type, h.tier, h.zone
ORDER BY total_inventory_value_inr DESC;

-- ----------------------------------------------------------------------------
-- QUERY 1.2: SKU Performance, Sales Velocity, and Gross Margins by Category
-- Measures unit movement, gross merchandise value (GMV), discounts, and realized gross profit.
-- ----------------------------------------------------------------------------
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS active_skus,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.line_total_inr), 2) AS total_gross_revenue_inr,
    ROUND(SUM(oi.discount_inr), 2) AS total_discounts_given_inr,
    ROUND(SUM(oi.quantity * p.unit_cost_inr), 2) AS total_cogs_inr,
    ROUND(SUM(oi.line_total_inr) - SUM(oi.quantity * p.unit_cost_inr), 2) AS gross_profit_inr,
    ROUND(((SUM(oi.line_total_inr) - SUM(oi.quantity * p.unit_cost_inr)) / SUM(oi.line_total_inr)) * 100, 2) AS gross_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY total_gross_revenue_inr DESC;

-- ----------------------------------------------------------------------------
-- QUERY 1.3: Customer Base Distribution, Order Frequency, and AOV by City Tier
-- Evaluates demographic penetration, average order values (AOV), and customer spend depth.
-- ----------------------------------------------------------------------------
WITH CustomerSpend AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.tier,
        c.zone,
        c.customer_type,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(CASE WHEN o.order_status = 'Delivered' THEN oi.line_total_inr ELSE 0 END), 0) AS total_delivered_spend_inr
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.tier, c.zone, c.customer_type
)
SELECT 
    tier,
    zone,
    customer_type,
    COUNT(customer_id) AS total_registered_customers,
    SUM(CASE WHEN total_orders > 0 THEN 1 ELSE 0 END) AS active_transacting_customers,
    ROUND(CAST(SUM(CASE WHEN total_orders > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(customer_id) * 100, 2) AS customer_activation_rate_pct,
    SUM(total_orders) AS total_orders_placed,
    ROUND(SUM(total_delivered_spend_inr), 2) AS total_revenue_inr,
    ROUND(AVG(CASE WHEN total_orders > 0 THEN total_delivered_spend_inr / total_orders ELSE 0 END), 2) AS avg_order_value_inr
FROM CustomerSpend
GROUP BY tier, zone, customer_type
ORDER BY total_revenue_inr DESC;

-- ----------------------------------------------------------------------------
-- QUERY 1.4: Payment Method Penetration & Order Fulfillment SLA Compliance
-- Analyzes digital payment adoption (UPI, RuPay) vs COD and delivery time adherence.
-- ----------------------------------------------------------------------------
SELECT 
    o.payment_method,
    COUNT(o.order_id) AS total_orders,
    ROUND(CAST(COUNT(o.order_id) AS FLOAT) / (SELECT COUNT(*) FROM orders) * 100, 2) AS payment_share_pct,
    SUM(CASE WHEN o.order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN o.order_status = 'Cancelled_Stockout' THEN 1 ELSE 0 END) AS stockout_cancelled_orders,
    SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(AVG(CASE WHEN o.order_status = 'Delivered' THEN o.delivery_time_hours END), 2) AS avg_delivery_time_hours,
    ROUND(AVG(CASE WHEN o.order_status = 'Delivered' THEN o.sla_breached_flag END) * 100, 2) AS sla_breach_rate_pct,
    ROUND(AVG(o.customer_rating), 2) AS avg_csat_rating
FROM orders o
GROUP BY o.payment_method
ORDER BY total_orders DESC;
