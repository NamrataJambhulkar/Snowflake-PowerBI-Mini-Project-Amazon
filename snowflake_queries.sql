CREATE OR REPLACE DATABASE AMAZON_PROJECT;
CREATE OR REPLACE SCHEMA AMAZON_PROJECT.SALES_DATA;

CREATE OR REPLACE TABLE AMAZON_PROJECT.SALES_DATA.AMAZON_SALES (
    Order_ID VARCHAR,
    Order_Date DATE,
    Product VARCHAR,
    Category VARCHAR,
    Price INTEGER,
    Quantity INTEGER,
    Total_Sales INTEGER,
    Customer_Name VARCHAR,
    Customer_Location VARCHAR,
    Payment_Method VARCHAR,
    Status VARCHAR
);

CREATE OR REPLACE STAGE AMAZON_PROJECT.SALES_DATA.amazon_stage;


SELECT * FROM AMAZON_PROJECT.SALES_DATA.AMAZON_SALES limit 10;


USE DATABASE AMAZON_PROJECT;
USE SCHEMA SALES_DATA;

-- 1. View a few rows
SELECT * FROM amazon_sales
LIMIT 10;

-- 2. Total sales by category
SELECT category, SUM(total_sales) AS Total_category_sales
FROM amazon_sales
GROUP BY category
ORDER BY Total_category_sales;

-- 3. Total revenue and quantity
SELECT SUM(total_sales) AS Total_revenue,
       SUM(quantity) AS total_unit_sold
FROM amazon_sales;

-- 4. Top 5 best-selling products
SELECT product, SUM(total_sales) AS product_revenue
FROM amazon_sales
GROUP BY product
ORDER BY product_revenue DESC 
LIMIT 5;

-- 5. Monthly sales (if your "Date" column is real date format)
SELECT TO_CHAR(Order_Date, 'YYYY-MM') AS order_month, SUM(total_sales) AS Monthly_Sales
FROM amazon_sales
GROUP BY order_month
ORDER BY order_month;

-- 6.  Payment Method Analysis
SELECT payment_method, COUNT(*) AS Orders, SUM(total_sales) AS total_collected
FROM amazon_sales
GROUP BY payment_method
ORDER BY total_collected DESC;

-- 7. Customer Location-wise Sales
SELECT Customer_Location, SUM(total_sales) AS revenue
FROM amazon_sales
GROUP BY Customer_Location
ORDER BY revenue DESC
LIMIT 10;

-- 8. CASE WHEN: Tag sales as ‘High’, ‘Medium’, ‘Low’
SELECT Order_ID, Product, Total_Sales,
  CASE
    WHEN Total_Sales >= 2000 THEN 'High'
    WHEN Total_Sales BETWEEN 500 AND 1999 THEN 'Medium'
    ELSE 'Low'
  END AS Sales_level
FROM amazon_sales
ORDER BY Total_Sales DESC;

-- 9. Window Function: Rank customers by total sales
SELECT Customer_Name, SUM(Total_Sales) AS Total_spent,
RANK() OVER(ORDER BY SUM(Total_Sales)DESC) AS Customer_rank
FROM amazon_sales
GROUP BY Customer_Name;

-- 10. ROW_NUMBER: Top-selling product per category
WITH ProductRank AS (
  SELECT Category, Product, SUM(Total_Sales) AS revenue,
  ROW_NUMBER() OVER(PARTITION BY Category ORDER BY SUM(Total_Sales)DESC) AS rn
  FROM amazon_sales
  GROUP BY Category, Product
)
SELECT * FROM ProductRank WHERE rn = 1;

-- 11. Subquery: Products sold above average price
SELECT * FROM amazon_sales
WHERE Price > (
    SELECT AVG(Price) FROM amazon_sales
);

-- 12. CTE + Aggregation: Monthly high performers (total sales > 1000)
WITH MonthlyPerform AS (
  SELECT TO_CHAR(Order_Date, 'YYYY-MM') AS order_month, Product, SUM(total_sales) AS revenue
  FROM amazon_sales
  GROUP BY order_month, Product
)
SELECT * FROM MonthlyPerform
WHERE revenue > 1000
ORDER BY order_month;
