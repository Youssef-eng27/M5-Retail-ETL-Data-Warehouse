import os
import time
import pandas as pd
import polars as pl

# ==============================================================================
# 0. CONFIGURATION & ENVIRONMENT SETUP
# ==============================================================================
# Define base paths for source CSV files and output Parquet destination
BASE_DIR = r"C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source"
OUTPUT_PARQUET = os.path.join(BASE_DIR, "m5_silver_master.parquet")

print("🚀 Starting Data Processing & Unpivot Pipeline...")
start_time = time.time()

# ==============================================================================
# 1. LOAD & OPTIMIZE DIMENSION DATASETS (Polars)
# ==============================================================================
print("\n📥 [1/4] Loading Calendar & Sell Prices...")

# Read calendar dataset and downcast integer types for optimal memory usage
calendar = pl.read_csv(os.path.join(BASE_DIR, "calendar.csv")).with_columns(
    [
        pl.col("wm_yr_wk").cast(pl.Int16),
        pl.col("wday").cast(pl.Int8),
        pl.col("month").cast(pl.Int8),
        pl.col("year").cast(pl.Int16),
        pl.col("snap_CA").cast(pl.Int8),
        pl.col("snap_TX").cast(pl.Int8),
        pl.col("snap_WI").cast(pl.Int8),
    ]
)

# Read sell prices dataset and convert repeated string features to Categorical data types
prices = pl.read_csv(os.path.join(BASE_DIR, "sell_prices.csv")).with_columns(
    [
        pl.col("store_id").cast(pl.Categorical),
        pl.col("item_id").cast(pl.Categorical),
        pl.col("wm_yr_wk").cast(pl.Int16),
        pl.col("sell_price").cast(pl.Float32),
    ]
)

# ==============================================================================
# 2. READ & UNPIVOT FACT SALES DATA (Wide-to-Long Transformation)
# ==============================================================================
print("\n🔄 [2/4] Reading Sales Data & Unpivoting (Wide to Long)...")

# Load historical daily sales evaluation dataset
sales = pl.read_csv(os.path.join(BASE_DIR, "sales_train_evaluation.csv"))

# Extract dynamic day column identifiers (d_1 to d_1941)
day_cols = [col for col in sales.columns if col.startswith("d_")]

# Unpivot sales table from Wide format to normalized Long format for data warehousing
sales_long = sales.unpivot(
    index=["id", "item_id", "dept_id", "cat_id", "store_id", "state_id"],
    on=day_cols,
    variable_name="d",
    value_name="sales",
).with_columns(
    [
        pl.col("item_id").cast(pl.Categorical),
        pl.col("dept_id").cast(pl.Categorical),
        pl.col("cat_id").cast(pl.Categorical),
        pl.col("store_id").cast(pl.Categorical),
        pl.col("state_id").cast(pl.Categorical),
        pl.col("sales").cast(pl.Int16),
    ]
)

# ==============================================================================
# 3. DATA INTEGRATION & MERGING (JOIN OPERATIONS)
# ==============================================================================
print("\n🔗 [3/4] Merging Datasets (Sales + Calendar + Prices)...")

# Join unpivoted sales with calendar table on day key ('d')
sales_merged = sales_long.join(calendar, on="d", how="inner")

# Enrich dataset with sell prices using composite key (store_id, item_id, wm_yr_wk)
master_table = sales_merged.join(
    prices, on=["store_id", "item_id", "wm_yr_wk"], how="left"
)

# ==============================================================================
# 4. EXPORT TO PARQUET (SILVER LAYER STORAGE)
# ==============================================================================
print(f"\n💾 [4/4] Saving Master Table to Parquet at: {OUTPUT_PARQUET}")

# Persist processed master dataset into compressed Parquet format using Snappy
master_table.write_parquet(OUTPUT_PARQUET, compression="snappy")

elapsed = round(time.time() - start_time, 2)
print(f"\n✅ Pipeline Finished Successfully in {elapsed} seconds!")
print(
    f"📊 Final Shape: {master_table.shape[0]:,} rows x {master_table.shape[1]} columns"
)

# ==============================================================================
# 5. EXPLORATORY DATA ANALYSIS (EDA) VIA PANDAS
# ==============================================================================
# Load source CSV files via Pandas for schema and shape validation

calender = pd.read_csv(
    r"C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source\calendar.csv"
)
evalue = pd.read_csv(
    r"C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source\sales_train_evaluation.csv"
)
valid = pd.read_csv(
    r"C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source\sales_train_validation.csv"
)
submission = pd.read_csv(
    r"C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source\sample_submission.csv"
)
prices = pd.read_csv(
    r"C:\Users\YOUNIS\Desktop\data_eng\M5-Retail-ETL-Data-Warehouse\source\sell_prices.csv"
)

# Display dataset dimensions (Rows, Columns)
print("Shape of calender.csv:", calender.shape)
print("Shape of sales_train_evaluation.csv:", evalue.shape)
print("Shape of sales_train_validation.csv:", valid.shape)
print("Shape of sample_submission.csv:", submission.shape)
print("Shape of sell_prices.csv:", prices.shape)

# Output column lists for metadata verification
print("Columns in calender.csv:", calender.columns.tolist())
print("Columns in sales_train_evaluation.csv:", evalue.columns.tolist())
print("Columns in sales_train_validation.csv:", valid.columns.tolist())
print("Columns in sample_submission.csv:", submission.columns.tolist())
print("Columns in sell_prices.csv:", prices.columns.tolist())