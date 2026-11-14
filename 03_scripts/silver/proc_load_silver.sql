/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)  [MySQL]
===============================================================================
Script Purpose:
    Performs the ETL (Extract, Transform, Load) step that fills the 'silver' tables
    from the 'bronze' tables:
        - Truncates the Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver.

Parameters:
    None.

Usage Example:
    CALL silver.load_silver();

Note:
    The script uses DELIMITER so the procedure body can contain semicolons.
    Run it with the mysql client or MySQL Workbench (both understand DELIMITER).
===============================================================================
*/

DROP PROCEDURE IF EXISTS silver.load_silver;

DELIMITER //

CREATE PROCEDURE silver.load_silver()
BEGIN
    DECLARE v_batch_start DATETIME;

    -- If anything fails, report the error instead of failing silently
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @err_no = MYSQL_ERRNO, @err_msg = MESSAGE_TEXT;
        SELECT 'ERROR OCCURRED DURING LOADING SILVER LAYER' AS status,
               @err_no  AS error_number,
               @err_msg AS error_message;
    END;

    SET v_batch_start = NOW();

    -- ------------------------------------------------------------------
    -- CRM tables
    -- ------------------------------------------------------------------

    -- silver.crm_cust_info
    TRUNCATE TABLE silver.crm_cust_info;
    INSERT INTO silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname,
        cst_marital_status, cst_gndr, cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname)  AS cst_lastname,
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,  -- Normalize marital status values to readable format
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,            -- Normalize gender values to readable format
        cst_create_date
    FROM (
        SELECT
            c.*,
            ROW_NUMBER() OVER (PARTITION BY c.cst_id ORDER BY c.cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info c
        WHERE c.cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;            -- Keep only the most recent record per customer

    -- silver.crm_prd_info
    TRUNCATE TABLE silver.crm_prd_info;
    INSERT INTO silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        p.prd_id,
        REPLACE(SUBSTRING(p.prd_key, 1, 5), '-', '_')    AS cat_id,   -- Extract category ID
        SUBSTRING(p.prd_key, 7, CHAR_LENGTH(p.prd_key))  AS prd_key,  -- Extract product key
        p.prd_nm,
        IFNULL(p.prd_cost, 0)                            AS prd_cost,
        CASE
            WHEN UPPER(TRIM(p.prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(p.prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(p.prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(p.prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END                                              AS prd_line, -- Map product line codes to descriptive values
        CAST(p.prd_start_dt AS DATE)                     AS prd_start_dt,
        -- End date = one day before the next start date of the same product
        DATE_SUB(
            CAST(LEAD(p.prd_start_dt) OVER (PARTITION BY p.prd_key ORDER BY p.prd_start_dt) AS DATE),
            INTERVAL 1 DAY
        )                                                AS prd_end_dt
    FROM bronze.crm_prd_info p;

    -- silver.crm_sales_details
    TRUNCATE TABLE silver.crm_sales_details;
    INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt,
        sls_due_dt, sls_sales, sls_quantity, sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE
            WHEN sls_order_dt = 0 OR CHAR_LENGTH(sls_order_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
        END AS sls_order_dt,
        CASE
            WHEN sls_ship_dt = 0 OR CHAR_LENGTH(sls_ship_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
        END AS sls_ship_dt,
        CASE
            WHEN sls_due_dt = 0 OR CHAR_LENGTH(sls_due_dt) != 8 THEN NULL
            ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
        END AS sls_due_dt,
        CASE
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,           -- Recalculate sales if original value is missing or incorrect
        sls_quantity,
        CASE
            WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales DIV NULLIF(sls_quantity, 0)  -- DIV = integer division
            ELSE sls_price
        END AS sls_price            -- Derive price if original value is invalid
    FROM bronze.crm_sales_details;

    -- ------------------------------------------------------------------
    -- ERP tables
    -- ------------------------------------------------------------------

    -- silver.erp_cust_az12
    TRUNCATE TABLE silver.erp_cust_az12;
    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, CHAR_LENGTH(cid))  -- Remove 'NAS' prefix if present
            ELSE cid
        END AS cid,
        CASE
            WHEN bdate > CURDATE() THEN NULL
            ELSE bdate
        END AS bdate,               -- Set future birthdates to NULL
        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
            ELSE 'n/a'
        END AS gen                  -- Normalize gender values and handle unknown cases
    FROM bronze.erp_cust_az12;

    -- silver.erp_loc_a101
    TRUNCATE TABLE silver.erp_loc_a101;
    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry                -- Normalize and handle missing or blank country codes
    FROM bronze.erp_loc_a101;

    -- silver.erp_px_cat_g1v2
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT id, cat, subcat, maintenance
    FROM bronze.erp_px_cat_g1v2;

    -- ------------------------------------------------------------------
    -- Summary
    -- ------------------------------------------------------------------
    SELECT 'Loading Silver Layer is Completed' AS status,
           TIMESTAMPDIFF(SECOND, v_batch_start, NOW()) AS total_load_seconds;
END //

DELIMITER ;
