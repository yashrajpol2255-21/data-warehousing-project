# End-to-End Data Warehousing Project

## 📌 Project Overview

This project demonstrates the design and implementation of an end-to-end SQL Data Warehouse using MySQL. It focuses on consolidating raw customer, product, and sales data into a structured analytical environment to support efficient data analysis and business intelligence.

The project follows a structured ETL (Extract, Transform, Load) workflow, applies data quality and cleansing techniques, and organizes transformed data using a dimensional data model.

## 🎯 Project Objectives

- Build a centralized data warehouse for customer, product, and sales data.
- Implement ETL processes to extract, transform, and load data.
- Perform data cleansing and standardization to improve data quality.
- Apply dimensional data modeling using Fact and Dimension tables.
- Implement a Star Schema for efficient analytical querying.
- Develop SQL queries to generate meaningful business insights.

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| MySQL | Database management and SQL transformations |
| SQL | Data extraction, transformation and analysis |
| ETL | Data integration and processing |
| Star Schema | Dimensional data modeling |
| Git & GitHub | Version control and project management |

## 🏗️ Data Warehouse Architecture

The project follows a layered data processing approach:

### 1. Bronze Layer – Raw Data

- Stores raw data extracted from source CSV files.
- Maintains the original structure of source datasets.
- Acts as the initial landing layer for incoming data.

### 2. Silver Layer – Cleansed Data

- Performs data cleaning and standardization.
- Handles NULL values and inconsistent records.
- Applies data type conversions and validation.
- Ensures data consistency and quality.

### 3. Gold Layer – Business-Ready Data

- Organizes processed data into Fact and Dimension tables.
- Implements dimensional modeling using a Star Schema.
- Provides structured data for reporting and analytical queries.

## 🔄 ETL Process

The ETL workflow consists of three major stages:

**Extract**
- Import customer, product, and sales datasets from CSV files.
- Load the source data into the Bronze Layer.

**Transform**
- Clean and standardize raw datasets.
- Handle missing and inconsistent values.
- Apply SQL transformations and business rules.
- Prepare data for dimensional modeling.

**Load**
- Load the transformed data into the Silver and Gold Layers.
- Populate Fact and Dimension tables.
- Organize the warehouse for analytical querying.

## 🗄️ Data Modeling

The Gold Layer uses a Star Schema consisting of:

**Dimension Tables**
- Customer Dimension
- Product Dimension
- Date Dimension (if implemented)

**Fact Table**
- Sales Fact Table

The Fact table stores transactional sales information and references the relevant Dimension tables through keys.

## 📊 SQL Concepts Implemented

- Database and table creation
- Primary Keys and Foreign Keys
- Data types and constraints
- INSERT, UPDATE and DELETE operations
- INNER JOIN, LEFT JOIN and multiple-table joins
- Aggregate functions
- GROUP BY and HAVING
- Common Table Expressions (CTEs)
- Window Functions
- ROW_NUMBER(), RANK() and DENSE_RANK()
- CASE statements
- NULL handling
- Date formatting and conversion
- Data cleaning and transformation

## 📁 Project Structure

```text
data-warehousing-project/
│
├── datasets/
│   ├── cust_info.csv
│   ├── prd_info.csv
│   └── sales_details.csv
│
├── scripts/
│   ├── init_database.sql
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── docs/
│   ├── data_model.png
│   └── architecture.png
│
├── README.md
└── .gitignore
```

*Note: Adjust the directory structure to match your actual repository.*

## 🚀 How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Clone this repository:

```bash
git clone https://github.com/yashrajpol2255-21/data-warehousing-project.git
```

3. Navigate to the project directory:

```bash
cd data-warehousing-project
```

4. Open the SQL scripts in MySQL Workbench.
5. Execute the database initialization script.
6. Import the source CSV datasets into the appropriate Bronze Layer tables.
7. Execute the Silver Layer transformation scripts.
8. Execute the Gold Layer scripts to create and populate Fact and Dimension tables.
9. Run analytical SQL queries to explore the warehouse data.

## 📚 Key Learnings

Through this project, I gained practical experience in:

- Understanding Data Warehouse architecture and ETL workflows.
- Working with structured datasets using MySQL.
- Applying data cleaning and transformation techniques.
- Designing Fact and Dimension tables.
- Understanding Star Schema and dimensional modeling.
- Writing advanced SQL queries for data analysis.
- Organizing data for analytical and reporting purposes.

## 👨‍💻 Author

**Yashraj Sudhir Pol**

B.Tech – Electrical Engineering  
Walchand College of Engineering, Sangli

GitHub: [yashrajpol2255-21](https://github.com/yashrajpol2255-21
