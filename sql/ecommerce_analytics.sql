-- ================================================================
-- E-COMMERCE SALES ANALYSIS PROJECT
-- PROJECT BY: CHIDI ONOCHIE RONALD
-- ================================================================
--
-- This script follows the required student project workflow:
--
-- PHASE 1: Understand the Business
-- PHASE 2: Data Understanding
-- PHASE 3: Import into MySQL
-- PHASE 4: Data Cleaning in MySQL
-- PHASE 5: Exploratory Data Analysis (EDA)
-- PHASE 6: Business Analysis
-- PHASE 7: Connect MySQL to Power BI
--
-- BUSINESS QUESTIONS:
-- The analysis section contains the 25 original business questions
-- supplied for this project, in their original order.
--
-- CLEANING WORKFLOW USED IN THIS PROJECT:
-- The original ecommerce_sales table was imported first as the raw/staging
-- table. A separate ecommerce_sales_clean table was then created from
-- it. Cleaning and validation were performed on ecommerce_sales_clean.
-- After cleaning was completed and verified, the original ecommerce_sales
-- table was dropped and ecommerce_sales_clean was renamed to
-- ecommerce_sales. Transformations and EDA were then performed on the
-- final ecommerce_sales table.

-- SOURCE FILE:
-- samplesuperstore.csv
--
-- EXPECTED MYSQL IMPORT LOCATION:
-- C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\samplesuperstore.csv
--
-- MYSQL VERSION:
-- MySQL 8.0+
-- ================================================================


-- ================================================================
-- PHASE 1: UNDERSTAND THE BUSINESS
-- ================================================================
--
-- Company / business context:
-- The dataset is a Superstore-style e-commerce sales dataset.
-- The analysis focuses on sales, customers, products, regions,
-- discounts, profit and shipping performance.
--
-- Business problem:
-- Understand what drives sales and profitability, identify
-- loss-making products/locations, evaluate discounting and shipping,
-- and support better commercial decisions.
--
-- Key stakeholders:
-- Management / executives
-- Sales team
-- Marketing team
-- Finance team
-- Operations / logistics team
--
-- Decisions supported:
-- Product and category strategy
-- Customer and segment strategy
-- Pricing and discount decisions
-- Regional strategy
-- Shipping strategy
-- Profitability improvement
--
-- Main KPIs:
-- Total Sales
-- Total Profit
-- Profit Margin
-- Total Orders
-- Total Quantity Sold
-- Total Customers
-- Average Order Value
-- Average Discount
-- Average Shipping Days
-- ================================================================

-- ================================================================
-- PHASE 2: DATA UNDERSTANDING
-- ================================================================
--
-- Original dataset structure:
-- The CSV contains 21 fields including Row_ID.
-- Row_ID is used temporarily during cleaning as a row identifier.
-- It is removed from the final analysis table after duplicate
-- records have been cleaned.
--
-- Final analysis table contains 20 business columns:
-- Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID,
-- Customer_Name, Segment, Country_Region, City, State_Province,
-- Postal_Code, Region, Product_ID, Category, Sub_Category,
-- Product_Name, Sales, Quantity, Discount, Profit.
--
-- Primary key:
-- Row_ID is used temporarily as a technical row identifier during
-- cleaning. Order_ID is NOT a primary key because one order can
-- contain multiple product rows.
--
-- Foreign keys:
-- No separate dimension tables/foreign keys are required for this
-- single-table project.
-- ================================================================


-- ================================================================
-- PHASE 3: IMPORT INTO MYSQL
-- ================================================================

CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE ecommerce_sales (
    Row_ID INT,
    Order_ID VARCHAR(20),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(20),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country_Region VARCHAR(100),
    City VARCHAR(100),
    State_Province VARCHAR(100),
    Postal_Code VARCHAR(20),
    Region VARCHAR(50),
    Product_ID VARCHAR(30),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(255),
    Sales DECIMAL(18,10),  -- high precision so values are not rounded per row on import
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(18,10)  -- high precision so values are not rounded per row on import
);

-- Import CSV.
-- Dates are stored in the CSV as M/D/YYYY, so STR_TO_DATE()
-- converts them directly into MySQL DATE values.

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/samplesuperstore.csv'
INTO TABLE ecommerce_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    Row_ID,
    Order_ID,
    @Order_Date,
    @Ship_Date,
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    Country_Region,
    City,
    State_Province,
    Postal_Code,
    Region,
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Sales,
    Quantity,
    Discount,
    Profit
)
SET
    Order_Date = STR_TO_DATE(@Order_Date, '%c/%e/%Y'),
    Ship_Date = STR_TO_DATE(@Ship_Date, '%c/%e/%Y');

