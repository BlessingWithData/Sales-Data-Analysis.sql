--------------------------------------------------------------------
============================================
-- 01: DATA EXPLORATION
-- Purpose : Understand dataset structure and identify potential
--- data quality issue before cleaning
---------------------------------------------------------------------
==============================================

-- 1. Preview sample data
SELECT *
FROM sales_cleaning_backup
LIMIT 20;

-- 2. Check total number of records
SELECT COUNT(*) AS total_rows
FROM sales_cleaning_backup;

--3. View table structure and data types
SELECT column_name,data_type
FROM information_schema.columns
WHERE table_name = 'sales_cleaning_backup';

--4. Check missing values in key columns
SELECT 
      COUNT(*) AS total_rows,
      COUNT(quantity) AS quantity_not_null,
      COUNT(unit_price) AS unit_price_not_null
FROM sales_cleaning_backup;


--5. Identify records with missing values 
SELECT *
FROM sales_cleaning_backup
WHERE quantity IS NULL
       OR unit_price IS NULL
       OR delivery_status IS NULL;

--6. Check for duplicates(using order_id as unique identifier)
SELECT order_id,COUNT(*) AS count
FROM sales_cleaning_backup
GROUP BY order_id
HAVING COUNT(*) > 1;

--7. Numeric summary(to detect anomalies early)
SELECT 
      MIN(quantity) AS min_quantity,
      MAX(quantity) AS max_quantity,
      AVG(quantity) AS avg_quantity,
      MIN(unit_price) AS min_unit_price,
      MAX(unit_price) AS max_unit_price,
      AVG(unit_price) AS avg_unit_price
FROM sales_cleaning_backup;