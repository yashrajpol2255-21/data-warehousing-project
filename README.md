# Data Warehouse Project – MySQL

## 📌 Project Overview

This project demonstrates the design and implementation of a modern data warehouse using **MySQL** and **SQL**.

It follows the **Medallion Architecture (Bronze, Silver, and Gold)** to organize data into different layers, process raw data, perform transformations, and create analytics-ready datasets.

The project focuses on understanding data warehousing concepts, ETL workflows, data transformation, and analytical data modeling.

## 🏗️ Data Architecture

The project uses three separate MySQL databases:

### 1. Bronze Layer
- Stores raw data loaded from source CSV files.
- Uses `LOAD DATA LOCAL INFILE` for bulk data ingestion.
- Preserves the original source data.

### 2. Silver Layer
- Performs data cleansing and transformation.
- Processes raw data from the Bronze layer.
- Uses SQL stored procedures to manage data loading and transformation.

### 3. Gold Layer
- Contains analytics-ready datasets.
- Uses SQL views to organize business-ready data.
- Supports reporting and analytical queries.

## 🔄 ETL Workflow

The project follows this workflow:

**Source CSV Files → Bronze → Silver → Gold → Analytics**

1. Extract data from source CSV files.
2. Load raw data into the Bronze database.
3. Clean and transform data in the Silver database.
4. Create analytical views in the Gold database.
5. Use Gold-layer views for reporting and analysis.

## 🛠️ Technologies Used

- **Database:** MySQL
- **Language:** SQL
- **Architecture:** Medallion Architecture
- **ETL:** SQL-based data ingestion and transformation
- **Version Control:** Git & GitHub

## 📁 Project Structure

```text
00_setup/       Setup guide and optional macOS Docker files
01_datasets/    CRM and ERP source CSV files
02_docs/        Architecture, requirements, data model, and project notes
03_scripts/     Database initialization and Bronze, Silver, and Gold SQL
04_tests/       Silver and Gold data quality checks
```

## 🚀 How to Run

Requirements: MySQL 8.0+ and the `mysql` command-line client. Run commands from the repository root.

1. Enable local file loading on the MySQL server:

   ```sql
   SET GLOBAL local_infile = 1;
   ```

2. Initialize the databases, create the Bronze tables, and load the source CSV files:

   ```bash
   mysql -u root -p < 03_scripts/init_database.sql
   mysql -u root -p < 03_scripts/bronze/ddl_bronze.sql
   mysql --local-infile=1 -u root -p < 03_scripts/bronze/load_bronze.sql
   ```

3. Create and load the Silver layer, then create the Gold views:

   ```bash
   mysql -u root -p < 03_scripts/silver/ddl_silver.sql
   mysql -u root -p < 03_scripts/silver/proc_load_silver.sql
   mysql -u root -p -e "CALL silver.load_silver();"
   mysql -u root -p < 03_scripts/gold/ddl_gold.sql
   ```

4. Run the data quality checks:

   ```bash
   mysql -u root -p < 04_tests/quality_checks_silver.sql
   mysql -u root -p < 04_tests/quality_checks_gold.sql
   ```

The Bronze load script uses paths relative to the repository root. In MySQL Workbench, enable `OPT_LOCAL_INFILE=1` in the connection settings and use absolute paths in the load script.

## 👨‍💻 Author

**Yashraj Sudhir Pol**

Walchand College of Engineering, Sangli

[GitHub](https://github.com/yashrajpol2255-21)