-- Verify imported data

SELECT COUNT(*) AS Total_Imported_Rows
FROM ecommerce_sales;

SELECT *
FROM ecommerce_sales
LIMIT 10;

-- ================================================================
-- PHASE 4: DATA CLEANING IN MYSQL
-- ================================================================

-- Create a separate cleaned copy from the imported table.
-- The original imported ecommerce_sales table is kept as the source table
-- while cleaning and validation are performed on ecommerce_sales_clean.

CREATE TABLE ecommerce_sales_clean AS
SELECT *
FROM ecommerce_sales;

-- Row_ID is retained temporarily in the cleaned copy so it can be used
-- to identify which duplicate record to keep.


-- ------------------------------------------------
-- 4.1 Check duplicate records
-- ------------------------------------------------

-- Identify exact duplicate business records

SELECT
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    Country_Region,
    City,
    State_Province,
    Postal_Code,
    Region,
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Sales,
    Quantity,
    Discount,
    Profit,
    COUNT(*) AS Duplicate_Count
FROM ecommerce_sales_clean
GROUP BY
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    Country_Region,
    City,
    State_Province,
    Postal_Code,
    Region,
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Sales,
    Quantity,
    Discount,
    Profit
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;


SELECT
    Row_ID,
    Order_ID,
    Customer_Name,
    Product_ID,
    Sales,
    Profit
FROM ecommerce_sales_clean
WHERE Order_ID IN (
    'US-2023-150119',
    'CA-2023-153623'
)
ORDER BY Order_ID, Row_ID;


DELETE FROM ecommerce_sales_clean
WHERE Row_ID IN (392, 1700);


SELECT COUNT(*) AS Total_Rows
FROM ecommerce_sales_clean;



-- Verify duplicate cleanup

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CONCAT_WS('|',
        Order_ID, Order_Date, Ship_Date, Ship_Mode,
        Customer_ID, Customer_Name, Segment, Country_Region,
        City, State_Province, Postal_Code, Region, Product_ID,
        Category, Sub_Category, Product_Name, Sales, Quantity,
        Discount, Profit
    )) AS Unique_Business_Rows
FROM ecommerce_sales_clean;


-- ------------------------------------------------
-- 4.2 Check missing values
-- ------------------------------------------------

SELECT
    SUM(Order_ID IS NULL) AS Missing_Order_ID,
    SUM(Order_Date IS NULL) AS Missing_Order_Date,
    SUM(Ship_Date IS NULL) AS Missing_Ship_Date,
    SUM(Ship_Mode IS NULL) AS Missing_Ship_Mode,
    SUM(Customer_ID IS NULL) AS Missing_Customer_ID,
    SUM(Customer_Name IS NULL) AS Missing_Customer_Name,
    SUM(Segment IS NULL) AS Missing_Segment,
    SUM(Country_Region IS NULL) AS Missing_Country,
    SUM(City IS NULL) AS Missing_City,
    SUM(State_Province IS NULL) AS Missing_State,
    SUM(Postal_Code IS NULL) AS Missing_Postal_Code,
    SUM(Region IS NULL) AS Missing_Region,
    SUM(Product_ID IS NULL) AS Missing_Product_ID,
    SUM(Category IS NULL) AS Missing_Category,
    SUM(Sub_Category IS NULL) AS Missing_Sub_Category,
    SUM(Product_Name IS NULL) AS Missing_Product_Name,
    SUM(Sales IS NULL) AS Missing_Sales,
    SUM(Quantity IS NULL) AS Missing_Quantity,
    SUM(Discount IS NULL) AS Missing_Discount,
    SUM(Profit IS NULL) AS Missing_Profit
FROM ecommerce_sales_clean;


-- Show rows with missing Sales

SELECT *
FROM ecommerce_sales_clean
WHERE Sales IS NULL;


-- Show rows with missing Profit

SELECT *
FROM ecommerce_sales_clean
WHERE Profit IS NULL;


-- ------------------------------------------------
-- 4.3 Remove extra spaces DIRECTLY on the table
-- ------------------------------------------------

UPDATE ecommerce_sales_clean
SET
    Order_ID = TRIM(Order_ID),
    Ship_Mode = TRIM(Ship_Mode),
    Customer_ID = TRIM(Customer_ID),
    Customer_Name = TRIM(Customer_Name),
    Segment = TRIM(Segment),
    Country_Region = TRIM(Country_Region),
    City = TRIM(City),
    State_Province = TRIM(State_Province),
    Postal_Code = TRIM(Postal_Code),
    Region = TRIM(Region),
    Product_ID = TRIM(Product_ID),
    Category = TRIM(Category),
    Sub_Category = TRIM(Sub_Category),
    Product_Name = TRIM(Product_Name);


