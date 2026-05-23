CREATE DATABASE Decodelabs;

CREATE TABLE SalesData (
    OrderID VARCHAR(20) PRIMARY KEY,
    OrderDate DATE,
    CustomerID VARCHAR(20),
    Product VARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    ShippingAddress VARCHAR(100),
    PaymentMethod VARCHAR(30),
    OrderStatus VARCHAR(30),
    TrackingNumber VARCHAR(30),
    ItemsInCart INT,
    CouponCode VARCHAR(30),
    ReferralSource VARCHAR(30),
    TotalPrice DECIMAL(10,2)
);

BULK INSERT SalesData
FROM 'C:\SQL_Data\DecodeLab Dataset for SQL.csv' 
WITH (
    FORMAT = 'CSV',
    CODEPAGE = '65001',
    FIRSTROW = 2
);

SELECT * FROM SalesData;

---Total Sales, Total Orders, AVerage Sales, Minimum Sale, Maximum Sale
SELECT
	SUM(TotalPrice) AS TotalSales,
	SUM(Quantity) AS TotalOrders,
	CAST(ROUND(AVG(TotalPrice),2) AS DECIMAL(10,2)) AS AverageSales,
	MIN(TotalPrice) AS MinimumSale,
	MAX(TotalPrice) AS MaximumSale
FROM SalesData;


---Gross Sales by Products
SELECT 
	Product,
	SUM(TotalPrice) AS GrossSales
FROM SalesData
GROUP BY Product
ORDER BY GrossSales DESC;

---Sales by Referral Source
SELECT ReferralSource,
       SUM(TotalPrice) AS Gross_Sales
FROM SalesData
GROUP BY ReferralSource
ORDER BY Gross_Sales DESC;



---SALES BY PAYMENT METHOD
SELECT PaymentMethod,
       SUM(TotalPrice) AS Gross_Sales
FROM SalesData
GROUP BY PaymentMethod
ORDER BY Gross_Sales DESC;

---ORDERS BY STATUS
SELECT OrderStatus,
	   COUNT(*) AS TotalOrders,
       SUM(TotalPrice) AS Gross_Sales
FROM SalesData
GROUP BY OrderStatus
ORDER BY Gross_Sales DESC;


---QUANTITY SOLD BY PRODUCTS
SELECT Product,
	   SUM(Quantity) QuantitySold
FROM SalesData
GROUP BY Product
ORDER BY QuantitySold DESC;

---REVENUE LEAKAGE ANALYSIS

---Unrealised Sales Analysis
SELECT 
	ISNULL(Product, 'Grand Total') AS Product,
    SUM(TotalPrice) Unrealised_Sales
FROM SalesData
WHERE OrderStatus IN ('Cancelled', 'Returned', 'Pending')
GROUP BY ROLLUP(Product);

---Cancelled Sales
SELECT 
    ISNULL(Product, 'Grand Total') AS Product,
    SUM(TotalPrice) AS Cancelled_Sales
FROM SalesData
WHERE OrderStatus = 'Cancelled'
GROUP BY ROLLUP(Product);

---Returned Sales
SELECT 
    ISNULL(Product, 'Grand Total') AS Product,
    SUM(TotalPrice) AS Returned_Sales
FROM SalesData
WHERE OrderStatus = 'Returned'
GROUP BY ROLLUP(Product);

---Pending Orders
SELECT 
    ISNULL(Product, 'Grand Total') AS Product,
    SUM(TotalPrice) AS Pending_Sales
FROM SalesData
WHERE OrderStatus = 'Pending'
GROUP BY ROLLUP(Product);

---Completed Sales
SELECT 
	ISNULL(Product, 'Grand Total') AS Product,
    SUM(TotalPrice) Completed_Sales
FROM SalesData
WHERE OrderStatus IN ('Shipped', 'Delivered')
GROUP BY ROLLUP(Product);

---Top 5 Highest Orders
SELECT TOP 5 OrderID,
       Product,
       TotalPrice
FROM SalesData
ORDER BY TotalPrice DESC;


---Percentage Revenue Contribution by Product
SELECT 
    Product,
    SUM(TotalPrice) AS Revenue,
    CAST(ROUND(
        (SUM(TotalPrice) * 100.0) /
        (SELECT SUM(TotalPrice) FROM SalesData),
    2) AS DECIMAL (10,2)) AS Percentage_Contribution
FROM SalesData
GROUP BY Product
ORDER BY Percentage_Contribution DESC;


---Sales Trend by Year
SELECT 
    YEAR(OrderDate) AS SalesYear,
    SUM(TotalPrice) AS TotalRevenue
FROM SalesData
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;

---High Value Customers
SELECT TOP 10
    CustomerID,
    SUM(TotalPrice) AS TotalSpent
FROM SalesData
GROUP BY CustomerID
ORDER BY TotalSpent DESC;

---Highest Individual Orders
SELECT TOP 10
    OrderID,
    Product,
    TotalPrice
FROM SalesData
ORDER BY TotalPrice DESC;

---Products with Revenue Above $65k
SELECT Product,
       SUM(TotalPrice) AS Revenue
FROM SalesData
WHERE OrderStatus IN ('Delivered', 'Shipped')
GROUP BY Product
HAVING SUM(TotalPrice) > 65000
ORDER BY Revenue DESC;


---Completed Vs Unrealized Sales Comparison
SELECT
    CASE
        WHEN OrderStatus IN ('Shipped', 'Delivered')
        THEN 'Completed'
        ELSE 'Unrealized'
    END AS SalesType,
    SUM(TotalPrice) AS Revenue
FROM SalesData
GROUP BY
    CASE
        WHEN OrderStatus IN ('Shipped', 'Delivered')
        THEN 'Completed'
        ELSE 'Unrealized'
    END;


SELECT * FROM SalesData