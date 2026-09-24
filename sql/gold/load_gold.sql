USE M5_Retail_DW;
GO

PRINT '==================================================';
PRINT '🚀 Starting Gold Layer Loading Procedure...';
PRINT '==================================================';

--------------------------------------------------
-- 1. Populate gold.dim_date
--------------------------------------------------
PRINT '1/4 Populating gold.dim_date...';

DELETE FROM gold.dim_date;

INSERT INTO gold.dim_date (
    date_key, date, wm_yr_wk, weekday, wday, month, year,
    event_name_1, event_type_1, event_name_2, event_type_2,
    snap_CA, snap_TX, snap_WI
)
SELECT DISTINCT
    CAST(CONVERT(VARCHAR(8), date, 112) AS INT) AS date_key,
    date,
    wm_yr_wk,
    weekday,
    wday,
    month,
    year,
    event_name_1,
    event_type_1,
    event_name_2,
    event_type_2,
    snap_CA,
    snap_TX,
    snap_WI
FROM silver.m5_master;

PRINT '   └─ Date dimension loaded successfully.';

--------------------------------------------------
-- 2. Populate gold.dim_store
--------------------------------------------------
PRINT '2/4 Populating gold.dim_store...';

DELETE FROM gold.dim_store;

INSERT INTO gold.dim_store (store_id, state_id)
SELECT DISTINCT
    store_id,
    state_id
FROM silver.m5_master;

PRINT '   └─ Store dimension loaded successfully.';

--------------------------------------------------
-- 3. Populate gold.dim_item
--------------------------------------------------
PRINT '3/4 Populating gold.dim_item...';

DELETE FROM gold.dim_item;

INSERT INTO gold.dim_item (item_id, dept_id, cat_id)
SELECT DISTINCT
    item_id,
    dept_id,
    cat_id
FROM silver.m5_master;

PRINT '   └─ Item dimension loaded successfully.';

--------------------------------------------------
-- 4. Populate gold.fact_sales (High-Performance Insert)
--------------------------------------------------
PRINT '4/4 Populating gold.fact_sales from silver.m5_master...';

TRUNCATE TABLE gold.fact_sales;

-- Disable FK Constraints temporarily for faster insert
ALTER TABLE gold.fact_sales NOCHECK CONSTRAINT ALL;

INSERT INTO gold.fact_sales WITH (TABLOCK) (
    date_key,
    store_key,
    item_key,
    sales,
    sell_price,
    revenue
)
SELECT 
    d.date_key,
    s.store_key,
    i.item_key,
    m.sales,
    m.sell_price,
    CAST(m.sales * ISNULL(m.sell_price, 0) AS DECIMAL(12, 2)) AS revenue
FROM silver.m5_master m
INNER JOIN gold.dim_date d ON m.date = d.date
INNER JOIN gold.dim_store s ON m.store_id = s.store_id
INNER JOIN gold.dim_item i ON m.item_id = i.item_id;

-- Re-enable FK Constraints
ALTER TABLE gold.fact_sales CHECK CONSTRAINT ALL;

PRINT '==================================================';
PRINT '✅ Gold Layer Loading Completed Successfully!';
PRINT '==================================================';
GO



USE M5_Retail_DW;
GO

-- Index for Date & Item lookups (Most common analytical queries)
CREATE NONCLUSTERED INDEX IX_fact_sales_date_item 
ON gold.fact_sales (date_key, item_key) 
INCLUDE (sales, revenue);

-- Index for Store lookups
CREATE NONCLUSTERED INDEX IX_fact_sales_store 
ON gold.fact_sales (store_key) 
INCLUDE (sales, revenue);
GO