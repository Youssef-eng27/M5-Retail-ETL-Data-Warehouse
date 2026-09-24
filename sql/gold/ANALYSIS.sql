USE M5_Retail_DW;
GO

-- 1. Daily Sales Performance View
CREATE OR ALTER VIEW gold.vw_daily_sales_performance AS
SELECT 
    d.date,
    d.year,
    d.month,
    d.weekday,
    d.wm_yr_wk,
    SUM(f.sales) AS total_units_sold,
    SUM(f.revenue) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_date d ON f.date_key = d.date_key
GROUP BY d.date, d.year, d.month, d.weekday, d.wm_yr_wk;
GO

-- 2. Store & Category Performance View
CREATE OR ALTER VIEW gold.vw_store_category_performance AS
SELECT 
    s.store_id,
    s.state_id,
    i.cat_id,
    i.dept_id,
    SUM(f.sales) AS total_units_sold,
    SUM(f.revenue) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_store s ON f.store_key = s.store_key
JOIN gold.dim_item i ON f.item_key = i.item_key
GROUP BY s.store_id, s.state_id, i.cat_id, i.dept_id;
GO

-- 3. Top Item Performance View
CREATE OR ALTER VIEW gold.vw_item_performance AS
SELECT 
    i.item_id,
    i.cat_id,
    i.dept_id,
    SUM(f.sales) AS total_units_sold,
    SUM(f.revenue) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_item i ON f.item_key = i.item_key
GROUP BY i.item_id, i.cat_id, i.dept_id;
GO

PRINT '==================================================';
PRINT '✅ Analytics Views Created Successfully!';
PRINT '==================================================';
GO