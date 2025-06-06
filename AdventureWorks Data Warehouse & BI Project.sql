---Option A: Build Your Own Dimensions + Fact
------Business Scenario - Track total sales by product, by customer, over time.



--1.Design & Implement
 --Option A: Design at least three new dimension tables (e.g. Date, Product, Customer) plus one fact table (e.g. Sales).

  --Step 1 
    --Star Schema 
     -- 1 fact table(Sales) ,4 dim tables(Date, Product, Customer, Geography)
---/*Quantitative data/*
Select *
From  [dbo].[FactResellerSales]; 
Select *
From [dbo].[FactSalesQuota]; 
---/*context to the fact table/*
Select *
From [dbo].[DimDate];

Select *
From [dbo].[DimProduct];


Select*
From [dbo].[DimCustomer];

Select *
From [dbo].[DimCurrency];

---2.	ETL with T SQL

-- Extract from source tables - Product


Select
    p.ProductKey,
    p.EnglishProductName,
    p.ProductSubcategoryKey,
    p.Color,
    p.StandardCost,
    p.DealerPrice,
    p.StartDate,
    p.EndDate
FROM [dbo].[DimProduct] as p
LEFT JOIN [dbo].[DimProductSubcategory] ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN [dbo].[DimProductCategory] pc ON ps.ProductCategoryKey = pc.ProductCategoryKey;

Select*

From [dbo].[DimProductCategory];
Select*

From [dbo].[DimProductSubcategory];


-- Extract from source tables - Customer
SELECT 
    c.CustomerKey,
	c.GeographyKey,
    c.FirstName,
    c.LastName,
    c.Gender,
    c.EnglishEducation,
    c.EnglishOccupation,
    c.YearlyIncome
FROM [dbo].[DimCustomer] as c
JOIN [dbo].[DimGeography] g ON c.GeographyKey = g.GeographyKey;


-- Extract from source tables - Date
Select *
From [dbo].[DimDate] d;
Select *
From  [dbo].[FactResellerSales] frs;


-- Extract from source tables - Fact Table(Sales)
SELECT 
    frs.ProductKey,
    p.EnglishProductName,
    p.ProductSubcategoryKey,
    p.Color,
    p.StandardCost,
    p.DealerPrice,
    
    frs.UnitPrice,
    frs.OrderQuantity,
    frs.SalesAmount,
    frs.OrderDateKey,
	frs.UnitPrice * frs.OrderQuantity AS LineTotal,
    
    g.GeographyKey,
    g.City,
    g.StateProvinceName,
    
	d.DateKey
    
FROM [dbo].[FactResellerSales] frs
LEFT JOIN [dbo].[DimProduct] p ON frs.ProductKey = p.ProductKey
LEFT JOIN [dbo].[DimGeography] g ON frs.SalesTerritoryKey = g.SalesTerritoryKey 
LEFT JOIN [dbo].[DimCustomer] c ON g.GeographyKey = c.GeographyKey
LEFT JOIN [dbo].[DimDate] d ON frs.OrderDateKey = d.DateKey

ORDER by  DealerPrice ASC;

---Date Creation Tables
SELECT
    FORMAT(d.FullDateAlternateKey, 'dd-MM-yyyy') AS YearMonth,
    SUM(frs.SalesAmount) AS MonthlySales
FROM FactResellerSales frs
LEFT JOIN DimDate d ON frs.OrderDateKey = d.DateKey
GROUP BY FORMAT(d.FullDateAlternateKey, 'dd-MM-yyyy')
;

SELECT
    p.EnglishProductName AS ProductName,
    SUM(frs.SalesAmount) AS TotalSales
FROM FactResellerSales frs
LEFT JOIN DimProduct p ON frs.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalSales DESC;

SELECT
    c.FirstName + ' ' + c.LastName AS CustomerName,
    SUM(frs.SalesAmount) AS TotalSales
FROM FactResellerSales frs
LEFT JOIN DimCustomer c ON frs.CustomerKey = c.CustomerKey
GROUP BY c.FirstName, c.LastName
ORDER BY TotalSales DESC;

SELECT
    FORMAT(d.FullDateAlternateKey, 'yyyy-MM') AS YearMonth,
    SUM(frs.SalesAmount) AS MonthlySales
FROM FactResellerSales frs
LEFT JOIN DimDate d ON frs.OrderDateKey = d.DateKey
GROUP BY FORMAT(d.FullDateAlternateKey, 'yyyy-MM')
ORDER BY YearMonth;

SELECT
    FORMAT(d.FullDateAlternateKey, 'dd-MM-yyyy') AS SaleDate,
    SUM(frs.SalesAmount) AS DailySales
FROM FactResellerSales frs
LEFT JOIN DimDate d ON frs.OrderDateKey = d.DateKey
GROUP BY FORMAT(d.FullDateAlternateKey, 'dd-MM-yyyy');

