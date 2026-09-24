import os
import polars as pl

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "../../"))
PARQUET_PATH = os.path.join(PROJECT_ROOT, "source", "m5_silver_master.parquet")
CSV_PATH = os.path.join(PROJECT_ROOT, "source", "m5_silver_master.csv")

print("⚡ Reading Parquet with Polars...")
df = pl.read_parquet(PARQUET_PATH)

print("⚡ Formatting columns and writing CSV...")
# Cast date to string explicitly to prevent formatting issues
df = df.with_columns(pl.col("date").cast(pl.Utf8))

# Export clean CSV without header for BCP compatibility
df.write_csv(CSV_PATH, include_header=False)

print(f"✅ Fast CSV created at: {CSV_PATH}")