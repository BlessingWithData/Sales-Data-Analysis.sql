CREATE TABLE final_sales_dataset AS
SELECT *
FROM sales_cleaning_backup;

---To verify
SELECT *
FROM final_sales_dataset
ORDER BY order_id;