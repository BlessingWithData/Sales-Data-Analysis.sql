/*
--Sales Data Analysis
--Dataset: final_sales_dataset
--Objective: Analyze sales performance
*/

------01. OVERALL REALIZED REVENUE

--- Realized Revenue

SELECT SUM(quantity*unit_price) AS realized_revenue
FROM final_sales_dataset
WHERE quantity > 0
      AND delivery_status = 'Delivered';

--- Gross Revenue
SELECT SUM(quantity*unit_price) AS gross_revenue
FROM final_sales_dataset;

-- Negative quantities
SELECT SUM(quantity*unit_price) AS negative_quantities
FROM final_sales_dataset
WHERE quantity < 0;

------02. REVENUE BY REGION 
SELECT 
      region,
      SUM(quantity*unit_price) AS realized_revenue 
FROM final_sales_dataset
WHERE quantity > 0
     AND delivery_status = 'Delivered'
GROUP BY region 
ORDER BY realized_revenue DESC;

--Order Volume by Region
SELECT 
      region,
      COUNT(*) AS total_order
FROM final_sales_dataset
WHERE quantity > 0
     AND delivery_status = 'Delivered'
GROUP BY region 
ORDER BY total_order DESC; 

--Average Order Value by Region
SELECT 
      region,
      SUM(quantity*unit_price)/ COUNT(*) AS avg_order_value
FROM final_sales_dataset
WHERE quantity > 0
     AND delivery_status = 'Delivered'
GROUP BY region;



-----03. PRODUCT BY REVENUE
SELECT 
      product,
      SUM(quantity*unit_price) AS realized_revenue
FROM final_sales_dataset
WHERE quantity > 0
     AND delivery_status = 'Delivered'
GROUP BY product
ORDER BY realized_revenue DESC
LIMIT 3;

-----04. CATEGORY BY REVENUE
SELECT 
      category,
      SUM(quantity*unit_price) AS realized_revenue
FROM final_sales_dataset
WHERE quantity > 0
     AND delivery_status = 'Delivered'
GROUP BY category
ORDER BY realized_revenue DESC;


------05. MONTHLY SALES TREND
WITH monthly_revenue AS (
      SELECT 
           DATE_TRUNC('month',order_date) AS month,
           SUM(unit_price*quantity) AS realized_revenue
      FROM final_sales_dataset
      WHERE quantity > 0
          AND delivery_status = 'Delivered'
      GROUP BY DATE_TRUNC('month',order_date)
)
      SELECT month,
             realized_revenue,
             LAG(realized_revenue) OVER(ORDER BY month) AS previous_month,
             realized_revenue - LAG(realized_revenue) OVER(
                  ORDER BY month) AS monthly_change
      FROM monthly_revenue
      ORDER BY month;

      