-- Verify leading/trailing spaces

SELECT
    SUM(Customer_Name <> TRIM(Customer_Name)) AS Customer_Name_Spaces,
    SUM(Segment <> TRIM(Segment)) AS Segment_Spaces,
    SUM(City <> TRIM(City)) AS City_Spaces,
    SUM(State_Province <> TRIM(State_Province)) AS State_Spaces,
    SUM(Region <> TRIM(Region)) AS Region_Spaces,
    SUM(Category <> TRIM(Category)) AS Category_Spaces,
    SUM(Sub_Category <> TRIM(Sub_Category)) AS Sub_Category_Spaces,
    SUM(Product_Name <> TRIM(Product_Name)) AS Product_Name_Spaces
FROM ecommerce_sales_clean;


-- ------------------------------------------------
-- 4.4 Standardize category values
-- ------------------------------------------------
-- Check existing values first.

SELECT DISTINCT Category
FROM ecommerce_sales_clean
ORDER BY Category;

SELECT DISTINCT Sub_Category
FROM ecommerce_sales_clean
ORDER BY Sub_Category;

SELECT DISTINCT Segment
FROM ecommerce_sales_clean
ORDER BY Segment;

SELECT DISTINCT Ship_Mode
FROM ecommerce_sales_clean
ORDER BY Ship_Mode;

SELECT DISTINCT Region
FROM ecommerce_sales_clean
ORDER BY Region;


-- Example direct standardization.
-- These updates are safe if those lowercase/space variants exist.
-- In the cleaned dataset, the values were already standardized.

UPDATE ecommerce_sales_clean
SET Category = 'Office Supplies'
WHERE LOWER(TRIM(Category)) = 'office supplies';

UPDATE ecommerce_sales_clean
SET Category = 'Furniture'
WHERE LOWER(TRIM(Category)) = 'furniture';

UPDATE ecommerce_sales_clean
SET Category = 'Technology'
WHERE LOWER(TRIM(Category)) = 'technology';


-- ------------------------------------------------
-- 4.5 Check invalid numeric records
-- ------------------------------------------------

SELECT *
FROM ecommerce_sales_clean
WHERE Sales <= 0;


SELECT *
FROM ecommerce_sales_clean
WHERE Quantity <= 0;


SELECT *
FROM ecommerce_sales_clean
WHERE Discount < 0
   OR Discount > 1;


-- Remove invalid records if they exist.
-- In this project these conditions return zero records.

DELETE FROM ecommerce_sales_clean
WHERE Sales <= 0
   OR Quantity <= 0
   OR Discount < 0
   OR Discount > 1;


-- ------------------------------------------------
-- 4.6 Check invalid dates
-- ------------------------------------------------

SELECT *
FROM ecommerce_sales_clean
WHERE Ship_Date < Order_Date;


-- Remove invalid shipping-date records if they exist.
-- In this project this condition returns zero records.

DELETE FROM ecommerce_sales_clean
WHERE Ship_Date < Order_Date;


-- ------------------------------------------------
-- 4.7 Remove Row_ID from the cleaned table
-- ------------------------------------------------
-- Row_ID was part of the original CSV and was retained temporarily in
-- ecommerce_sales_clean so duplicate records could be identified.
-- It is now removed because it is not needed for the final analysis.


ALTER TABLE ecommerce_sales_clean
DROP COLUMN Row_ID;


-- Verify the cleaned table structure

DESCRIBE ecommerce_sales_clean;

-- ------------------------------------------------
-- 4.8 Replace the original table with the cleaned table
-- ------------------------------------------------
-- The cleaned table now becomes the final ecommerce_sales table used
-- for EDA, business questions and Power BI.

DROP TABLE ecommerce_sales;

RENAME TABLE ecommerce_sales_clean TO ecommerce_sales;


-- Verify the final ecommerce_sales structure

DESCRIBE ecommerce_sales;


-- ================================================================
-- PHASE 4B: DATA TRANSFORMATION IN MYSQL
-- ================================================================

-- Add useful transformed fields directly to the analysis table.

ALTER TABLE ecommerce_sales
ADD COLUMN Shipping_Days INT,
ADD COLUMN Profit_Margin DECIMAL(10,2);


