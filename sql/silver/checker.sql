USE M5_Retail_DW;
GO

-- 1. Check Total Row Count (Must be exactly 59,181,090)
SELECT COUNT(*) AS total_rows FROM silver.m5_master;

-- 2. Check for unexpected NULLs in key business columns
SELECT 
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS null_ids,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS null_stores,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN sell_price IS NULL THEN 1 ELSE 0 END) AS null_prices
FROM silver.m5_master;

-- 3. Verify Date Range & Distinct Stores/Items
SELECT 
    MIN(date) AS min_date, 
    MAX(date) AS max_date, 
    COUNT(DISTINCT store_id) AS total_stores,
    COUNT(DISTINCT item_id) AS total_items
FROM silver.m5_master;