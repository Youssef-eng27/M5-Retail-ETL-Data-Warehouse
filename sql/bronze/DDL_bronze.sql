-- 1. Create the Data Warehouse Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'M5_Retail_DW')
BEGIN
    CREATE DATABASE M5_Retail_DW;
END
GO

-- 2. Switch context to the new database
USE M5_Retail_DW;
GO
-- Create Bronze Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze;');
END
GO

-- Create Silver Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver;');
END
GO

-- Create Gold Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold;');
END
GO

-- 1. Create Bronze Calendar Table
IF OBJECT_ID('bronze.calendar', 'U') IS NOT NULL 
    DROP TABLE bronze.calendar;
GO

CREATE TABLE bronze.calendar (
    date DATE NULL,
    wm_yr_wk INT NULL,
    weekday VARCHAR(20) NULL,
    wday INT NULL,
    month INT NULL,
    year INT NULL,
    d VARCHAR(10) NULL,
    event_name_1 VARCHAR(50) NULL,
    event_type_1 VARCHAR(50) NULL,
    event_name_2 VARCHAR(50) NULL,
    event_type_2 VARCHAR(50) NULL,
    snap_CA INT NULL,
    snap_TX INT NULL,
    snap_WI INT NULL
);
GO

-- 2. Create Bronze Sell Prices Table
IF OBJECT_ID('bronze.sell_prices', 'U') IS NOT NULL 
    DROP TABLE bronze.sell_prices;
GO

CREATE TABLE bronze.sell_prices (
    store_id VARCHAR(20) NULL,
    item_id VARCHAR(50) NULL,
    wm_yr_wk INT NULL,
    sell_price DECIMAL(10, 2) NULL
);
GO