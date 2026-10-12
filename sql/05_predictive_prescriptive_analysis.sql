-- ============================================================================
-- PROJECT BHARAT-FLOW: TYPE 3 - PREDICTIVE & PRESCRIPTIVE ANALYTICS
-- Focus: Multi-dimensional ABC-XYZ Inventory Matrix, Prescriptive Safety Stock /
-- Dynamic Reorder Points (ROP), Economic Order Quantity (EOQ), and Customer RFM Segmentation.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 3.1: Multi-Dimensional ABC-XYZ Inventory Matrix
-- Evaluates Pareto Annual Consumption Value (ABC: 80/15/5) and Demand Predictability
-- via Coefficient of Variation of Monthly Demand (XYZ: X < 0.5, Y 0.5-1.0, Z > 1.0).
-- Prescribes 9 distinct stocking and procurement policies.
-- ----------------------------------------------------------------------------
WITH MonthlySkuDemand AS (
    SELECT 
        oi.product_id,
        SUBSTR(o.order_date, 1, 7) AS order_month,
        SUM(oi.quantity) AS monthly_units,
        SUM(oi.line_total_inr) AS monthly_revenue_inr
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY oi.product_id, SUBSTR(o.order_date, 1, 7)
),
SkuDemandMetrics AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.unit_cost_inr,
        p.mrp_inr,
        COALESCE(SUM(msd.monthly_units), 0) AS total_annual_units,
        COALESCE(SUM(msd.monthly_revenue_inr), 0) AS total_annual_revenue_inr,
        AVG(msd.monthly_units) AS avg_monthly_units,
        ROUND(
            SQRT(
                AVG(msd.monthly_units * msd.monthly_units) - 
                (AVG(msd.monthly_units) * AVG(msd.monthly_units))
            ), 2
        ) AS stddev_monthly_units
    FROM products p
    LEFT JOIN MonthlySkuDemand msd ON p.product_id = msd.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.unit_cost_inr, p.mrp_inr
),
SkuCoefficientOfVariation AS (
    SELECT 
        *,
        CASE 
            WHEN avg_monthly_units IS NULL OR avg_monthly_units = 0 THEN 999.0
            ELSE ROUND(stddev_monthly_units / avg_monthly_units, 3)
        END AS cv_demand,
        SUM(total_annual_revenue_inr) OVER () AS network_total_revenue_inr,
        ROUND(
            SUM(total_annual_revenue_inr) OVER (ORDER BY total_annual_revenue_inr DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) /
            SUM(total_annual_revenue_inr) OVER () * 100, 2
        ) AS cumulative_revenue_pct
    FROM SkuDemandMetrics
),
AbcXyzClassified AS (
    SELECT 
        product_id,
        product_name,
        category,
        unit_cost_inr,
        mrp_inr,
        total_annual_units,
        total_annual_revenue_inr,
        avg_monthly_units,
        stddev_monthly_units,
        cv_demand,
        cumulative_revenue_pct,
        CASE 
            WHEN cumulative_revenue_pct <= 80.0 THEN 'A'
            WHEN cumulative_revenue_pct <= 95.0 THEN 'B'
            ELSE 'C'
        END AS abc_class,
        CASE 
            WHEN cv_demand <= 0.45 THEN 'X'
            WHEN cv_demand <= 0.85 THEN 'Y'
            ELSE 'Z'
        END AS xyz_class
    FROM SkuCoefficientOfVariation
)
SELECT 
    product_id,
    product_name,
    category,
    total_annual_units,
    total_annual_revenue_inr,
    cv_demand,
    abc_class,
    xyz_class,
    (abc_class || xyz_class) AS abc_xyz_segment,
    CASE (abc_class || xyz_class)
        WHEN 'AX' THEN 'High Value, High Predictability: Just-In-Time (JIT) / Automated Continuous Replenishment'
        WHEN 'AY' THEN 'High Value, Moderate Predictability: Dynamic Buffer Sizing with Strict Weekly Reviews'
        WHEN 'AZ' THEN 'High Value, Erratic Volatility: Centralized Safety Buffer, Strict Make-to-Order / Batch Pull'
        WHEN 'BX' THEN 'Medium Value, High Predictability: Standard Periodic Reorder System with Fixed Safety Stock'
        WHEN 'BY' THEN 'Medium Value, Moderate Predictability: Continuous Review (s, S) System with Buffer Stock'
        WHEN 'BZ' THEN 'Medium Value, Erratic Volatility: Consignment Stocking or Supplier-Managed Buffer'
        WHEN 'CX' THEN 'Low Value, High Predictability: Bulk Two-Bin Ordering to Minimize Transaction Costs'
        WHEN 'CY' THEN 'Low Value, Moderate Predictability: Quarterly Economic Order Quantity (EOQ) Batches'
        WHEN 'CZ' THEN 'Low Value, Erratic Volatility: Minimal Stocking, Decentralized Local Procurement on Demand'
    END AS prescriptive_inventory_policy
