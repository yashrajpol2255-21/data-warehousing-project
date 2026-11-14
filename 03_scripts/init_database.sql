/*
=============================================================
Create Databases (Bronze, Silver, Gold layers)
=============================================================
Script Purpose:
    MySQL treats "schema" and "database" as the same thing, so each layer of the
    warehouse is its own database: 'bronze', 'silver' and 'gold'.
    If a layer already exists, it is dropped and recreated.

WARNING:
    Running this script drops the 'bronze', 'silver' and 'gold' databases if they
    exist. All data in them is permanently deleted. Make sure you have backups.

Usage (from the repository root):
    mysql -u root -p < 03_scripts/init_database.sql
*/

DROP DATABASE IF EXISTS bronze;
DROP DATABASE IF EXISTS silver;
DROP DATABASE IF EXISTS gold;

CREATE DATABASE bronze CHARACTER SET utf8mb4;
CREATE DATABASE silver CHARACTER SET utf8mb4;
CREATE DATABASE gold   CHARACTER SET utf8mb4;
