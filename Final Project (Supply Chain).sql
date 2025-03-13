SELECT TOP (1000) [Product_type],
      [SKU],
      [Price],
      [Availability],
      [Number_of_products_sold],
      [Revenue_generated],
      [Customer_demographics],
      [Stock_levels],
      [Lead_times],
      [Order_quantities],
      [Shipping_times],
      [Shipping_carriers],
      [Shipping_costs],
      [Supplier_name],
      [Location],
      [Lead_time],
      [Production_volumes],
      [Manufacturing_lead_time],
      [Manufacturing_costs],
      [Inspection_results],
      [Defect_rates],
      [Transportation_modes],
      [Routes],
      [Costs]
  FROM [supply_chain_data].[dbo].[supply_chain_data];


--  Add a new column to temporarily store the calculated revenue
ALTER TABLE [supply_chain_data].[dbo].[supply_chain_data]
ADD New_Revenue_generated DECIMAL(18, 2);

-- Calculate the new revenue and update the temporary column
UPDATE [supply_chain_data].[dbo].[supply_chain_data]
SET New_Revenue_generated = Price * Number_of_products_sold;

--  Drop the old Revenue_generated column
ALTER TABLE [supply_chain_data].[dbo].[supply_chain_data]
DROP COLUMN Revenue_generated;

--  Rename the new column to Revenue_generated
EXEC sp_rename '[supply_chain_data].[dbo].[supply_chain_data].New_Revenue_generated', 'Revenue_generated', 'COLUMN';
-- Remove text from SKU
UPDATE [supply_chain_data].[dbo].[supply_chain_data]
SET SKU = CAST(SUBSTRING(SKU, PATINDEX('%[0-9]%', SKU), LEN(SKU)) AS INT);

-- Remove null data
DELETE FROM [supply_chain_data].[dbo].[supply_chain_data]  
WHERE Price < 0 OR [Revenue_generated] < 0 OR Availability < 0;

-- Edit data type
ALTER TABLE [supply_chain_data].[dbo].[supply_chain_data]  
ALTER COLUMN [Customer_demographics] VARCHAR(255);

UPDATE [supply_chain_data].[dbo].[supply_chain_data]  
SET [Customer_demographics] = 'Unknown'  
WHERE CAST([Customer_demographics] AS VARCHAR(MAX)) IS NULL  
  OR CAST([Customer_demographics] AS VARCHAR(MAX)) = '';

-- Outliers
SELECT * FROM supply_chain_data  
WHERE Price > (SELECT AVG(Price) + 3 * STDEV(Price) FROM supply_chain_data)  
   OR Price < (SELECT AVG(Price) - 3 * STDEV(Price) FROM supply_chain_data);

 Remove unknown values
DELETE FROM [supply_chain_data].[dbo].[supply_chain_data]
WHERE [Customer_demographics] IS NULL OR [Customer_demographics] = 'Unknown';

 Update defect rates format
UPDATE [supply_chain_data].[dbo].[supply_chain_data]
SET [Defect_rates] = FORMAT([Defect_rates] * 100, 'N2') + '%';

-- Add new columns if they don't exist
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'supply_chain_data';

ALTER TABLE supply_chain_data ADD 
    Profit_Margin FLOAT,
    Stock_Turnover_Ratio FLOAT,
    Lead_Time_Variance INT,
    Order_Fulfillment_Rate FLOAT,
    Logistics_Efficiency_Score FLOAT,
    Defect_Rate_Category VARCHAR(10),
    Customer_Segment VARCHAR(50),
    Avg_Revenue_Per_Order FLOAT,
    Inventory_Health_Score FLOAT,
    Order_Delay_Risk VARCHAR(20),
    Transport_Cost_Per_Unit FLOAT,
    Production_Efficiency_Score FLOAT,
    Defect_Rate_Normalized FLOAT,
    Profit_Per_Product FLOAT,
    Sales_Performance_Category VARCHAR(20);




