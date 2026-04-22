-- =============================================================================
-- Project:     Superstore Sales Forecasting
-- Tool:        PostgreSQL
-- Description: SQL analysis of the Superstore dataset (2014–2017).
--              Queries cover business KPIs, regional performance, category
--              profitability, monthly trends, and segment analysis.
--              Results were used to build a 3-page Power BI dashboard.
-- =============================================================================


-- =============================================================================
-- SETUP: Table Schema
-- =============================================================================

DROP TABLE IF EXISTS superstore;

CREATE TABLE superstore (
    row_id          INTEGER,
    order_id        VARCHAR(20),
    order_date      VARCHAR(20),
    ship_date       VARCHAR(20),
    ship_mode       VARCHAR(20),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(50),
    segment         VARCHAR(20),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    product_id      VARCHAR(20),
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(150),
    sales           NUMERIC(10,2),
    quantity        INTEGER,
    discount        NUMERIC(4,2),
    profit          NUMERIC(10,2)
);

-- Convert date columns from VARCHAR to DATE after import
ALTER TABLE superstore
    ALTER COLUMN order_date TYPE DATE
        USING TO_DATE(order_date, 'MM/DD/YYYY'),
    ALTER COLUMN ship_date TYPE DATE
        USING TO_DATE(ship_date, 'MM/DD/YYYY');


-- =============================================================================
-- QUERY 1: Business Overview KPIs
-- Purpose:  High-level summary of total revenue, profit, orders, and customers.
--           Used for the KPI cards on Page 1 (Sales Performance Overview).
-- =============================================================================

SELECT 
    ROUND(SUM(sales)::numeric, 2)            AS total_revenue,
    ROUND(SUM(profit)::numeric, 2)           AS total_profit,
    COUNT(DISTINCT order_id)                 AS total_orders,
    COUNT(DISTINCT customer_id)              AS total_customers
FROM superstore;


-- =============================================================================
-- QUERY 2: Revenue and Profit by Category
-- Purpose:  Compares revenue vs profit across the three product categories.
--           Used for the Revenue vs Profit by Category chart on Page 2.
-- =============================================================================

SELECT 
    category,
    ROUND(SUM(sales)::numeric, 2)            AS total_revenue,
    ROUND(SUM(profit)::numeric, 2)           AS total_profit
FROM superstore
GROUP BY category
ORDER BY total_revenue DESC;


-- =============================================================================
-- QUERY 3: Revenue and Profit by Region
-- Purpose:  Identifies which regions generate the most revenue and profit.
--           Used for the Revenue by Region and Profit by Region charts on Page 1.
-- =============================================================================

SELECT 
    region,
    ROUND(SUM(sales)::numeric, 2)            AS total_revenue,
    ROUND(SUM(profit)::numeric, 2)           AS total_profit
FROM superstore
GROUP BY region
ORDER BY total_revenue DESC;


-- =============================================================================
-- QUERY 4: Monthly Revenue Trend
-- Purpose:  Tracks revenue, profit, and order volume month by month.
--           Used for the Monthly Revenue Trend chart on Page 1
--           and as the base data for the 12-month forecast on Page 3.
-- =============================================================================

SELECT 
    DATE_TRUNC('month', order_date)::DATE    AS month,
    ROUND(SUM(sales)::numeric, 2)            AS monthly_revenue,
    ROUND(SUM(profit)::numeric, 2)           AS monthly_profit,
    COUNT(DISTINCT order_id)                 AS monthly_orders
FROM superstore
GROUP BY DATE_TRUNC('month', order_date)::DATE
ORDER BY month;


-- =============================================================================
-- QUERY 5: Monthly Revenue by Category
-- Purpose:  Breaks down monthly revenue by product category.
--           Supports category trend analysis on Page 2.
-- =============================================================================

SELECT 
    DATE_TRUNC('month', order_date)::DATE    AS month,
    category,
    ROUND(SUM(sales)::numeric, 2)            AS monthly_revenue
FROM superstore
GROUP BY DATE_TRUNC('month', order_date)::DATE, category
ORDER BY month, category;


-- =============================================================================
-- QUERY 6: Revenue and Profit by Sub-Category
-- Purpose:  Drills into sub-category performance to identify profit drivers
--           and loss-makers (e.g. Tables at -$17K).
--           Used for the Profit by Sub-Category chart on Page 2.
-- =============================================================================

SELECT 
    sub_category,
    category,
    ROUND(SUM(sales)::numeric, 2)            AS total_revenue,
    ROUND(SUM(profit)::numeric, 2)           AS total_profit
FROM superstore
GROUP BY sub_category, category
ORDER BY total_revenue DESC;


-- =============================================================================
-- QUERY 7: Annual Revenue Summary
-- Purpose:  Year-over-year revenue, profit, and order volume (2014–2017).
--           Used for the Revenue by Year chart on Page 1.
-- =============================================================================

SELECT 
    EXTRACT(YEAR FROM order_date)            AS year,
    ROUND(SUM(sales)::numeric, 2)            AS total_revenue,
    ROUND(SUM(profit)::numeric, 2)           AS total_profit,
    COUNT(DISTINCT order_id)                 AS total_orders
FROM superstore
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;


-- =============================================================================
-- QUERY 8: Profit Margin by Customer Segment
-- Purpose:  Compares profitability across Consumer, Corporate, and Home Office.
--           Used for the Profit Margin by Segment chart on Page 2.
-- =============================================================================

SELECT
    segment,
    ROUND(SUM(sales)::numeric, 2)                       AS total_revenue,
    ROUND(SUM(profit)::numeric, 2)                      AS total_profit,
    ROUND((SUM(profit) / SUM(sales) * 100)::numeric, 2) AS profit_margin_pct
FROM superstore
GROUP BY segment
ORDER BY profit_margin_pct DESC;


-- =============================================================================
-- End of Analysis
-- =============================================================================