-- Calculate shipping days

UPDATE ecommerce_sales
SET Shipping_Days = DATEDIFF(Ship_Date, Order_Date);


-- Calculate profit margin

UPDATE ecommerce_sales
SET Profit_Margin =
    CASE
        WHEN Sales = 0 THEN 0
        ELSE ROUND((Profit / Sales) * 100, 2)
    END;


-- Verify transformations

SELECT
    Order_ID,
    Order_Date,
    Ship_Date,
    Shipping_Days,
    Sales,
    Profit,
    Profit_Margin
FROM ecommerce_sales
LIMIT 20;


-- ================================================================
-- PHASE 5: EXPLORATORY DATA ANALYSIS (EDA)
-- ================================================================

-- ------------------------------------------------
-- 5.1 Basic dataset profile
-- ------------------------------------------------

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Product_ID) AS Total_Products
FROM ecommerce_sales;


-- ------------------------------------------------
-- 5.2 Date range
-- ------------------------------------------------

SELECT
    MIN(Order_Date) AS Earliest_Order_Date,
    MAX(Order_Date) AS Latest_Order_Date,
    MIN(Ship_Date) AS Earliest_Ship_Date,
    MAX(Ship_Date) AS Latest_Ship_Date
FROM ecommerce_sales;


-- ------------------------------------------------
-- 5.3 Numeric ranges
-- ------------------------------------------------

SELECT
    MIN(Sales) AS Min_Sales,
    MAX(Sales) AS Max_Sales,
    MIN(Quantity) AS Min_Quantity,
    MAX(Quantity) AS Max_Quantity,
    MIN(Discount) AS Min_Discount,
    MAX(Discount) AS Max_Discount,
    MIN(Profit) AS Min_Profit,
    MAX(Profit) AS Max_Profit,
    MIN(Shipping_Days) AS Min_Shipping_Days,
    MAX(Shipping_Days) AS Max_Shipping_Days
FROM ecommerce_sales;


-- ------------------------------------------------
-- 5.4 Average shipping time
-- ------------------------------------------------

SELECT
    ROUND(AVG(Shipping_Days), 4) AS Average_Shipping_Days
FROM ecommerce_sales;


-- ------------------------------------------------
-- 5.5 Distribution of shipping modes
-- ------------------------------------------------

SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM ecommerce_sales
GROUP BY Ship_Mode
ORDER BY Total_Orders DESC;


-- ------------------------------------------------
-- 5.6 Distribution of segments
-- ------------------------------------------------

SELECT
    Segment,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Segment
ORDER BY Total_Sales DESC;


-- ------------------------------------------------
-- 5.7 Distribution of regions
-- ------------------------------------------------

SELECT
    Region,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(AVG(Profit_Margin), 2) AS Average_Profit_Margin
FROM ecommerce_sales
GROUP BY Region
ORDER BY Total_Sales DESC;


-- ------------------------------------------------
-- 5.8 Distribution of categories
-- ------------------------------------------------

SELECT
    Category,
    COUNT(DISTINCT Product_ID) AS Total_Products,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Category
ORDER BY Total_Sales DESC;


-- ================================================================
-- PHASE 5C: BUSINESS QUESTIONS 1-25
-- ================================================================


-- ================================================================
-- BUSINESS QUESTION 1
-- "What are overall sales, profit, quantity sold and orders?"
-- ================================================================

SELECT
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Quantity_Sold,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM ecommerce_sales;


-- ================================================================
-- BUSINESS QUESTION 2
-- "How have sales and profit changed over time?"
-- ================================================================

SELECT
    YEAR(Order_Date) AS Order_Year,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY YEAR(Order_Date)
ORDER BY Order_Year;


-- ================================================================
-- BUSINESS QUESTION 3
-- "Which years, quarters and months had highest/lowest sales?"
-- ================================================================

-- Years

SELECT
    YEAR(Order_Date) AS Order_Year,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM ecommerce_sales
GROUP BY YEAR(Order_Date)
ORDER BY Total_Sales DESC;


-- Quarters

SELECT
    YEAR(Order_Date) AS Order_Year,
    QUARTER(Order_Date) AS Order_Quarter,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM ecommerce_sales
GROUP BY YEAR(Order_Date), QUARTER(Order_Date)
ORDER BY Total_Sales DESC;


-- Months

SELECT
    YEAR(Order_Date) AS Order_Year,
    MONTH(Order_Date) AS Month_Number,
    MONTHNAME(Order_Date) AS Month_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM ecommerce_sales
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_Date)
ORDER BY Total_Sales DESC;


