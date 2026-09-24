Markdown# 🛒 M5 Retail Data Warehouse & Automated ETL Pipeline

An end-to-end Enterprise Data Warehouse (EDW) and High-Performance ETL Pipeline built using **Polars**, **Python**, and **SQL Server**. The pipeline ingests, transforms, and indexes **59.18 million rows** of granular retail data (M5 Competition Dataset) under the **Medallion Architecture (Bronze → Silver → Gold)** following **Kimball's Dimensional Modeling** methodologies.

---

## 📐 Architecture Overview

The system processes large-scale transactional data through three progressive processing stages designed to separate concerns, enforce data quality, and maximize query performance:

[ Raw CSV Files ]│▼ (Bronze Layer)┌─────────────────────────────────────────────────────────┐│ Polars Python Engine (In-Memory Processing & Memory Opt) │└─────────────────────────────────────────────────────────┘│  • Wide-to-Long Unpivoting (d_1 to d_1941)│  • Type Casting & Categorical Encoding▼ (Silver Layer)[ Compressed Snappy Parquet Master Storage ]│▼ (Gold Layer - Data Warehouse Loading)┌─────────────────────────────────────────────────────────┐│ Microsoft SQL Server (M5_Retail_DW)                     ││  • Star Schema Deployment (Kimball Methodology)         ││  • BCP / Bulk Insert Strategy                           ││  • Nonclustered B-Tree Indexes with Covered INCLUDEs    │└─────────────────────────────────────────────────────────┘│▼[ Analytics Views / BI Consumption Ready ]
1. **Bronze Layer:** Raw ingestion of source data (Sales, Calendar, Sell Prices).
2. **Silver Layer:** Fast in-memory transformation, unpivoting wide daily metrics into long temporal series, and persisting into compressed Snappy Parquet.
3. **Gold Layer:** Fully structured Star Schema Data Warehouse in SQL Server optimized for analytical processing (OLAP) and BI tools.

---

## 🛠️ Tech Stack & Key Tools

* **Data Processing & ETL:** Python 3.x, Polars (Chosen over Pandas for zero-copy memory safety and multi-threaded execution speeds).
* **Storage Formats:** Apache Parquet (Snappy Compression).
* **Data Warehouse Engine:** Microsoft SQL Server.
* **Data Modeling:** Kimball Star Schema (Dimensions & Fact Architecture).
* **Version Control:** Git & GitHub.

---

## 📊 Dimensional Data Model (Star Schema)

The Gold layer implements a normalized Star Schema designed specifically for retail demand analysis:

                ┌─────────────────────────┐
                │     gold.dim_date       │
                ├─────────────────────────┤
                │ PK  date_key (INT)      │
                │     date                │
                │     year, month, etc.   │
                └────────────┬────────────┘
                             │ 1
                             │
                             │ N
┌─────────────────────────┐    ┌─┴───────────────────────┐    ┌─────────────────────────┐│     gold.dim_store      │    │     gold.fact_sales     │    │      gold.dim_item      │├─────────────────────────┤    ├─────────────────────────┤    ├─────────────────────────┤│ PK  store_key (INT)     ├────┤ FK  date_key (INT)      ├────┤ PK  item_key (INT)      ││     store_id            │ 1  │ FK  store_key (INT)     │  1 │     item_id             ││     state_id            │    │ FK  item_key (INT)      │    │     dept_id, cat_id     │└─────────────────────────┘   N│     sales (INT)         │N   └─────────────────────────┘│     sell_price (DEC)    ││     revenue (DEC)       │└─────────────────────────┘
* **`gold.dim_date`**: Contains temporal attributes, week identifiers (`wm_yr_wk`), day numbers, and SNAP event indicators.
* **`gold.dim_store`**: Contains store identifiers and state locations (CA, TX, WI).
* **`gold.dim_item`**: Contains product details, category levels (`cat_id`), and department hierarchies (`dept_id`).
* **`gold.fact_sales`**: Fact table storing daily transactional granular metrics (Units Sold, Unit Selling Price, Calculated Revenue).

---

## ⚡ Performance Optimization & Benchmarks

Handling **59,181,090 rows** at scale required strict optimization techniques across Python and SQL Server engines:

### 1. Polars Wide-to-Long Transformation
* **Problem:** Converting 1,941 individual day columns (`d_1` to `d_1941`) in Pandas caused memory overflow (OOM) errors and high latency.
* **Solution:** Replaced Pandas with **Polars C++ core engine**. Applied `.unpivot()` alongside explicit integer downcasting (`Int8`, `Int16`, `Float32`) and categorical encoding on text keys.
* **Result:** Processed and merged all 59.18 million rows into Parquet in less than **2 minutes**.

### 2. High-Throughput Bulk Loading
* Disabled non-essential FK constraints during initial bulk insertion.
* Utilized table-level lock allocations (`TABLOCK`) alongside batching to minimize transaction log fragmentation.

### 3. B-Tree Nonclustered Index Tuning
To accelerate aggregation performance across multi-million row joins, targeted composite B-Tree indexes were created with covered columns:

```sql
-- Composite Date-Item Index for Product Performance Queries
CREATE NONCLUSTERED INDEX IX_fact_sales_date_item
ON gold.fact_sales (date_key, item_key)
INCLUDE (sales, revenue);

-- Store Performance Index
CREATE NONCLUSTERED INDEX IX_fact_sales_store
ON gold.fact_sales (store_key)
INCLUDE (sales, revenue);
🎯 Data Integrity & ReconciliationData validation scripts were executed post-load to verify 100% data fidelity between source CSV files and the Gold Fact table:MetricValidated Target ValueTotal Fact Table Rows59,181,090Total Units Sold66,927,173Total Gross Revenue$191,577,546.04Data Loss Ratio0.00%📈 Analytics Layer (SQL Views)The DW features pre-aggregated analytical views designed for instant BI connectivity:gold.vw_daily_sales_performance: Tracks daily/weekly unit sales and revenue trends over time.gold.vw_store_category_performance: Evaluates product category performance broken down by regional stores and states.gold.vw_item_performance: Highlights top-performing and low-moving SKUs across all retail outlets.📁 Repository Structure.
├── source/                      # Raw dataset files (Ignored in Git)
├── scripts/
│   ├── 01_polars_etl.py         # Polars Wide-to-Long transformation & Parquet generation
│   ├── 02_gold_schema_ddl.sql   # Star Schema DDL definitions
│   ├── 03_dw_data_loading.sql   # Bulk loading & data population scripts
│   ├── 04_indexes_tuning.sql    # Nonclustered index definitions
│   └── 05_analytics_views.sql   # Gold layer business performance views
├── architecture_diagram.png     # Pipeline architecture overview
└── README.md                    # Project documentation
🚀 How to Run the ProjectClone the Repository:Bashgit clone [https://github.com/Youssef-eng27/M5-Retail-ETL-Data-Warehouse.git](https://github.com/Youssef-eng27/M5-Retail-ETL-Data-Warehouse.git)
cd M5-Retail-ETL-Data-Warehouse
Install Required Python Libraries:Bashpip install polars pandas pyarrow
Execute ETL Pipeline:Bashpython scripts/01_polars_etl.py
Deploy Data Warehouse Schema & Views:Execute SQL scripts 02 through 05 in Microsoft SQL Server Management Studio (SSMS) in sequential order.