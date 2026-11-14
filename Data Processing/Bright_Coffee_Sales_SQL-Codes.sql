/*
--------------------------------------------------------------------------------------------------------------
             BRIGHT COFFEE SHOP
           DATA ANALYTICS CASE STUDY

AUTHOR: Mologadi Shiri

PROJECT OBJECTIVE:
Analyse coffee shop transactions to identify sales performance, product trends, store perfomance and purchasing patterns.

DATASET:
149,116 transaction records.

TOOLS:
- Databricks SQL
- Microsoft Excel
- Miro
- GitHub
- Power BI (Planned)

PROJECT SCOPE:
1. Data Inspection and Exploration
2. Data Quality Validation
3. SQL Data Analysis
4. Sales and Revenue Analysis
5. Data Preparation and Export
6. Excel Analysis and Visualisation

----------------------------------------------------------------------------------------------------------
*/


/*
-- -------------------------------------------------------------------------------------------------------
-- SECTION 1: DATA INSPECTION 
-- OBJECTIVE:
-- Inspect the dataset to understand its structure,
-- identify data types and determine the size of the dataset.
-- Check records for consistency and identify formatting issues that may affect SQL execution, data processing and calculations.
-- ------------------------------------------------------------------------------------------------------------------------------
*/

/*
-- OBJECTIVE:
-- Use SELECT * to inspect the dataset, view all available columns and examine the information contained in the table.
*/

SELECT *
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

/*
-- CLASSROOM EXAMPLE: DATA TYPE CONVERSION
-- Demonstrated in class for datasets where Unit_price
-- is imported as STRING instead of DOUBLE.
-- Conversion was not required for this dataset.

-- SELECT 
  --   transaction_id,
    -- unit_price,
   --  CAST(REPLACE(unit_price, ',','.') AS DOUBLE) AS Unit_price
-- FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;
*/

-- Check how many records are there in the dataset = 149116
SELECT
     COUNT(*) AS total_records
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

-- Number of Units sold
SELECT
     SUM(transaction_qty) AS Total_units_sold
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

-- Check if transaction IDs are unique. 
SELECT COUNT(DISTINCT transaction_id) AS unique_transactions
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

-- check for null values across all columns
SELECT *
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
WHERE transaction_id IS NULL
OR transaction_date IS NULL
OR transaction_time IS NULL
OR transaction_qty IS NULL
OR store_id IS NULL
OR store_location IS NULL
OR product_id IS NULL
OR unit_price IS NULL
OR product_category IS NULL
OR product_type IS NULL
OR product_detail IS NULL;              -- No Null values.


-- Investigating zero quantities
SELECT COUNT(*) AS zero_quantity_records
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
WHERE transaction_qty = 0; 

-- Checking for zero or negative quantities and prices.
SELECT COUNT(*) AS Invalid_records
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
WHERE transaction_qty <= 0
OR unit_price <=0;

-- Investigate if there is any products that was recorded with a selling price of zero
SELECT COUNT(*) AS zero_price_records
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
WHERE unit_price = 0; 

SELECT COUNT(*) AS negative_price_records
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
WHERE unit_price < 0; 


-- Checking for blanks
SELECT COUNT(*) AS blank_product
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
WHERE TRIM(product_category) = ''
OR TRIM(product_type) = ''
OR TRIM(product_detail) = '';


-- Capturing the date and time when the query is executed.
SELECT 
     transaction_date,
     transaction_time,
CURRENT_TIMESTAMP() AS Processing_Time
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
GROUP BY ALL
ORDER BY Processing_Time;


-- DATE RANGE VALIDATION - when sales manager wants to understand daily, monthly and seasonal trends
-- This also tells us the period covered
SELECT
     MIN(transaction_date) AS First_Transaction_Date,
     MAX(transaction_date) AS Last_Transaction_Date
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

-- Checking shop operationg hours
SELECT 
      MIN(transaction_time) AS earliest_transaction_time,
      MAX(transaction_time) AS latest_transaction_time
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

-- Inspecting transaction quantities - understanding the quantity range before using it in our sales calculations
SELECT
      MIN(transaction_qty) AS min_quantity,
      MAX(transaction_qty) AS max_quantity,
      AVG(transaction_qty) AS avg_quantity
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

-- Checking product details - this will help us identify which specific products generate the most revenue
SELECT COUNT(DISTINCT product_detail) AS Unique_Product_Details
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

SELECT DISTINCT product_type
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
ORDER BY product_type;

SELECT 
     COUNT(DISTINCT product_detail) AS Unique_Product_Details
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;


-- Checking different locations represented in the Dataset = 3
SELECT COUNT(DISTINCT store_id) AS number_of_stores
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

SELECT DISTINCT store_location
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
ORDER BY store_location;
------------------------------------------------------------------------------------------------------------


/*
-- SECTION 2.SALES CALCULATIONS AND ANALYSIS 
-- OBJECTIVE: To calculate and analyse sales performance using transaction quantities and unit prices. 
-- This section focuses on determining total revenue, identifying top-performing products, 
-- comparing revenue across store locations, and analysing sales patterns by time of day and date
*/

/*
-- 2.1 TOTAL SALES AND REVENUE
-- Calculate revenue for each transaction by multiplying quantity sold by unit price
*/
SELECT 
      transaction_qty * unit_price AS Total_amount
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

