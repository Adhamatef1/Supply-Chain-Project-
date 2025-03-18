Supply Chain Dashboard


A project focused on analyzing and optimizing a cosmetics supply chain in India. The dashboard provides multiple pages covering shipping analysis, defect analysis, warehouse management, and expense tracking—all powered by SQL for data cleaning and Power BI for interactive visualizations.


1. Project Overview
Objective: Offer a comprehensive view of the supply chain’s performance, from shipping carriers to defect rates, stock levels, and expenses.
Technologies:
SQL: Used to clean and transform data, remove outliers, add new columns (e.g., Profit Margin), and improve performance with indexing.
Power BI: Utilized to create interactive dashboards with charts, slicers, and filters for better decision-making.


2. How to Run the Project
   
Download the files:
Final Project (Supply Chain) V3.pbix (Power BI file)
Final Project (Supply Chain).xlsx (Excel data) or connect directly to your SQL database if applicable.
Place them in the same folder on your local machine.
Open the .pbix file in Power BI Desktop.
Click Refresh to load the latest data.
Navigate between pages (tabs at the bottom) to explore each analysis section:
Home Page
Overview
Shipping Analysis
Defect Analysis
Warehouse Analysis
Expenses Analysis


4. SQL Highlights
Below is a snippet (not the full code) illustrating the data transformation logic. The complete script can be found in Final Project (Supply Chain).sql.

**sql

-- Example: Removing text from SKU and keeping only digits

UPDATE [supply_chain_data].[dbo].[supply_chain_data]
SET SKU = CAST(SUBSTRING(SKU, PATINDEX('%[0-9]%', SKU), LEN(SKU)) AS INT);

-- Deleting negative or invalid values
DELETE FROM [supply_chain_data].[dbo].[supply_chain_data]
WHERE Price < 0 OR [Revenue_generated] < 0 OR Availability < 0;

-- Adding new columns for advanced metrics
ALTER TABLE supply_chain_data ADD Profit_Margin FLOAT;

UPDATE supply_chain_data
SET Profit_Margin = ((Revenue_generated - Manufacturing_costs) / NULLIF(Revenue_generated,0)) * 100;
**


Why SQL?
Data Cleaning: Removing outliers, invalid entries, and null values.
Data Transformation: Calculating new metrics (Profit, Stock Turnover Ratio, etc.).
Performance: Creating indexes for faster queries.


4. Dashboard Pages & Charts
Each page focuses on a different aspect of the supply chain:


4.1 Home Page
A landing page to welcome users or display a project logo/title. You can add navigation buttons or a brief introduction here. Currently, it may be minimal or blank.


4.2 Overview Page
Goal: Present a high-level summary of the most important KPIs.

KPI Cards:
Total Revenue
Total Orders
Average Revenue per Product
Pie Chart – Profit per Customer Demographics: Shows profit share by demographic segments (e.g., Male, Female).
Treemap – Customer Segments: Segments customers into “High-Value” vs. “General.”
Gauge – In Stock: Illustrates current stock availability.
Bar Chart – Revenue by Product: Quick comparison of revenue for each product category (skincare, haircare, cosmetics).
Line Chart – Lead Times by Location: Highlights shipping or production lead times across major cities (Delhi, Mumbai, etc.).


4.3 Shipping Analysis
Goal: Deep-dive into carriers, transportation modes, and shipping costs.

KPI Cards:
Total Carriers: Number of shipping companies.
Average Shipping Costs: Mean cost of shipping per order.
Average Transport Cost per Unit: Tracks how much is spent per shipped unit.
Sankey Diagram – Carriers & Modes: Visualizes the flow from total orders to carriers, then breaks it down by transport mode (Road, Air, Sea, Rail).
Bar Chart – Average Lead Times by Product: Compares shipping times for different product lines.
Map – Shipping Locations: Geographical distribution of shipments across Indian cities.
Line Chart – Shipping Costs by Order Quantity: Analyzes how shipping costs scale with order volumes.


4.4 Defect Analysis
Goal: Monitor quality control and identify problem areas.

KPI Card – Average Defect Rate %: Quick look at overall defect rates.
Pie Chart – Inspection Results Breakdown: Pass, Fail, or Pending inspection statuses.
Bar Chart – Average Defect Rate by Supplier: Which supplier has the highest defect rate?
Bar Chart – Defect Rate by Product Type: Compare cosmetics vs. haircare vs. skincare.
Table – Defect Rate by Product & Supplier: Detailed matrix for pinpointing issues.
Line Chart – Average Defect Rate by Lead_time: Investigates if longer lead times correlate with higher defects.


4.5 Warehouse Analysis
Goal: Evaluate stock levels, turnover, and overall warehouse efficiency.

KPI Cards:
Total Stock Levels
Order Fulfillment Rate
Stock Turnover Ratio
Average Lead Time Variance
Bar Chart – Stock Levels per Product Type: Compare inventory levels across different product categories.
Pie Chart – Stock Turnover Ratio per Category: Which categories move faster?
Map – Stock Level by Location: Check how stock is distributed geographically.
Bar Chart – Lead Time Variance per Supplier: Highlights which supplier deviates most from expected lead times.
Line/Scatter – Order Delay Risk vs. Inventory Health Score: Relationship between risk of delay and inventory health.


4.6 Expenses Analysis
Goal: Understand where money is spent and how it affects profitability.

KPI Cards:
Total Expenses
Net Profit
Profit Margin %
Transport Cost Per Unit
Bar Chart – Profit vs. Expenses per Product: Compare product-level profitability vs. costs.
Bar/Pie Chart – Expense Breakdown: Illustrates manufacturing, shipping, and other costs.
Line Chart – Trend of Expenses Over Time: Shows expense fluctuations across orders or any timeline.
Pie/Donut – Expense Categories: Distribution of total expenses by product category.
5. Filters & Slicers
You’ve added several slicers for more dynamic analysis:

Location: Filter data by city (Delhi, Chennai, Bangalore, etc.).
Supplier Name: Focus on specific suppliers.
Delay Risk: High, Medium, Low.
Sales Performance: Top Performing, Average, Low Performing.
“Clear all slicers” button: Resets everything to default, ensuring a quick way to start fresh.
These filters enhance interactivity and allow stakeholders to isolate specific details.

6. Future Improvements
Add Historical Dates: For genuine time-series analysis and trend detection.
Real-Time Data Integration: Stream live data for immediate insights.
Predictive Analytics: Use ML models to forecast defects, lead times, or costs.
More Detailed Cost Breakdown: E.g., separate overhead costs, marketing, or administrative expenses.


Enjoy Exploring!
By combining SQL for robust data cleaning and Power BI for rich visualizations, this dashboard helps decision-makers pinpoint inefficiencies, reduce defects, optimize shipping, and manage warehouse stock effectively.

If you have any questions or suggestions, feel free to open an issue or submit a pull request. Happy analyzing!