-- ================================================================
-- BUSINESS QUESTION 4
-- "Which regions generate the highest sales and profit?"
-- ================================================================

SELECT
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY Region
ORDER BY Total_Sales DESC;


-- ================================================================
-- BUSINESS QUESTION 5
-- "Which categories generate the highest sales?"
-- ================================================================

SELECT
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM ecommerce_sales
GROUP BY Category
ORDER BY Total_Sales DESC;


-- ================================================================
-- BUSINESS QUESTION 6
-- "Which categories generate the highest profit?"
-- ================================================================

SELECT
    Category,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Category
ORDER BY Total_Profit DESC;


-- ================================================================
-- BUSINESS QUESTION 7
-- "Which sub-categories have highest/lowest profit?"
-- ================================================================

SELECT
    Sub_Category,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Sub_Category
ORDER BY Total_Profit DESC;


-- ================================================================
-- BUSINESS QUESTION 8
-- "What are the top 10 products by sales and profit?"
-- ================================================================

SELECT
    Product_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 10;


-- ================================================================
-- BUSINESS QUESTION 9
-- "Which products have high sales but low/negative profit?"
-- ================================================================

SELECT
    Product_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Product_Name
HAVING SUM(Sales) > 10000
   AND SUM(Profit) <= 0
ORDER BY Total_Sales DESC;


-- ================================================================
-- BUSINESS QUESTION 10
-- "Which customer segments generate highest sales?"
-- ================================================================

SELECT
    Segment,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM ecommerce_sales
GROUP BY Segment
ORDER BY Total_Sales DESC;


-- ================================================================
-- BUSINESS QUESTION 11
-- "Which customer segments generate highest profit?"
-- ================================================================

SELECT
    Segment,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Segment
ORDER BY Total_Profit DESC;


-- ================================================================
-- BUSINESS QUESTION 12
-- "Which customers generate highest sales and profit?"
-- ================================================================

SELECT
    Customer_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;


-- ================================================================
-- BUSINESS QUESTION 13
-- "What is average order value by segment?"
-- ================================================================

SELECT
    Segment,
    ROUND(SUM(Sales) / COUNT(DISTINCT Order_ID), 2) AS Average_Order_Value
FROM ecommerce_sales
GROUP BY Segment
ORDER BY Average_Order_Value DESC;


-- ================================================================
-- BUSINESS QUESTION 14
-- "Are highest-spending customers also most profitable?"
-- ================================================================

SELECT
    Customer_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;


-- ================================================================
-- BUSINESS QUESTION 15
-- "What is the overall profit margin?"
-- ================================================================

SELECT
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM ecommerce_sales;


-- ================================================================
-- BUSINESS QUESTION 16
-- "How does discount level affect profitability?"
-- ================================================================

SELECT
    CASE
        WHEN Discount = 0 THEN '0%'
        WHEN Discount <= 0.10 THEN '1%-10%'
        WHEN Discount <= 0.20 THEN '11%-20%'
        WHEN Discount <= 0.30 THEN '21%-30%'
        WHEN Discount <= 0.40 THEN '31%-40%'
        WHEN Discount <= 0.50 THEN '41%-50%'
        ELSE 'Above 50%'
    END AS Discount_Level,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY
    CASE
        WHEN Discount = 0 THEN '0%'
        WHEN Discount <= 0.10 THEN '1%-10%'
        WHEN Discount <= 0.20 THEN '11%-20%'
        WHEN Discount <= 0.30 THEN '21%-30%'
        WHEN Discount <= 0.40 THEN '31%-40%'
        WHEN Discount <= 0.50 THEN '41%-50%'
        ELSE 'Above 50%'
    END
ORDER BY MIN(Discount);


-- ================================================================
-- BUSINESS QUESTION 17
-- "Which categories/sub-categories receive highest discounts?"
-- ================================================================

-- Categories

SELECT
    Category,
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent
FROM ecommerce_sales
GROUP BY Category
ORDER BY Average_Discount_Percent DESC;


-- Sub-categories

SELECT
    Sub_Category,
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent
FROM ecommerce_sales
GROUP BY Sub_Category
ORDER BY Average_Discount_Percent DESC;


-- ================================================================
-- BUSINESS QUESTION 18
-- "Which products have high discounts and negative profit?"
-- ================================================================

SELECT
    Product_Name,
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY Product_Name
HAVING AVG(Discount) >= 0.30
   AND SUM(Profit) < 0
ORDER BY Average_Discount_Percent DESC;