/*
-- Calculate total qualities sold and overall revenue for the entire dataset.
-- ROUND() is used to to display revenue to two decimal places
*/
SELECT
      SUM(transaction_qty),
     ROUND(SUM(transaction_qty * unit_price), 2) AS Total_revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;


/*
-- 2.2 REVENUE BY PRODUCT CATEGORY
-- Calculate total revenue generated by each individual product.
-- This helps identify the products contributing most to overall revenue.
*/
SELECT
     product_category,
     ROUND(SUM(transaction_qty * unit_price), 2) AS Total_revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
GROUP BY ALL
ORDER BY Total_revenue DESC;

-- 2.3 REVENUE BY PRODUCT DETAIL
SELECT
     product_detail,
     ROUND(SUM(transaction_qty * unit_price), 2) AS Total_revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
GROUP BY ALL
ORDER BY Total_revenue DESC;

/*
-- Filtering revenue alanysis to investigate a specific product category.
-- The WHERE condition can be activated when analysing an individual category.
*/
 -- 2.4 REVENUE BY PRODUCT CATEGORY
 SELECT
     product_category,
     ROUND(SUM(transaction_qty * unit_price), 2) AS Total_revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
-- WHERE product_category = 'Coffee'
GROUP BY ALL
ORDER BY product_category;    


-- 2.5 REVENUE BY PRODUCT TYPE.
SELECT
     product_type,
     ROUND(SUM(transaction_qty * unit_price), 2) AS Total_revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
GROUP BY ALL
ORDER BY Total_revenue DESC;


/*
-- Analyse sales quantities and total revenue at each unit price.
-- This helps identify which price points generate the most revenue.
*/
-- 2.6 REVENUE BY UNIT PRICE
SELECT
      unit_price,
      SUM(transaction_qty) AS total_units_sold,
      ROUND(SUM(unit_price * transaction_qty), 2) AS Total_Revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
GROUP BY unit_price
ORDER by Total_revenue;


/*
-- Calculate total revenue generated by each store location.
-- This helps compare reveue performane across the different stores.
*/
-- 2.7 TOTAL REVENUE BY STORE LOCATION
SELECT 
     store_location,
     ROUND(SUM(transaction_qty * unit_price), 2) AS Total_revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
GROUP BY ALL
ORDER BY Total_revenue DESC;

/*
-- 2.8 TOTAL REVENUE BASED ON TIME OF THE DAY
-- To see coffee shop trading hrs
-- This can be useful to check when sales pick up, which hr generate most revenue, 
-- when customer activity slows down, whether opening and closing hrs are aligned with sales demand.
*/

SELECT
     MIN(transaction_time) AS Earliest_Transaction_Time,
     MAX(transaction_time) AS Latest_Transaction_Time
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw;

/*
-- 6am - 11:59:59 = Morning
-- 12pm - 17:59:59 = Afternoon
-- 18pm - 20:59:59 = Evening
-- After 21:00 = Night
*/

SELECT 
    CASE 
       WHEN transaction_time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
       WHEN transaction_time BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
	   WHEN transaction_time BETWEEN '18:00:00' AND '20:59:59' THEN 'Evening'
	   WHEN transaction_time >= '21:00:00' THEN 'Night'
       ELSE 'Other'
    END AS time_bucket,
    ROUND(SUM(transaction_qty * unit_price), 2) AS Total_revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
GROUP BY ALL;


-- Date extraction (Month name, month_id, day name)
SELECT
     transaction_date,
     YEAR(transaction_date) As Sales_year,
     MONTHNAME(transaction_date) AS month_name,
     MONTH(transaction_date) AS month_number,
     DATE_FORMAT(transaction_date, 'yyyy-MMM') AS month_id,
     DAYNAME(transaction_date) AS day_name,
     DAYOFWEEK(transaction_date) AS day_number
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw; 


/*
-- PREPARING TRANSACTION-LEVEL DATASET FOR CSV EXPORT
-- Combines transaction,product,store, date and time attributes.
-- Calculates transaction counts, units sold and revenue.
-- Prepares the dataset for further analysis in Excel.
*/

SELECT 
    transaction_id,
    transaction_date,
     YEAR(transaction_date) AS sales_year,
     MONTHNAME(transaction_date) AS month_name,
     MONTH(transaction_date) AS month_number,
     DATE_FORMAT(transaction_date, 'yyyy-MMM') AS month_id,
     DAYNAME(transaction_date) AS day_name,
     DAYOFWEEK(transaction_date) AS day_number,
    product_category,
    product_type,
    product_detail,
    store_location,
      CASE 
       WHEN transaction_time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
       WHEN transaction_time BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
	   WHEN transaction_time BETWEEN '18:00:00' AND '20:59:59' THEN 'Evening'
	   WHEN transaction_time >= '21:00:00' THEN 'Night'
       ELSE 'Other'
    END AS time_bucket,
    COUNT(transaction_id) AS Total_transactions,
    SUM(transaction_qty) AS Total_units_sold,
    ROUND(SUM(transaction_qty * unit_price), 2) AS Total_revenue
FROM bright_coffee_shop.sales_analysis.coffee_sales_raw
GROUP BY ALL;

-- ---------------------------------------------------------------------------------------------------------------------------