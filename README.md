# E-Commerce Sales Analytics

**From raw data to profitable business insights, using MySQL and Power BI.**

An end-to-end data analytics project that cleans and analyses an e-commerce sales dataset in **MySQL**, answers **25 business questions** with SQL, and presents the results in a **four-page Power BI dashboard**, a written **business report** and a **PowerPoint presentation**.

**Team:** Chidi · Phoebe · Toyeibat

---

## Table of Contents

1. [Business Problem](#business-problem)
2. [Project Objectives](#project-objectives)
3. [Dataset](#dataset)
4. [Tools and Skills](#tools-and-skills)
5. [Workflow](#workflow)
6. [Key Metrics](#key-metrics)
7. [Key Findings](#key-findings)
8. [Power BI Dashboard](#power-bi-dashboard)
9. [Recommendations](#recommendations)
10. [Repository Structure](#repository-structure)
11. [How to Reproduce](#how-to-reproduce)
12. [Limitations](#limitations)
13. [Contributors](#contributors)

---

## Business Problem

Sales growth does not always mean profitable growth. Management needs to understand **where sales come from, where profit is made, and where losses occur** across products, customers, regions, discounts and shipping choices, so that commercial decisions are based on evidence rather than on sales totals alone.

## Project Objectives

- Measure sales and profit performance over time
- Identify profitable and loss-making products and sub-categories
- Compare customer segments and customer-level sales and profitability
- Assess how discount levels affect profitability
- Identify regional and geographic differences in sales and profit
- Compare shipping modes by order volume, sales, profit and shipping time
- Provide practical recommendations for profitable growth and operational control

**Stakeholders supported:** Sales/Commercial, Product, Pricing/Marketing, Regional, Operations/Logistics, and Finance/Senior Management.

## Dataset

| Item | Detail |
| --- | --- |
| Source file | `data/samplesuperstore.csv` (Superstore-style e-commerce data) |
| Raw records | 10,194 rows, 21 columns |
| Cleaned records | 10,192 rows (2 duplicates removed) |
| Time period | Orders from 2023 to 2026 |
| Distinct orders | 5,111 |
| Distinct customers | 804 |

See the full [Data Dictionary](data/DATA_DICTIONARY.md).

## Tools and Skills

| Tool | Used for |
| --- | --- |
| **MySQL 8.0** | Database setup, data cleaning, validation, transformation, EDA, business analysis |
| **Power BI** | Data modelling, KPI cards, interactive four-page dashboard |
| **Microsoft Word** | Business report |
| **Microsoft PowerPoint** | Executive presentation |

**Skills demonstrated:** SQL aggregation, grouping, conditional logic, date functions, ranking, calculated measures, data cleaning and validation, dashboard design, business storytelling.

## Workflow

```
Raw CSV -> MySQL import -> SQL cleaning -> Validation -> Clean data
        -> EDA -> 25 business questions -> Power BI dashboard
        -> Insights -> Recommendations
```

1. **Understand the business:** problem, stakeholders, KPIs
2. **Data understanding:** structure, fields and keys
3. **Import into MySQL:** raw table loaded as a staging table
4. **Data cleaning:** a clean copy of the table was created, duplicates removed, dates and numeric fields validated, text trimmed, then the clean table replaced the raw one
5. **Transformation:** `Shipping_Days`, `Profit_Margin`, and year/quarter/month groupings
6. **EDA and business analysis:** 25 SQL business questions
7. **Power BI:** connected to MySQL and built a four-page executive dashboard

## Key Metrics

| Metric | Value |
| --- | --- |
| Total sales | $2,326,153.86 |
| Total profit | $292,273.46 |
| Profit margin | 12.56% |
| Total orders | 5,111 |
| Total customers | 804 |
| Total quantity sold | 38,644 |
| Average order value | $455.13 |
| Average discount | 15.54% |
| Average shipping days | 3.96 |

## Key Findings

- **Growth:** 2026 was the strongest year, with $745,567.53 in sales and $95,926.35 in profit. Q4 was the strongest quarter in every year shown.
- **Regions:** West led on sales ($739.8K) and profit ($110.8K), with a 14.98% margin. Central had $503.2K in sales but only $39.9K in profit (7.92% margin).
- **Categories:** Technology led on both sales ($839.9K) and profit ($146.5K). Furniture had $754.4K in sales but only $19.7K in profit, a 2.61% margin versus 17.45% for Technology and 17.22% for Office Supplies.
- **Sub-categories:** Tables had the lowest profit (-$17.8K); Supplies and Bookcases were also negative.
- **Loss-making high-sales products:** Cubify CubeX 3D Printer, Lexmark MX611dhe, GBC DocuBind P400 and Cisco TelePresence System EX90.
- **Discounts:** Profit margin fell as discounts rose. The 0% discount group had a 29.56% margin, discounts above 20% were loss-making, and discounts above 50% produced a **-118.71%** margin (about -$77.0K profit).
- **Segments:** Consumer led on sales ($1.17M) and profit ($136.4K). Home Office had the highest average order value ($472.38).
- **Customers:** High spend does not guarantee profit. One top customer had $25.0K in sales but a loss of $1.98K.
- **Geography:** Texas, Ohio, Pennsylvania and Illinois recorded high sales but negative profit. Philadelphia, Houston and Chicago were among the loss-making high-sales cities.
- **Shipping:** Standard Class was used most (3,068 orders) and averaged 4.99 days. Shipping-time differences were driven by ship mode rather than by region.

## Power BI Dashboard

The dashboard (`dashboard/ecommerce_analytics.pbix`) has four pages:

| Page | Content |
| --- | --- |
| **1. Executive Overview** | KPI cards, sales and profit by year, sales by region, sales by category, sales/profit by ship mode |
| **2. Product & Customer Performance** | Profit by sub-category, top customers, top products, loss-making products |
| **3. Profitability & Discount** | Profit by segment, sales and profit by category, profit margin by category, profit by discount level |
| **4. Regional & Shipping Analysis** | Sales and profit by region, sales by ship mode, average shipping days by ship mode |

### Page 1: Executive Overview
![Executive Overview](dashboard/screenshots/page1_executive_overview.png)

### Page 2: Product & Customer Performance
![Product and Customer Performance](dashboard/screenshots/page2_product_customer.png)

### Page 3: Profitability & Discount
![Profitability and Discount](dashboard/screenshots/page3_profitability_discount.png)

### Page 4: Regional & Shipping Analysis
![Regional and Shipping Analysis](dashboard/screenshots/page4_regional_shipping.png)

## Recommendations

1. **Tighten discount governance**, especially above 20%, weighing margin impact against sales uplift.
2. **Review high-sales, loss-making products** (pricing, cost, discounting).
3. **Improve Furniture profitability**, focusing on Tables and Bookcases.
4. **Investigate loss-making states and cities** (Texas, Ohio, Pennsylvania, Illinois; Philadelphia, Houston, Chicago).
5. **Manage customers by profit contribution**, not sales alone.
6. **Protect strong regions and investigate Central's** lower margin.
7. **Match shipping service to order economics.**
8. **Monitor Q4 and other peak periods** for discount levels and product mix.
9. **Use the dashboard as a recurring management review tool.**

## Repository Structure

```
ecommerce-sales-analytics/
├── README.md
├── .gitignore
├── data/
│   ├── samplesuperstore.csv          # Raw dataset
│   └── DATA_DICTIONARY.md            # Field definitions and quality checks
├── sql/
│   └── ecommerce_analytics.sql       # Import, cleaning, transformation, EDA, 25 business questions
├── dashboard/
│   ├── ecommerce_analytics.pbix      # Power BI dashboard (4 pages)
│   └── screenshots/                  # Dashboard page screenshots (4 PNGs)
├── reports/
│   └── Ecommerce_Business_Report_Chidi_Phoebe_Toyeibat.docx
└── presentation/
    └── Ecommerce_Sales_Analytics.pptx
```

## How to Reproduce

**Requirements:** MySQL 8.0+, MySQL Workbench (optional), Power BI Desktop.

1. **Clone the repo**
   ```bash
   git clone https://github.com/onironald/ecommerce-sales-analytics.git
   ```
2. **Prepare the CSV for import.** The script loads the file with `LOAD DATA INFILE` from MySQL's secure upload folder. Copy `data/samplesuperstore.csv` to `C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/`, or edit the path in `sql/ecommerce_analytics.sql` to match your setup.
3. **Run the SQL script** `sql/ecommerce_analytics.sql` in MySQL. It creates the `ecommerce_analytics` database, imports and cleans the data, and runs the 25 business questions.
4. **Open the dashboard.** Open `dashboard/ecommerce_analytics.pbix` in Power BI Desktop and, if prompted, update the data source to point to your MySQL server (`ecommerce_analytics` database, `ecommerce_sales` table), then refresh.

## Limitations

- The data covers a defined historical period and is not a forecast.
- `Shipping_Days` measures Order Date to Ship Date, not the complete customer delivery cycle.
- The relationship between discount and profit is an observed association, not proof of causation.
- Major decisions should be supported with operational, pricing and cost context.

## Contributors

- **Chidi**
- **Phoebe**
- **Toyeibat**

<!-- Add your LinkedIn / GitHub / email links here -->