-- ================================================================
-- BUSINESS QUESTION 19
-- "Are high-sales products necessarily most profitable?"
-- ================================================================

SELECT
    Product_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 20;


-- ================================================================
-- BUSINESS QUESTION 20
-- "Which states and cities generate highest sales?"
-- ================================================================

-- States

SELECT
    State_Province,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM ecommerce_sales
GROUP BY State_Province
ORDER BY Total_Sales DESC;


-- Top 20 cities

SELECT
    City,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM ecommerce_sales
GROUP BY City
ORDER BY Total_Sales DESC
LIMIT 20;


-- ================================================================
-- BUSINESS QUESTION 21
-- "Which states and cities have highest/lowest profit?"
-- ================================================================

-- States

SELECT
    State_Province,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY State_Province
ORDER BY Total_Profit DESC;


-- Cities

SELECT
    City,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY City
ORDER BY Total_Profit DESC;


-- ================================================================
-- BUSINESS QUESTION 22
-- "Are there areas with high sales but low/negative profit?"
-- ================================================================

SELECT
    State_Province,
    City,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY State_Province, City
HAVING SUM(Sales) > 5000
   AND SUM(Profit) < 500
ORDER BY Total_Sales DESC;


-- ================================================================
-- BUSINESS QUESTION 23
-- "Which shipping modes are most used and how do they compare
-- in sales, profit and time?"
-- ================================================================

SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(AVG(Shipping_Days), 2) AS Average_Shipping_Days
FROM ecommerce_sales
GROUP BY Ship_Mode
ORDER BY Total_Orders DESC;


-- ================================================================
-- BUSINESS QUESTION 24
-- "What is average shipping time and which regions/modes take
-- longest?"
-- ================================================================

-- By region

SELECT
    Region,
    ROUND(AVG(Shipping_Days), 2) AS Average_Shipping_Days
FROM ecommerce_sales
GROUP BY Region
ORDER BY Average_Shipping_Days DESC;


-- By shipping mode

SELECT
    Ship_Mode,
    ROUND(AVG(Shipping_Days), 2) AS Average_Shipping_Days
FROM ecommerce_sales
GROUP BY Ship_Mode
ORDER BY Average_Shipping_Days DESC;


-- Overall average

SELECT
    ROUND(AVG(Shipping_Days), 2) AS Overall_Average_Shipping_Days
FROM ecommerce_sales;


-- ================================================================
-- BUSINESS QUESTION 25
-- "Which combinations of products, customers, regions, discounts
-- and shipping contribute most to profitable performance?"
-- ================================================================

SELECT
    Product_Name,
    Customer_Name,
    Region,
    Ship_Mode,
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM ecommerce_sales
GROUP BY
    Product_Name,
    Customer_Name,
    Region,
    Ship_Mode
ORDER BY Total_Profit DESC
LIMIT 20;


-- ================================================================
-- ACTUAL FINDINGS FROM QUESTIONS 1–25
-- ================================================================
-- These findings are based on the results produced from the cleaned
-- ecommerce_sales table during the analysis.

-- Overall performance:
-- Total Sales = $2,326,153.86
-- Total Profit = $292,273.46
-- Total Quantity Sold = 38,644
-- Total Orders = 5,111
-- Total Customers = 804
-- Average Order Value = $455.13
-- Overall Profit Margin = 12.56%
-- Average Discount = 15.54%
-- Average Shipping Days = 3.96

-- Time performance:
-- 2026 recorded the highest annual sales ($745,567.53) and profit
-- ($95,926.35). Q4 was the strongest quarter in each year shown.
-- November 2026 recorded the highest monthly sales at $118,454.51.

-- Regional performance:
-- West recorded the highest sales ($739,813.61) and profit ($110,798.82).
-- East followed with $691,447.68 sales and $94,859.90 profit.
-- Central recorded $503,170.67 sales but only $39,865.31 profit,
-- giving it a much weaker profit margin than the other regions.
-- South recorded $391,721.90 sales and $46,749.43 profit.

-- Category and sub-category performance:
-- Technology led both sales ($839,893.28) and profit ($146,543.38).
-- Furniture generated $754,367.27 sales but only $19,706.64 profit.
-- Tables recorded the lowest sub-category profit at -$17,753.21.
-- Supplies and Bookcases also recorded negative profit.

-- Product performance:
-- Canon imageCLASS 2200 Advanced Copier was the highest-sales product
-- in the reviewed top products and generated $25,199.93 profit.
-- Several high-sales products were loss-making, including the Cisco
-- TelePresence System EX90 (-$1,811.08), GBC DocuBind P400 (-$1,878.17),
-- Lexmark MX611dhe (-$4,589.97), and Cubify CubeX 3D Printer
-- (-$8,879.97).

