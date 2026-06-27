## Sales Data Analysis Project

   
   ### Project Overview
This project analyzes cleaned sales data to uncover key business insights such as revenue performance, product trends and regional distribution. The goal is to support data-driven decision making through SQL-based analysis.


### Business Objectives
- Measure realized revenue from completed transactions
- Identify top-performing product, category and regions
- Analyze monthly sales trend 
- Understand differences in customer purchasing behaviour
- Extract actionable business insights


### Tools Used
- SQL (PostgreSQL)
- Vs Code
- Git & Github


### Dataset Description
- **Source:**
This dataset was generated with the assistance of Claude.

The dataset contains transactional sales records with the following fields:
- Order ID
- Order Date
- Product
- Category 
- Region 
- Quantity
- Unit Price
- Delivery Status

### Data Cleaning & Preparation
Before analysis, the dataset was assessed for quality issues that could distort business insights. The following cleaning steps were performed:

1. ### Creating a Working Copy of the Dataset

To preserve the integrity of the raw data, a duplicate working table was created. This ensures that all transformations are reversible and the original dataset remains unchanged for reference or reprocessing.

```sql
CREATE TABLE sales_cleaning_backup AS 
SELECT *
FROM sales;
```

2. ### Duplicate Detection and Removal

The dataset was checked for duplicate records using ctid.

Only one duplicate record was identified
The duplicate was removed to prevent inflation of revenue, quantity, and order counts
This ensures each transaction is represented only once in the analysis
```sql
DELETE FROM sales_cleaning_backup
WHERE ctid IN (
    SELECT ctid
    FROM duplicates
    WHERE rn > 1
);
```


3. ### Handling Missing Values

Missing values were assessed based on column importance and usability:

**Order Date:**
Found 1 null value in the order_date column. 
Missing value was removed because time-based analysis requires valid dates, and imputation was not possible.
```sql
DELETE FROM sales_cleaning_backup
WHERE order_date IS NULL;
```

**Category:**
Found 1 null value in the category column. Missing values were replaced with “Unknown” since category could not be reliably inferred from existing data. This preserves the record while maintaining grouping consistency.
```sql
UPDATE sales_cleaning_backup
SET category = 'Unknown'
WHERE category IS NULL;
```
**Quantity:**
Records with null quantity were removed because quantity is essential for revenue calculation and cannot be inferred.
```sql
DELETE FROM sales_cleaning_backup
WHERE quantity IS NULL;
```

4. ### Trimming and Standardizing Text Data

Text-based columns were cleaned to improve consistency in grouping and analysis:

Leading and trailing whitespace were removed
Standard formatting was applied to ensure uniformity across product, category, and region fields.
```sql
 UPDATE sales_cleaning_backup
 SET product =INITCAP(TRIM(product));
 ```
5. ### Data Type Correction

Column data types were standardized to ensure analytical correctness:

Quantity column is formatted to INT type.
This enables accurate aggregation and mathematical operations
```sql
ALTER TABLE sales_cleaning_backup
ALTER COLUMN quantity TYPE INT;
```
6. ### Data Validation and Flagging

Numeric fields were validated to ensure logical correctness.

Negative values were identified in the quantity column.
Since negative values included different transaction statuses (delivered, cancelled, pending), they were not deleted or converted
Instead, they were flagged for further analysis, preserving business context while maintaining data integrity

This approach ensures that operational realities are not lost through over-cleaning.
```sql
  UPDATE sales_cleaning_backup
  SET quantity =
     CASE 
          WHEN quantity < 0 THEN 'Negative quantity'
          ELSE 'Valid'
END;
```


7. ### Outlier Detection

Outliers were analyzed in key numerical fields:

- unit_price

- quantity

No significant outliers were detected that required removal or transformation, indicating stable distribution of values within expected operational ranges. 

**📊 Key Metrics Definition**

|Metric	|Definition|
|-------------|-----------:|
|Realized Revenue|	Revenue from delivered orders with quantity > 0
|Gross Transactions	|All transactions before filtering


**📊 Key Findings Summary**

|KPI	|Result|
|---------|----------:|
|Total Realized Revenue	|1,435,000
|Top Revenue Region	|Port Harcourt
|Highest Order Volume	|Lagos
|Highest Average Order Value	|Port Harcourt
|Top Products	|Mouse, Printer, Headset
|Top Category	|Office


### Exploratory Data Analysis

**Revenue**

To avoid misleading interpretation,revenue was analyzed using three distinct perspectives:

1. **Realized Revenue**

Objective: To determine the total revenue generated from completed transaction only.

```sql
SELECT SUM(quantity*unit_price) AS realized_revenue
FROM final_sales_dataset
WHERE quantity > 0
      AND delivery_status = 'Delivered';
```
**Insight**

The total realized revenue from completed transaction is 1,435,000. This represents actual business earnings and excludes cancelled,pending and invalid transactions, ensuring a performance-focused view of sales.

2. **Gross Revenue**

Objective: To meaure the total value of all recorded transaction in the dataset,regardless of delivery status
```sql
SELECT SUM(quantity*unit_price) AS gross_revenue
FROM final_sales_dataset;
```
**Insight**

