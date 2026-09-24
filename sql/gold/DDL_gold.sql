USE M5_Retail_DW;
GO

-- 1. Create Schema if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

-- 2. Drop Fact table first (due to FK constraints)
IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL DROP TABLE gold.fact_sales;
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL DROP TABLE gold.dim_date;
IF OBJECT_ID('gold.dim_store', 'U') IS NOT NULL DROP TABLE gold.dim_store;
IF OBJECT_ID('gold.dim_item', 'U') IS NOT NULL DROP TABLE gold.dim_item;
GO

--------------------------------------------------
-- 1. Dimension: Date
--------------------------------------------------
CREATE TABLE gold.dim_date (
    date_key INT PRIMARY KEY,               -- YYYYMMDD format
    date DATE NOT NULL UNIQUE,
    wm_yr_wk INT NOT NULL,
    weekday VARCHAR(15) NOT NULL,
    wday INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    event_name_1 VARCHAR(50),
    event_type_1 VARCHAR(50),
    event_name_2 VARCHAR(50),
    event_type_2 VARCHAR(50),
    snap_CA INT NOT NULL,
    snap_TX INT NOT NULL,
    snap_WI INT NOT NULL
);
GO

--------------------------------------------------
-- 2. Dimension: Store
--------------------------------------------------
CREATE TABLE gold.dim_store (
    store_key INT IDENTITY(1,1) PRIMARY KEY,
    store_id VARCHAR(10) NOT NULL UNIQUE,
    state_id VARCHAR(5) NOT NULL
);
GO

--------------------------------------------------
-- 3. Dimension: Item
--------------------------------------------------
CREATE TABLE gold.dim_item (
    item_key INT IDENTITY(1,1) PRIMARY KEY,
    item_id VARCHAR(50) NOT NULL UNIQUE,
    dept_id VARCHAR(20) NOT NULL,
    cat_id VARCHAR(20) NOT NULL
);
GO

--------------------------------------------------
-- 4. Fact Table: Sales
--------------------------------------------------
CREATE TABLE gold.fact_sales (
    sales_key BIGINT IDENTITY(1,1) PRIMARY KEY,
    date_key INT NOT NULL,
    store_key INT NOT NULL,
    item_key INT NOT NULL,
    sales INT NOT NULL,
    sell_price DECIMAL(10, 2) NULL,
    revenue DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    
    CONSTRAINT FK_fact_sales_dim_date FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key),
    CONSTRAINT FK_fact_sales_dim_store FOREIGN KEY (store_key) REFERENCES gold.dim_store(store_key),
    CONSTRAINT FK_fact_sales_dim_item FOREIGN KEY (item_key) REFERENCES gold.dim_item(item_key)
);
GO