-- Customer and segment performance:
-- Consumer generated the highest sales ($1,170,659.79) and profit
-- ($136,371.45). Corporate generated $715,707.01 sales and $94,214.23
-- profit, while Home Office generated $439,787.06 sales and $61,687.79 profit.
-- Home Office had the highest average order value at $472.38.
-- Sean Miller had $25,043.05 sales but -$1,980.74 profit, showing that
-- high customer sales do not always translate into positive profitability.

-- Discount performance:
-- The 0% discount group generated a 29.56% profit margin.
-- Profitability declined as discount levels increased in the grouped
-- analysis. Discounts above 20% produced negative profit margins, with
-- the Above 50% group recording -118.71%.
-- Furniture had the highest average discount at 17.30%, followed by
-- Office Supplies at 15.63% and Technology at 13.15%.

-- Geographic performance:
-- California and New York recorded the highest state sales.
-- Several high-sales states were loss-making, including Texas
-- (-$25,729.36), Ohio (-$16,959.32), Pennsylvania (-$15,559.96),
-- and Illinois (-$12,607.89).
-- Philadelphia, Houston and Chicago were among the high-sales cities
-- with negative profit.

-- Shipping performance:
-- Standard Class was the most-used shipping mode with 3,068 orders,
-- followed by Second Class (982), First Class (795) and Same Day (266).
-- Average shipping time was 3.96 days overall. Standard Class averaged
-- 4.99 days, Second Class 3.24 days, First Class 2.18 days and Same Day
-- 0.04 days. Regional averages ranged from 3.91 to 4.05 days.


-- ================================================================
-- FINAL BUSINESS THEMES IDENTIFIED FROM THE ANALYSIS
-- ================================================================

-- 1. Overall sales and profit growth:
-- Sales and profit increased over the four-year period, with 2026
-- recording the highest annual sales and profit. This indicates that
-- the business expanded its revenue base over time.

-- 2. Strong regional performance with a Central profitability gap:
-- West generated the highest sales and profit, while East also remained
-- a major contributor. Central generated substantial sales but a much
-- lower profit margin, showing that sales volume alone is not enough to
-- explain regional performance.

-- 3. Technology drives the strongest category economics:
-- Technology led both sales and profit. Its contribution is therefore
-- important to overall revenue and profitability performance.

-- 4. Furniture has a sales-to-profit imbalance:
-- Furniture generated high sales but relatively low profit. The gap is
-- reinforced by the weak performance of Tables, Bookcases and other
-- furniture-related products with negative profit.

-- 5. Product revenue does not always equal product profitability:
-- Several products generated substantial sales while producing little or
-- negative profit. This shows why product decisions should consider both
-- sales and profit rather than sales ranking alone.

-- 6. Discounting is strongly associated with weaker profitability:
-- The grouped discount analysis shows progressively weaker profit margins
-- as discount levels rise. Groups above 20% discount recorded negative
-- profit margins. This is an important pricing and promotion control area.

-- 7. Consumer is the largest segment, while order value differs by segment:
-- Consumer contributes the largest sales and profit. Home Office has the
-- highest average order value, indicating that segment size and order value
-- provide different views of customer economics.

-- 8. Customer sales rankings do not always represent customer value:
-- Some high-spending customers are highly profitable, while others can
-- generate losses. Customer evaluation therefore needs both sales and
-- profit measures.

-- 9. Several high-sales locations are loss-making:
-- Texas, Ohio, Pennsylvania and Illinois recorded high sales but negative
-- total profit. City-level results also show substantial loss-making sales
-- markets such as Philadelphia, Houston and Chicago.

-- 10. Shipping demand is concentrated in Standard Class:
-- Standard Class accounts for the largest number of orders and the largest
-- sales/profit contribution among shipping modes. Same Day is substantially
-- faster, but its use is much lower. Shipping decisions therefore involve
-- both service speed and commercial economics.

-- 11. Regional shipping times are relatively close:
-- Regional average shipping times range from 3.91 to 4.05 days, so the
-- main shipping-time difference comes from the selected shipping mode
-- rather than large regional variation.

-- 12. Profitable combinations are concentrated around strong products,
-- customers and controlled discounting:
-- The final product/customer/region/shipping analysis shows that some
-- combinations generate strong profit with low discounts, while other
-- combinations combine higher discounts with weak or negative profit.