FROM AbcXyzClassified
ORDER BY total_annual_revenue_inr DESC;

-- ----------------------------------------------------------------------------
-- QUERY 3.2: Prescriptive Reorder Point (ROP), Safety Stock (SS) & EOQ Optimization
-- Dynamically integrates daily demand variance and supplier lead-time variance:
-- Formula: SS = Z * sqrt(L * sigma_d^2 + d^2 * sigma_L^2) at 95% SLA (Z = 1.65).
-- Formula: ROP = (d * L) + SS.
-- Formula: EOQ = sqrt((2 * Annual_Demand * Ordering_Cost) / Annual_Holding_Cost).
-- ----------------------------------------------------------------------------
WITH SkuSalesDaily AS (
    SELECT 
        oi.product_id,
        SUM(oi.quantity) / 365.0 AS avg_daily_demand_d,
        SQRT(
            (AVG(oi.quantity * oi.quantity) - AVG(oi.quantity) * AVG(oi.quantity))
        ) AS sigma_daily_demand
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY oi.product_id
),
InventoryAggregates AS (
    SELECT 
        product_id,
        SUM(current_stock_units) AS network_on_hand_units,
        SUM(stockout_events_l90d) AS network_stockouts_l90d
    FROM inventory
    GROUP BY product_id
)
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    s.supplier_name,
    s.contract_lead_time_days AS lead_time_L,
    s.lead_time_std_dev AS sigma_lead_time,
    ROUND(ssd.avg_daily_demand_d, 2) AS avg_daily_demand,
    ia.network_on_hand_units,
    ROUND(
        1.65 * SQRT(
            (s.contract_lead_time_days * (ssd.sigma_daily_demand * ssd.sigma_daily_demand)) +
            ((ssd.avg_daily_demand_d * ssd.avg_daily_demand_d) * (s.lead_time_std_dev * s.lead_time_std_dev))
        ), 0
    ) AS prescriptive_safety_stock_units,
    ROUND(
        (ssd.avg_daily_demand_d * s.contract_lead_time_days) +
        (1.65 * SQRT(
            (s.contract_lead_time_days * (ssd.sigma_daily_demand * ssd.sigma_daily_demand)) +
            ((ssd.avg_daily_demand_d * ssd.avg_daily_demand_d) * (s.lead_time_std_dev * s.lead_time_std_dev))
        )), 0
    ) AS prescriptive_reorder_point_units,
    ROUND(
        SQRT(
            (2.0 * (ssd.avg_daily_demand_d * 365.0) * p.ordering_cost_inr) /
            (p.unit_cost_inr * p.holding_cost_rate_annual)
        ), 0
    ) AS prescriptive_eoq_units,
    CASE 
        WHEN ia.network_on_hand_units <= ROUND(
            (ssd.avg_daily_demand_d * s.contract_lead_time_days) +
            (1.65 * SQRT(
                (s.contract_lead_time_days * (ssd.sigma_daily_demand * ssd.sigma_daily_demand)) +
                ((ssd.avg_daily_demand_d * ssd.avg_daily_demand_d) * (s.lead_time_std_dev * s.lead_time_std_dev))
            )), 0) * 0.75 THEN 'CRITICAL: Stock Depleted Below Safety Margin (Immediate PO Required)'
        WHEN ia.network_on_hand_units <= ROUND(
            (ssd.avg_daily_demand_d * s.contract_lead_time_days) +
            (1.65 * SQRT(
                (s.contract_lead_time_days * (ssd.sigma_daily_demand * ssd.sigma_daily_demand)) +
                ((ssd.avg_daily_demand_d * ssd.avg_daily_demand_d) * (s.lead_time_std_dev * s.lead_time_std_dev))
            )), 0) THEN 'WARNING: At Reorder Point (Trigger EOQ Replenishment)'
        WHEN ia.network_on_hand_units > ROUND(
            (ssd.avg_daily_demand_d * s.contract_lead_time_days) +
            (1.65 * SQRT(
                (s.contract_lead_time_days * (ssd.sigma_daily_demand * ssd.sigma_daily_demand)) +
                ((ssd.avg_daily_demand_d * ssd.avg_daily_demand_d) * (s.lead_time_std_dev * s.lead_time_std_dev))
            )), 0) * 3.5 THEN 'EXCESS: Overstocked (Risk of Holding Cost Inefficiency / Spoilage)'
        ELSE 'HEALTHY: Balanced Inventory Position'
    END AS prescriptive_inventory_health_flag
