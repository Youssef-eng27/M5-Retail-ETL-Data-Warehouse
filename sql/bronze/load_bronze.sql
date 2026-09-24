USE M5_Retail_DW;
GO

-- 1. Load Data into bronze.calendar
TRUNCATE TABLE bronze.calendar;
GO

BULK INSERT bronze.calendar
FROM 'C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source\calendar.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- \n in Hexadecimal
    TABLOCK
);
GO

-- 2. Load Data into bronze.sell_prices
TRUNCATE TABLE bronze.sell_prices;
GO

BULK INSERT bronze.sell_prices
FROM 'C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source\sell_prices.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- \n in Hexadecimal
    TABLOCK
);
GO