-- ================================================================
-- FINAL BUSINESS RECOMMENDATIONS
-- ================================================================

-- 1. Tighten discount governance:
-- Establish clearer approval thresholds for discounts above 20%, with
-- additional review for products or locations already producing weak
-- margins. Use margin impact, not sales uplift alone, to evaluate promotions.

-- 2. Review high-sales loss-making products:
-- Investigate the cost, pricing, discount level and sales mix of products
-- such as the Cubify CubeX 3D Printer, Lexmark MX611dhe, GBC DocuBind P400
-- and Cisco TelePresence System EX90 before continuing aggressive promotion.

-- 3. Improve Furniture profitability:
-- Review pricing, discounting and product economics within Furniture,
-- especially Tables and Bookcases, which recorded negative profit. The
-- objective should be to improve contribution from existing sales rather
-- than simply increase Furniture volume.

-- 4. Investigate loss-making states and cities:
-- Prioritize detailed reviews of Texas, Ohio, Pennsylvania and Illinois,
-- together with high-sales loss-making cities such as Philadelphia,
-- Houston and Chicago. Compare product mix, discounting and customer mix
-- to identify the specific causes of negative profit.

-- 5. Manage customers using profitability as well as sales:
-- Maintain relationships with profitable high-value customers while
-- reviewing high-sales customers with negative profit. Sean Miller is a
-- clear example of why sales value should be assessed alongside profit.

-- 6. Protect profitable product/customer combinations:
-- Identify combinations similar to the strongest profitable combinations
-- in Question 25 and support them through targeted promotions, availability
-- and customer retention, provided their margins remain attractive.

-- 7. Continue supporting strong regions while addressing weak margins:
-- Maintain the commercial strengths of West and East while investigating
-- the reasons behind Central's lower profitability and the losses observed
-- in specific states.

-- 8. Match shipping service to customer and order economics:
-- Keep Standard Class as an important fulfillment option while using faster
-- shipping where customer needs justify it. The analysis should be paired
-- with shipping-cost data when available before changing the current mix.

-- 9. Monitor peak periods for profitable growth:
-- Q4 and other strong sales periods should be monitored for discount levels,
-- product mix and profit margin so that higher sales translate into healthy
-- contribution rather than low-margin volume.

-- 10. Use a combined management view:
-- Product, customer, segment, region, discount, sales, profit and shipping
-- measures should be reviewed together in management decisions. This will
-- help distinguish revenue growth from profitable growth.

-- NOTE: The discount/profit relationship is an observed association in
-- this dataset. It should not be treated as proof that discounting alone
-- causes the observed profit changes.


-- ================================================================
-- PHASE 6: BUSINESS ANALYSIS / FINAL KPI SUMMARY
-- ================================================================
-- This final query can be used to verify the numbers before
-- connecting MySQL to Power BI.
-- ================================================================

SELECT
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity_Sold,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    ROUND(SUM(Sales) / COUNT(DISTINCT Order_ID), 2) AS Average_Order_Value,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Percent,
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent,
    ROUND(AVG(Shipping_Days), 2) AS Average_Shipping_Days
FROM ecommerce_sales;


-- ================================================================
-- PHASE 7: CONNECT MYSQL TO POWER BI
-- ================================================================
--
-- Power BI Desktop:
-- 1. Get Data
-- 2. Select MySQL Database
-- 3. Server: localhost:3306
-- 4. Database: ecommerce_analytics
-- 5. Authenticate using MySQL credentials
-- 6. Select ecommerce_sales
-- 7. Load the cleaned/transformed table
-- 8. Perform only minor Power Query transformations if necessary
-- 9. Build the executive dashboard
--
-- Recommended dashboard sections:
-- Executive Overview
-- Product & Customer Performance
-- Profitability & Discount
-- Geography & Shipping
--
-- Recommended KPI cards:
-- Total Sales
-- Total Profit
-- Profit Margin
-- Total Orders
-- Total Quantity
-- Average Order Value
-- Average Shipping Days
-- Total Customers
-- ================================================================


-- ================================================================
-- FINAL PROJECT CHECK
-- ================================================================

SELECT
    'PROJECT BY CHIDI ONOCHIE RONALD' AS Project_Owner,
    'ecommerce_analytics' AS Database_Name,
    'ecommerce_sales' AS Table_Name,
    COUNT(*) AS Final_Row_Count,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM ecommerce_sales;


-- ================================================================
-- END OF SQL PROJECT
-- PROJECT BY: CHIDI ONOCHIE RONALD
-- ================================================================


