/*
===============================================================================
Load Bronze Layer (Source CSV -> Bronze)  [MySQL]
===============================================================================
Script Purpose:
    Truncates the bronze tables and loads them from the CSV files in 01_datasets
    using LOAD DATA LOCAL INFILE.

    MySQL does not allow LOAD DATA inside a stored procedure, so this is a plain
    script rather than a procedure (unlike the Silver layer).

How to run (from the REPOSITORY ROOT, so the relative paths below resolve):
    mysql --local-infile=1 -u root -p < 03_scripts/bronze/load_bronze.sql

Requirements:
    - The server must allow local files:  SET GLOBAL local_infile = 1;
    - The client must allow it too (--local-infile=1). In MySQL Workbench, add
      OPT_LOCAL_INFILE=1 under the connection's Advanced > Others, and replace the
      relative paths below with absolute ones.

Notes:
    - Empty CSV fields are loaded as NULL (same as SQL Server's BULK INSERT).
    - File names are case-sensitive on Linux/macOS, so they match the real files.
===============================================================================
*/

TRUNCATE TABLE bronze.crm_cust_info;
LOAD DATA LOCAL INFILE '01_datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@cst_id, @cst_key, @cst_firstname, @cst_lastname, @cst_marital_status, @cst_gndr, @cst_create_date)
SET cst_id = NULLIF(@cst_id, ''),
    cst_key = NULLIF(@cst_key, ''),
    cst_firstname = NULLIF(@cst_firstname, ''),
    cst_lastname = NULLIF(@cst_lastname, ''),
    cst_marital_status = NULLIF(@cst_marital_status, ''),
    cst_gndr = NULLIF(@cst_gndr, ''),
    cst_create_date = NULLIF(TRIM(TRAILING '\r' FROM @cst_create_date), '');

TRUNCATE TABLE bronze.crm_prd_info;
LOAD DATA LOCAL INFILE '01_datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@prd_id, @prd_key, @prd_nm, @prd_cost, @prd_line, @prd_start_dt, @prd_end_dt)
SET prd_id = NULLIF(@prd_id, ''),
    prd_key = NULLIF(@prd_key, ''),
    prd_nm = NULLIF(@prd_nm, ''),
    prd_cost = NULLIF(@prd_cost, ''),
    prd_line = NULLIF(@prd_line, ''),
    prd_start_dt = NULLIF(@prd_start_dt, ''),
    prd_end_dt = NULLIF(TRIM(TRAILING '\r' FROM @prd_end_dt), '');

TRUNCATE TABLE bronze.crm_sales_details;
LOAD DATA LOCAL INFILE '01_datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@sls_ord_num, @sls_prd_key, @sls_cust_id, @sls_order_dt, @sls_ship_dt, @sls_due_dt, @sls_sales, @sls_quantity, @sls_price)
SET sls_ord_num = NULLIF(@sls_ord_num, ''),
    sls_prd_key = NULLIF(@sls_prd_key, ''),
    sls_cust_id = NULLIF(@sls_cust_id, ''),
    sls_order_dt = NULLIF(@sls_order_dt, ''),
    sls_ship_dt = NULLIF(@sls_ship_dt, ''),
    sls_due_dt = NULLIF(@sls_due_dt, ''),
    sls_sales = NULLIF(@sls_sales, ''),
    sls_quantity = NULLIF(@sls_quantity, ''),
    sls_price = NULLIF(TRIM(TRAILING '\r' FROM @sls_price), '');

TRUNCATE TABLE bronze.erp_loc_a101;
LOAD DATA LOCAL INFILE '01_datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@cid, @cntry)
SET cid = NULLIF(@cid, ''),
    cntry = NULLIF(TRIM(TRAILING '\r' FROM @cntry), '');

TRUNCATE TABLE bronze.erp_cust_az12;
LOAD DATA LOCAL INFILE '01_datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@cid, @bdate, @gen)
SET cid = NULLIF(@cid, ''),
    bdate = NULLIF(@bdate, ''),
    gen = NULLIF(TRIM(TRAILING '\r' FROM @gen), '');

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE '01_datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@id, @cat, @subcat, @maintenance)
SET id = NULLIF(@id, ''),
    cat = NULLIF(@cat, ''),
    subcat = NULLIF(@subcat, ''),
    maintenance = NULLIF(TRIM(TRAILING '\r' FROM @maintenance), '');

-- Row counts after loading
SELECT 'bronze.crm_cust_info'     AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL SELECT 'bronze.crm_prd_info',     COUNT(*) FROM bronze.crm_prd_info
UNION ALL SELECT 'bronze.crm_sales_details',COUNT(*) FROM bronze.crm_sales_details
UNION ALL SELECT 'bronze.erp_loc_a101',     COUNT(*) FROM bronze.erp_loc_a101
UNION ALL SELECT 'bronze.erp_cust_az12',    COUNT(*) FROM bronze.erp_cust_az12
UNION ALL SELECT 'bronze.erp_px_cat_g1v2',  COUNT(*) FROM bronze.erp_px_cat_g1v2;