The Gross Transaction Value represent the total activity within the sales system,including completed, pending and cancelled orders.This metric is useful for understanding demand flow and system activity before filtering for business outcomes.

3. **Negative Quantities

Objective: To analyze the financial impact of negative quantity transactions,which may represent returns, cancellations, or operational adjustments within the sales process.
```sql
SELECT SUM(quantity*unit_price) AS negative_quantity
FROM final_sales_dataset
WHERE quantity < 0
```

**Insight**

These values reduce overall operational leakage within the sales process.

2. **REVENUE BY REGION**

Objective: To identify which region generate the most realized revenue
```sql
SELECT 
      region,
      SUM(quantity*unit_price) AS realized_revenue 
FROM final_sales_dataset
WHERE quantity > 0
      AND delivery_status = 'Delivered'
GROUP BY region 
ORDER BY realized_revenue DESC;
```
**Insight**

Port Harcourt emerged as the top-performing region in terms of realized revenue and average order value, while Lagos recorded the highest order volume. This indicates that Port Harcourt's revenue leadership is driven by customers spending more per transaction, whereas Lagos generates revenue through a larger number of orders.


💼 **Business Implication**

The business should investigate the factors contributing to higher spending in Port Harcourt, such as product mix, customer demographics, pricing strategies, or purchasing behavior. Insights from this region could help increase average order value in other markets.


3. **REVENUE BY PRODUCT**

Objective: Identify the products that generate the highest realized revenue and which product contribute most to overall business performance.

**Insight**

Mouse, Printer and Headset were the top three revenue-generating products, indicating strong customer demand and significant contribution to overall sales performance.

**Business Implication**

Maintaining adequate inventory and focusing promotional efforts on these products can help sustain revenue growth. Understanding the factors behind their success may also provide opportunities to improve the performance of other product.


4. **REVENUE BY CATEGORY**

Objective: Identify which product categories contribute the most to realized revenue.

**Insight**

|Category|Revenue|
|----------|--------:|
|Office| 620,000|
|Electronics| 475,000|
|Accessories| 340,000|

The office category generated the highest realized revenue,indicating strong customer demand and making it the most significant contributor to overall sales performance.

**Business Implication**
: The business should ensure consistent availablility of office products and continue investing in strategies that support category growth.




5. 📈 **Monthly Sales Trend**

🎯 Objective

To analyze monthly realized revenue performance in order to understand fluctuations in sales activity and identify periods of growth and decline.

🧠 Insight

Monthly revenue shows significant volatility across the period, with no consistent growth pattern.

The highest revenue occurs in January (250,000), indicating a strong start to the year.
A sharp decline is observed in March (35,000) and again in October (15,000), representing the weakest performance months.
Strong recovery periods are visible in April (200,000) and November (230,000), where revenue increases significantly from the previous months.

The MoM changes confirm that performance is highly unstable, with both sharp declines (e.g., -165,000 in March) and strong rebounds (e.g., +215,000 in November). This indicates that sales are driven by irregular demand patterns rather than steady progression.

💼 Business Implication

This volatility suggests that revenue is influenced by external or operational factors such as seasonality, promotions, or stock availability.

Strong months (April, November, January) can be studied to identify what drives demand spikes
Weak months (March, October, June) may require targeted interventions such as promotions or improved sales strategies
Planning should assume high variability, not stable monthly growth


🧠 **Key Insights**

- Revenue concentration is high.

- A small number of products and one category (Office) drive most revenue.

- Regional behavior differs significantly.Port Harcourt drives high-value purchases
Lagos drives high transaction volume.

- Revenue is not stable over time.
Monthly performance is highly volatile with sharp peaks and dips.

- Negative quantities reduce realized revenue and indicate process inefficiencies.

**💼 Business Recommendations**
1. **Improve regional strategy:**
Leverage Port Harcourt’s high AOV by analyzing its pricing, customer profile, or product mix.
Apply successful strategies from Port Harcourt to other regions.
Increase monetization in Lagos through upselling and bundling
2. **Optimize product performance:**
Prioritize inventory and marketing for top products (Mouse, Printer, Headset)
Investigate why these products outperform others
Identify opportunities to boost lower-performing products
3. **Strengthen category strategy:**
Focus on expanding the Office category, which is the main revenue driver
Cross-sell related products within high-performing categories
4. **Address revenue volatility:**
Investigate causes of monthly fluctuations.
Introduce promotional strategies during low-performing months.
Improve demand forecasting for better planning
5. **Reduce operational inefficiencies:**
Monitor returns and cancellations closely
Investigate root causes of negative quantity transactions
Improve order validation and fulfillment processes

**🚀 Final Business Conclusion**

- The business is driven by a concentrated set of products, a dominant category, and uneven regional performance. While Port Harcourt leads in revenue efficiency and Lagos leads in transaction volume, overall performance is highly volatile across time.

- Sustainable growth will depend on:
Expanding high-performing product lines
Improving regional monetization balance
Reducing operational losses.
