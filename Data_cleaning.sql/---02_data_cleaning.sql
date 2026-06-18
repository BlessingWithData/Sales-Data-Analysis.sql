-----------------------------------------------------
====================================
-- 02. DATA CLEANING
-- Purpose: Clean,standardize and flag issues in
-- the dataset without losing original data
-----------------------------------------------------
====================================

----- 1.Creating a copy of the original data

CREATE TABLE sales_cleaning_backup AS 
SELECT *
FROM sales;

-----Verify the data

SELECT COUNT(*)
FROM sales_cleaning_backup;

------ Inspecting the data
SELECT *
FROM sales_cleaning_backup
LIMIT 20;


----- 2. Checking for duplicates using ctid
 SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id,
                         product,
                         category
            ORDER BY ctid
) AS rn
FROM sales_cleaning_backup;


------ Deleting duplicate rows
WITH duplicates AS (
    SELECT ctid,
           ROW_NUMBER() OVER(
            PARTITION BY order_id
            ORDER BY ctid
          ) AS rn 
        FROM  sales_cleaning_backup 
)
DELETE FROM sales_cleaning_backup
WHERE ctid IN (
    SELECT ctid
    FROM duplicates
    WHERE rn > 1
);


------- 3.HANDLING MISSING VALUES


SELECT COUNT(*)
FROM sales_cleaning_backup
WHERE order_date IS NULL;

---Since we have just one row with a missing order_date,
-- it is reasonable to delete it from the dataset
DELETE FROM sales_cleaning_backup
WHERE order_date IS NULL;

SELECT COUNT (*)
FROM sales_cleaning_backup
WHERE category IS NULL;

SELECT *
FROM sales_cleaning_backup
WHERE category IS NULL

-- replacing the null in product column is the best option since the correct category could
--not be determined from existing data ,the missing value was replaced with "Unknown"
UPDATE sales_cleaning_backup
SET category = 'Unknown'
WHERE category IS NULL;


SELECT COUNT(*)
FROM sales_cleaning_backup
WHERE quantity IS NULL;

----We have just one null value in the quantity column,
---so removing it is the best since it is unusable
DELETE FROM sales_cleaning_backup
WHERE quantity IS NULL;

 ---------- 4.TRIM WHITESPACES FROM TEXT COLUMNS

 UPDATE sales_cleaning_backup
 SET product =INITCAP(TRIM(product));

UPDATE sales_cleaning_backup
SET delivery_status = INITCAP(TRIM(delivery_status));

UPDATE sales_cleaning_backup
SET region = INITCAP(TRIM(region));


UPDATE sales_cleaning_backup
SET category = INITCAP(TRIM(category));

----------- 5.CORRECTING DATA TYPE
SELECT 
        column_name,
        data_type
FROM information_schema.columns
WHERE table_name = 'sales_cleaning_backup';

ALTER TABLE sales_cleaning_backup
ALTER COLUMN quantity TYPE INT;

----------- 6.DATA VALIDATION
-- DATE VALIDATION
SELECT *
FROM sales_cleaning_backup
WHERE order_date > CURRENT_DATE;

--NUMERIC VALIDATION 
SELECT count(*)
FROM sales_cleaning_backup
WHERE quantity < 0;

SELECT 
     quantity,
     delivery_status
FROM sales_cleaning_backup
WHERE quantity < 0;

-----Investigating this we can not  change it to positive
--value beacuse it is not an error so we just flag it 

 ALTER TABLE sales_cleaning_backup
 ADD COLUMN quantity_flag VARCHAR(50);
 
     CASE 
          WHEN quantity < 0 THEN 'Negative quantity'
          ELSE 'Valid'
END;

--To verify
SELECT 
    quantity,
    delivery_status,
    quantity_flag
FROM sales_cleaning_backup;


--------- 7.CHECKING OUTLIERS(USING IQR METHOD)
---Checking outliers for unit_price 
WITH quartiles AS (
    SELECT
         PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY 
         unit_price) AS q1,
         PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY
         unit_price) AS q3
  FROM sales_cleaning_backup
)
    SELECT
      q1 < (q1 - 1.5 * (q3-q1)),
      q3 > (q3 + 1.5 * (q3-q1))
    FROM quartiles;

---- checking outlier for quantity column
    WITH quartiles AS (
    SELECT
         PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY 
         quantity) AS q1,
         PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY
         quantity) AS q3
  FROM sales_cleaning_backup
)
    SELECT
      q1 < (q1 - 1.5 * (q3-q1)),
      q3 > (q3 + 1.5 * (q3-q1))
    FROM quartiles;


----------CHECK DATA CONSISTENCY
--Check quantity and delivery status
SELECT *
FROM sales_cleaning_backup
WHERE delivery_status = 'Delivered'
     AND quantity < 0; 


--Check unit prices
SELECT *
FROM sales_cleaning_backup
WHERE unit_price <= 0;

--Check delivery status values
SELECT DISTINCT delivery_status
FROM sales_cleaning_backup;

--Check date consistency
SELECT *
FROM sales_cleaning_backup
WHERE order_date > CURRENT_DATE;

--Check duplicate order ids
SELECT 
      order_id,
      COUNT(*)
FROM sales_cleaning_backup
GROUP BY order_id
HAVING COUNT(*) > 1;

--Check for missing values 
SELECT *
FROM sales_cleaning_backup
WHERE order_id IS NULL 
      OR product IS NULL;

--Check category consistency
SELECT 
      product,
      COUNT(DISTINCT category) AS category_count
FROM sales_cleaning_backup
GROUP BY product 
HAVING COUNT(DISTINCT category) > 1;