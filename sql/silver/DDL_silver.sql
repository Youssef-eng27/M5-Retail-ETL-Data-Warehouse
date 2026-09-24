USE M5_Retail_DW;
GO

-- Create Silver Master Table Structure
IF OBJECT_ID('silver.m5_master', 'U') IS NOT NULL 
    DROP TABLE silver.m5_master;
GO

CREATE TABLE silver.m5_master (
    id VARCHAR(100) NOT NULL,
    item_id VARCHAR(50) NOT NULL,
    dept_id VARCHAR(50) NOT NULL,
    cat_id VARCHAR(50) NOT NULL,
    store_id VARCHAR(20) NOT NULL,
    state_id VARCHAR(10) NOT NULL,
    d VARCHAR(10) NOT NULL,
    sales INT NOT NULL,
    date DATE NOT NULL,
    wm_yr_wk INT NOT NULL,
    weekday VARCHAR(20) NULL,
    wday INT NULL,
    month INT NULL,
    year INT NULL,
    event_name_1 VARCHAR(50) NULL,
    event_type_1 VARCHAR(50) NULL,
    event_name_2 VARCHAR(50) NULL,
    event_type_2 VARCHAR(50) NULL,
    snap_CA INT NULL,
    snap_TX INT NULL,
    snap_WI INT NULL,
    sell_price DECIMAL(10, 2) NULL
);
GO

-- Create Index for fast Gold Layer aggregations
CREATE NONCLUSTERED INDEX IX_silver_m5_master_date_store
ON silver.m5_master (date, store_id);
GO


-- 1. Ensure table is clean
TRUNCATE TABLE silver.m5_master;
GO

-- 2. Execute Fast Bulk Insert directly from SSMS engine
BULK INSERT silver.m5_master
FROM 'C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source\m5_silver_master.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  -- Handles standard \n line breaks cleanly
    BATCHSIZE = 500000,
    TABLOCK
);
GO