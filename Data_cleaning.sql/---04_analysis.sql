/*
--Sales Data Analysis
--Dataset: final_sales_dataset
--Objective: Analyze sales performance
*/

------01. TOTAL REVENUE 
SELECT 
      SUM(quantity*unit_price) AS total_revenue 
FROM final_sales_dataset
WHERE quantity >0;

------02. REVENUE BY REGION 
SELECT 
      region,
      SUM(quantity*unit_price) AS total_revenue 
FROM final_sales_dataset
WHERE quantity > 0
GROUP BY region 
ORDER BY total_revenue DESC;

-----03. PRODUCT BY REVENUE
SELECT 
      product,
      SUM(quantity*unit_price) AS revenue 
FROM final_sales_dataset
GROUP BY product
ORDER BY revenue DESC;

-----04. CATEGORY BY REVENUE
SELECT 
      category, 
      SUM(quantity*unit_price) AS revenue 
FROM final_sales_dataset
GROUP BY category
ORDER BY revenue DESC;

------05. MOST SOLD PRODUCT
SELECT 
      product,
      SUM(quantity) AS total_quantity_sold
FROM final_sales_dataset
GROUP BY product
ORDER BY total_quantity_sold DESC;

------06. MONTHLY SALES TREND
WITH monthly_sales AS (
      SELECT 
           DATE_TRUNC('month',order_date) AS month,
           SUM(unit_price*quantity) AS total_revenue
      FROM final_sales_dataset
      WHERE quantity > 0
      GROUP BY month
)
      SELECT month,
             total_revenue,
             DENSE_RANK()OVER(ORDER BY total_revenue DESC
             ) AS revenue_rank
      FROM monthly_sales;

      