-- Calculate percentiles for Sales_Performance_Category
WITH Percentiles AS (
    SELECT 
        [Revenue_generated],
        PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY [Revenue_generated]) 
        OVER () AS Percentile_80,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Revenue_generated]) 
        OVER () AS Percentile_50
    FROM [supply_chain_data]
)
UPDATE supply_chain_data
SET 
    Profit_Margin = (([Revenue_generated] - [Manufacturing_costs]) / NULLIF([Revenue_generated], 0)) * 100,
    Stock_Turnover_Ratio = [Number_of_products_sold] / NULLIF([Stock_levels], 0),
    Lead_Time_Variance = [Lead_time] - [Manufacturing_lead_time],
    Order_Fulfillment_Rate = ([Order_quantities] / NULLIF([Number_of_products_sold], 0)) * 100,
    Logistics_Efficiency_Score = [Revenue_generated] / NULLIF([Costs], 0),
    Defect_Rate_Category = CASE 
        WHEN [Defect_rates] < 2 THEN 'Low' 
        WHEN [Defect_rates] BETWEEN 2 AND 5 THEN 'Medium' 
        ELSE 'High'
    END,
    Customer_Segment = CASE 
        WHEN [Customer_demographics] = 'Female' AND [Revenue_generated] > 5000 THEN 'High-Value Female Customers'
        WHEN [Customer_demographics] = 'Male' AND [Revenue_generated] > 5000 THEN 'High-Value Male Customers'
        ELSE 'General Customers' 
    END,
    Avg_Revenue_Per_Order = [Revenue_generated] / NULLIF([Order_quantities], 0),
    Inventory_Health_Score = ([Stock_levels] / NULLIF([Number_of_products_sold], 0)) * 100,
    Order_Delay_Risk = CASE 
        WHEN [Lead_time] > 20 AND [Transportation_modes] = 'Road' THEN 'High Risk'
        WHEN [Lead_time] > 15 AND [Transportation_modes] = 'Rail' THEN 'Medium Risk'
        ELSE 'Low Risk' 
    END,
    Transport_Cost_Per_Unit = [Costs] / NULLIF([Number_of_products_sold], 0),
    Production_Efficiency_Score = [Production_volumes] / NULLIF([Manufacturing_lead_time], 0),
    Defect_Rate_Normalized = [Defect_rates] / NULLIF([Manufacturing_costs], 0),
    Profit_Per_Product = ([Revenue_generated] - [Manufacturing_costs] - [Costs]) / NULLIF([Number_of_products_sold], 0),
    Sales_Performance_Category = CASE 
        WHEN [Revenue_generated] > (SELECT Percentile_80 FROM Percentiles WHERE supply_chain_data.Revenue_generated = Percentiles.Revenue_generated) THEN 'Top Performing'
        WHEN [Revenue_generated] BETWEEN (SELECT Percentile_50 FROM Percentiles WHERE supply_chain_data.Revenue_generated = Percentiles.Revenue_generated)
            AND (SELECT Percentile_80 FROM Percentiles WHERE supply_chain_data.Revenue_generated = Percentiles.Revenue_generated) THEN 'Average'
        ELSE 'Low Performing'
    END;

ALTER TABLE supply_chain_data ADD Total_Expenses FLOAT;

--  TotalExpenses
UPDATE supply_chain_data
SET Total_Expenses = 
    [Manufacturing_costs] +  [Shipping_costs] + [Costs];


ALTER TABLE supply_chain_data ADD Profit FLOAT;

-- Calculate Profit as Revenue minus Total Expenses
UPDATE supply_chain_data
SET Profit = 
    [Revenue_generated] - (
        [Manufacturing_costs] + 
        [Shipping_costs] + 
        [Costs]
    );
-- Indexing for performance optimization
CREATE INDEX idx_Profit_Margin ON supply_chain_data(Profit_Margin);
CREATE INDEX idx_Stock_Turnover_Ratio ON supply_chain_data(Stock_Turnover_Ratio);
CREATE INDEX idx_Order_Fulfillment_Rate ON supply_chain_data(Order_Fulfillment_Rate);
CREATE INDEX idx_Sales_Performance_Category ON supply_chain_data(Sales_Performance_Category);
CREATE INDEX idx_Customer_Segment ON supply_chain_data(Customer_Segment);

