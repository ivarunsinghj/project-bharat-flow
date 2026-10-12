-- ============================================================================
-- PROJECT BHARAT-FLOW: TYPE 2 - DIAGNOSTIC & ROOT-CAUSE ANALYSIS
-- Focus: Diagnosing the underlying drivers of inventory stockouts, phantom stock,
-- upstream supplier lead-time variance, SLA breaches, and downstream customer churn.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 2.1: Stockout & Order Cancellation Attribution by Hub Type and Tier
-- Pinpoints where in the supply chain fulfillment failures are concentrated.
-- ----------------------------------------------------------------------------
WITH HubOrderStats AS (
    SELECT 
        h.hub_id,
        h.hub_name,
        h.hub_type,
        h.city,
        h.tier,
        h.zone,
        COUNT(o.order_id) AS total_orders_routed,
        SUM(CASE WHEN o.order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_count,
        SUM(CASE WHEN o.order_status = 'Cancelled_Stockout' THEN 1 ELSE 0 END) AS stockout_cancel_count,
        SUM(CASE WHEN o.order_status = 'Cancelled_Customer' THEN 1 ELSE 0 END) AS customer_cancel_count,
        SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_count,
        ROUND(AVG(CASE WHEN o.order_status = 'Delivered' THEN o.delivery_time_hours END), 2) AS avg_delivery_hours,
        ROUND(AVG(o.sla_breached_flag) * 100, 2) AS sla_breach_pct
    FROM fulfillment_hubs h
    LEFT JOIN orders o ON h.hub_id = o.hub_id
    GROUP BY h.hub_id, h.hub_name, h.hub_type, h.city, h.tier, h.zone
)
SELECT 
    hub_type,
    tier,
    COUNT(hub_id) AS total_hubs,
    SUM(total_orders_routed) AS total_orders,
    SUM(stockout_cancel_count) AS total_stockout_cancellations,
    ROUND((CAST(SUM(stockout_cancel_count) AS FLOAT) / SUM(total_orders_routed)) * 100, 2) AS stockout_cancellation_rate_pct,
    ROUND((CAST(SUM(customer_cancel_count) AS FLOAT) / SUM(total_orders_routed)) * 100, 2) AS customer_cancellation_rate_pct,
    ROUND((CAST(SUM(returned_count) AS FLOAT) / SUM(total_orders_routed)) * 100, 2) AS return_rate_pct,
    ROUND(AVG(sla_breach_pct), 2) AS avg_sla_breach_pct
FROM HubOrderStats
GROUP BY hub_type, tier
ORDER BY stockout_cancellation_rate_pct DESC;

-- ----------------------------------------------------------------------------
-- QUERY 2.2: Supplier Reliability & Lead Time Volatility Diagnostic
-- Correlates upstream supplier contract lead times and lead-time standard deviation
-- with downstream stockout frequencies for their supplied SKUs.
-- ----------------------------------------------------------------------------
SELECT 
    s.supplier_id,
    s.supplier_name,
    s.reliability_score,
    s.contract_lead_time_days,
    s.lead_time_std_dev,
    COUNT(DISTINCT p.product_id) AS skus_supplied,
    ROUND(AVG(i.stockout_events_l90d), 2) AS avg_stockout_events_per_hub,
    SUM(i.stockout_events_l90d) AS total_stockout_events_across_network,
    ROUND(AVG(CAST(i.current_stock_units AS FLOAT) / NULLIF(i.safety_stock_units, 0)), 2) AS avg_stock_to_safety_ratio
FROM suppliers s
JOIN products p ON s.supplier_id = p.primary_supplier_id
JOIN inventory i ON p.product_id = i.product_id
GROUP BY s.supplier_id, s.supplier_name, s.reliability_score, s.contract_lead_time_days, s.lead_time_std_dev
ORDER BY total_stockout_events_across_network DESC;

-- ----------------------------------------------------------------------------
-- QUERY 2.3: Downstream Customer Churn Diagnostic via Fulfillment SLA Breaches
-- Tests the hypothesis: Do delivery SLA breaches and stockout cancellations
-- cause customer churn, lower repeat rates, and suppressed review ratings?
-- ----------------------------------------------------------------------------
WITH CustomerFirstOrder AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),
CustomerFirstExperience AS (
    SELECT 
        o.customer_id,
        o.order_id AS first_order_id,
        o.order_status AS first_order_status,
        o.sla_breached_flag AS first_order_sla_breached,
        o.customer_rating AS first_order_rating
    FROM orders o
    JOIN CustomerFirstOrder cfo ON o.customer_id = cfo.customer_id AND o.order_date = cfo.first_order_date
),
CustomerTotalActivity AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders_lifetime,
        SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders_lifetime,
        AVG(customer_rating) AS avg_lifetime_rating
    FROM orders
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN cfe.first_order_status = 'Cancelled_Stockout' THEN 'First Order Stockout Cancelled'
        WHEN cfe.first_order_sla_breached = 1 THEN 'First Order SLA Breached (Delayed)'
        ELSE 'First Order Delivered On-Time'
    END AS initial_experience_cohort,
    COUNT(cfe.customer_id) AS total_customers_in_cohort,
    ROUND(AVG(cta.total_orders_lifetime), 2) AS avg_lifetime_orders,
    SUM(CASE WHEN cta.total_orders_lifetime > 1 THEN 1 ELSE 0 END) AS repeat_purchasers_count,
    ROUND((CAST(SUM(CASE WHEN cta.total_orders_lifetime > 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(cfe.customer_id)) * 100, 2) AS repeat_retention_rate_pct,
    ROUND(AVG(cta.avg_lifetime_rating), 2) AS avg_customer_satisfaction_rating
FROM CustomerFirstExperience cfe
JOIN CustomerTotalActivity cta ON cfe.customer_id = cta.customer_id
GROUP BY 
    CASE 
        WHEN cfe.first_order_status = 'Cancelled_Stockout' THEN 'First Order Stockout Cancelled'
        WHEN cfe.first_order_sla_breached = 1 THEN 'First Order SLA Breached (Delayed)'
        ELSE 'First Order Delivered On-Time'
    END
ORDER BY repeat_retention_rate_pct DESC;

-- ----------------------------------------------------------------------------
-- QUERY 2.4: Seasonal Logistics Friction: Monthly Monsoon & Festive Shock Diagnostic
-- Tracks monthly fulfillment velocity, delivery delays, and cancellation rates
-- across the 12-month operating window.
-- ----------------------------------------------------------------------------
SELECT 
    SUBSTR(order_date, 1, 7) AS order_year_month,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    ROUND(CAST(SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(order_id) * 100, 2) AS fulfillment_rate_pct,
    SUM(CASE WHEN order_status = 'Cancelled_Stockout' THEN 1 ELSE 0 END) AS stockout_cancellations,
    ROUND(CAST(SUM(CASE WHEN order_status = 'Cancelled_Stockout' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(order_id) * 100, 2) AS stockout_rate_pct,
    ROUND(AVG(CASE WHEN order_status = 'Delivered' THEN delivery_time_hours END), 2) AS avg_delivery_time_hrs,
    ROUND(AVG(sla_breached_flag) * 100, 2) AS sla_breach_rate_pct,
    ROUND(AVG(customer_rating), 2) AS avg_csat_rating,
    CASE 
        WHEN SUBSTR(order_date, 6, 2) IN ('07', '08') THEN 'Monsoon Season Supply Friction'
        WHEN SUBSTR(order_date, 6, 2) IN ('10', '11') THEN 'Diwali Festive Demand Surge'
        WHEN SUBSTR(order_date, 6, 2) = '01' THEN 'Republic Day / New Year Surge'
        ELSE 'Standard Baseline Operations'
    END AS operational_period_label
FROM orders
GROUP BY SUBSTR(order_date, 1, 7)
ORDER BY order_year_month ASC;