FROM products p
JOIN suppliers s ON p.primary_supplier_id = s.supplier_id
JOIN SkuSalesDaily ssd ON p.product_id = ssd.product_id
JOIN InventoryAggregates ia ON p.product_id = ia.product_id
ORDER BY prescriptive_safety_stock_units DESC;

-- ----------------------------------------------------------------------------
-- QUERY 3.3: Customer RFM (Recency, Frequency, Monetary) Segmentation & CLV Model
-- Recency benchmark date: 2026-09-30.
-- Segmenting customers into Champions, Loyalists, Potential Loyalists, At Risk,
-- and Hibernating with targeted operational retention playbooks.
-- ----------------------------------------------------------------------------
WITH CustomerRawRFM AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.city,
        c.tier,
        c.zone,
        c.customer_type,
        c.preferred_payment_mode,
        CAST((JULIANDAY('2026-09-30') - JULIANDAY(MAX(o.order_date))) AS INTEGER) AS recency_days,
        COUNT(DISTINCT CASE WHEN o.order_status = 'Delivered' THEN o.order_id END) AS frequency_orders,
        COALESCE(SUM(CASE WHEN o.order_status = 'Delivered' THEN oi.line_total_inr ELSE 0 END), 0) AS monetary_spend_inr,
        AVG(CASE WHEN o.order_status = 'Delivered' THEN o.customer_rating END) AS avg_delivered_rating
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.city, c.tier, c.zone, c.customer_type, c.preferred_payment_mode
),
CustomerRFMScored AS (
    SELECT 
        customer_id,
        customer_name,
        city,
        tier,
        zone,
        customer_type,
        preferred_payment_mode,
        recency_days,
        frequency_orders,
        monetary_spend_inr,
        avg_delivered_rating,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency_orders ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_spend_inr ASC) AS m_score
    FROM CustomerRawRFM
    WHERE frequency_orders > 0
),
CustomerSegmented AS (
    SELECT 
        *,
        (r_score * 100 + f_score * 10 + m_score) AS rfm_combined_score,
        CASE 
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 3 AND f_score < 3 THEN 'Potential Loyalists / Promising'
            WHEN r_score = 2 AND f_score >= 3 THEN 'At Risk / High Value Slipping'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Hibernating / Churned'
            ELSE 'Need Attention / Occasional'
        END AS rfm_segment
    FROM CustomerRFMScored
)
SELECT 
    rfm_segment,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency_orders), 1) AS avg_frequency_orders,
    ROUND(AVG(monetary_spend_inr), 2) AS avg_monetary_spend_inr,
    ROUND(SUM(monetary_spend_inr), 2) AS total_segment_revenue_inr,
    ROUND((SUM(monetary_spend_inr) / (SELECT SUM(monetary_spend_inr) FROM CustomerSegmented)) * 100, 2) AS revenue_contribution_pct,
    ROUND(AVG(avg_delivered_rating), 2) AS avg_customer_satisfaction,
    CASE rfm_segment
        WHEN 'Champions' THEN 'Reward with early-access ONDC network deals, zero-delivery fee passes, and VIP rapid dispatch SLA.'
        WHEN 'Loyal Customers' THEN 'Upsell adjacent categories with personalized bundle recommendations.'
        WHEN 'Potential Loyalists / Promising' THEN 'Incentivize repeat cadence via UPI cashback vouchers on next 2 orders placed within 14 days.'
        WHEN 'At Risk / High Value Slipping' THEN 'Trigger automated win-back SMS/WhatsApp with personalized discounts on their historically favored staples.'
        WHEN 'Hibernating / Churned' THEN 'Send low-cost re-engagement survey with free sample coupon and prune marketing spend if non-responsive after 45 days.'
        ELSE 'Deploy re-order reminder alerts timed to their estimated household product replenishment cycle.'
    END AS prescriptive_retention_playbook
FROM CustomerSegmented
GROUP BY rfm_segment
ORDER BY total_segment_revenue_inr DESC;
