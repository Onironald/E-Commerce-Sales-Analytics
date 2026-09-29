# Data Dictionary

**Source file:** `samplesuperstore.csv` (Superstore-style e-commerce sales data)
**Raw size:** 10,194 rows x 21 columns
**After cleaning (MySQL):** 10,192 rows (2 duplicate records removed), `Row_ID` dropped, 2 fields derived

## Original fields

| Column (CSV) | Column (MySQL) | Description |
| --- | --- | --- |
| Row ID | Row_ID | Technical row identifier, used only during cleaning and removed from the final table |
| Order ID | Order_ID | Order identifier. One order can contain several product rows, so it is not a primary key |
| Order Date | Order_Date | Date the order was placed |
| Ship Date | Ship_Date | Date the order was shipped |
| Ship Mode | Ship_Mode | Standard Class, Second Class, First Class, Same Day |
| Customer ID | Customer_ID | Unique customer identifier |
| Customer Name | Customer_Name | Customer name |
| Segment | Segment | Consumer, Corporate, Home Office |
| Country/Region | Country_Region | Country of the order |
| City | City | City of the order |
| State/Province | State_Province | State of the order |
| Postal Code | Postal_Code | Postal code |
| Region | Region | Sales region (West, East, Central, South) |
| Product ID | Product_ID | Product identifier |
| Category | Category | Furniture, Office Supplies, Technology |
| Sub-Category | Sub_Category | Product sub-category |
| Product Name | Product_Name | Product name |
| Sales | Sales | Sales amount (USD) |
| Quantity | Quantity | Units sold |
| Discount | Discount | Discount applied as a fraction (0.2 = 20%) |
| Profit | Profit | Profit on the line (negative = loss) |

## Derived fields

| Field | Definition |
| --- | --- |
| Shipping_Days | `Ship_Date - Order_Date` in days (order-to-ship time, not the full delivery cycle) |
| Profit_Margin | `Profit / Sales * 100` |

Year, quarter, month and discount-level groupings are also derived in SQL and Power BI.

## Data quality checks performed

- Duplicate rows removed (2)
- Dates converted to DATE type and validated
- No non-positive Sales or Quantity
- No invalid Discount values
- No Ship_Date earlier than Order_Date
- No missing Profit values
- Text fields trimmed of leading/trailing spaces
