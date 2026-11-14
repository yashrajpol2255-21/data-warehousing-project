# End-to-End Data Warehouse in MySQL

A data warehouse built with MySQL 8 that consolidates sales data from two source systems (a CRM and an ERP, both delivered as CSV files) into a clean star schema ready for analysis.

> **Credit:** This project is based on the *SQL Data Warehouse* project by [Baraa Khatib Salkini (DataWithBaraa)](https://github.com/DataWithBaraa), released under the MIT License (see [LICENSE](LICENSE)). The original is written for **SQL Server (T-SQL)**. In this repository I **ported the SQL scripts to MySQL 8** and tested the whole pipeline end to end. The architecture, datasets and documentation come from the original project.

## What this project does

- Loads six raw CSV files (3 from the CRM, 3 from the ERP) into a **Bronze** layer, unchanged.
- Cleans and standardises the data in a **Silver** layer.
- Exposes business-ready **Gold** views in a star schema: two dimensions and one fact table.
- Includes SQL quality checks for the Silver and Gold layers.

## Architecture

MySQL treats a schema and a database as the same thing, so each layer is its own database.

| Layer | Database | What it holds |
|---|---|---|
| Bronze | `bronze` | Raw tables, loaded 1:1 from the CSV files |
| Silver | `silver` | Cleansed and standardised tables |
| Gold | `gold` | Views forming the star schema |

**Source files** (in `01_datasets/`)

| System | File | Content |
|---|---|---|
| CRM | `cust_info.csv` | Customer master data |
| CRM | `prd_info.csv` | Product information and cost history |
| CRM | `sales_details.csv` | Sales orders |
| ERP | `CUST_AZ12.csv` | Customer birthdate and gender |
| ERP | `LOC_A101.csv` | Customer country |
| ERP | `PX_CAT_G1V2.csv` | Product categories |

**Silver cleaning rules (examples)**

- Remove duplicate customers, keeping the most recent record.
- Trim whitespace; map codes such as `M`/`F`/`S` to readable values (`Male`, `Female`, `Single`).
- Derive product category and key from the combined product key; compute product end dates from the next start date.
- Convert integer dates such as `20101229` to real `DATE` values; set invalid dates to `NULL`.
- Recalculate sales or price when they are missing, zero or inconsistent (`sales = quantity * price`).
- Remove the `NAS` prefix and dashes from ERP customer IDs so both systems join; set future birthdates to `NULL`.

## Data model (Gold layer)

| View | Type | Notes |
|---|---|---|
| `gold.dim_customers` | Dimension | CRM + ERP customer data merged, with a surrogate key |
| `gold.dim_products` | Dimension | Current products only, enriched with category data, with a surrogate key |
| `gold.fact_sales` | Fact | One row per order line, linked to both dimensions by surrogate keys |

## Project structure

```text
data-warehousing-project/
├── 01_datasets/
│   ├── source_crm/          # cust_info.csv, prd_info.csv, sales_details.csv
│   └── source_erp/          # CUST_AZ12.csv, LOC_A101.csv, PX_CAT_G1V2.csv
├── 02_docs/                 # architecture, data flow, data model, catalog, naming conventions
├── 03_scripts/
│   ├── init_database.sql    # creates the bronze, silver and gold databases
│   ├── bronze/
│   │   ├── ddl_bronze.sql   # bronze tables
│   │   └── load_bronze.sql  # loads the CSV files (LOAD DATA LOCAL INFILE)
│   ├── silver/
│   │   ├── ddl_silver.sql   # silver tables
│   │   └── proc_load_silver.sql   # procedure silver.load_silver()
│   └── gold/
│       └── ddl_gold.sql     # dimension and fact views
├── 04_tests/
│   ├── quality_checks_silver.sql
│   └── quality_checks_gold.sql
├── LICENSE
└── README.md
```

## How to run

**Requirements:** MySQL Server 8.0+ and the `mysql` command-line client.

1. Clone the repository and go to its root folder (the load script uses paths relative to it):

   ```bash
   git clone https://github.com/yashrajpol2255-21/data-warehousing-project.git
   cd data-warehousing-project
   ```

2. Allow loading local files (one time, as a MySQL admin):

   ```sql
   SET GLOBAL local_infile = 1;
   ```

3. Run the scripts in this order:

   ```bash
   mysql -u root -p < 03_scripts/init_database.sql
   mysql -u root -p < 03_scripts/bronze/ddl_bronze.sql
   mysql --local-infile=1 -u root -p < 03_scripts/bronze/load_bronze.sql
   mysql -u root -p < 03_scripts/silver/ddl_silver.sql
   mysql -u root -p < 03_scripts/silver/proc_load_silver.sql
   mysql -u root -p -e "CALL silver.load_silver();"
   mysql -u root -p < 03_scripts/gold/ddl_gold.sql
   ```

4. Run the quality checks and explore the data:

   ```bash
   mysql -u root -p < 04_tests/quality_checks_silver.sql
   mysql -u root -p < 04_tests/quality_checks_gold.sql
   mysql -u root -p -e "SELECT * FROM gold.fact_sales LIMIT 10;"
   ```

   Most checks are expected to return no rows. The checks that list `DISTINCT` values are for you to review. The birthdate check lists a few customers born before 1924, which come from the source data.

**MySQL Workbench:** you can open and run the same scripts there. For `load_bronze.sql`, enable `OPT_LOCAL_INFILE=1` in the connection settings (Advanced tab) and replace the relative file paths with absolute ones.

**Expected row counts after a full run**

| Table or view | Rows |
|---|---|
| `bronze.crm_cust_info` | 18,494 |
| `silver.crm_cust_info` | 18,484 (duplicates removed) |
| `bronze` / `silver.crm_prd_info` | 397 |
| `bronze` / `silver.crm_sales_details` | 60,398 |
| `bronze` / `silver.erp_cust_az12` and `erp_loc_a101` | 18,484 each |
| `bronze` / `silver.erp_px_cat_g1v2` | 37 |
| `gold.dim_customers` | 18,484 |
| `gold.dim_products` | 295 (current products only) |
| `gold.fact_sales` | 60,398 |

## Porting notes: SQL Server to MySQL

| SQL Server (original) | MySQL (this repo) |
|---|---|
| Schemas inside one `DataWarehouse` database | Three databases: `bronze`, `silver`, `gold` |
| `BULK INSERT` inside a stored procedure | `LOAD DATA LOCAL INFILE` in a plain script (MySQL does not allow it in procedures) |
| `NVARCHAR`, `DATETIME2`, `GETDATE()` | `VARCHAR`, `DATETIME`, `NOW()` / `CURDATE()` / `CURRENT_TIMESTAMP` |
| `LEN()`, `ISNULL()` | `CHAR_LENGTH()`, `IFNULL()` |
| `date - 1` | `DATE_SUB(date, INTERVAL 1 DAY)` |
| `int / int` (integer division) | `DIV` |
| `CREATE OR ALTER PROCEDURE` with `TRY...CATCH` | `CREATE PROCEDURE` with an `EXIT HANDLER` |
| `IF OBJECT_ID(...) DROP ...` | `DROP ... IF EXISTS` and `CREATE OR REPLACE VIEW` |

## Author

**Yashraj Sudhir Pol**
B.Tech in Electrical Engineering, Walchand College of Engineering, Sangli

[GitHub](https://github.com/yashrajpol2255-21) · [LinkedIn](https://www.linkedin.com/in/yashraj-pol-2839a7257)
