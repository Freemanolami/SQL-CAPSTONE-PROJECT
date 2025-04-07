CREATE DATABASE Super_store;

USE Super_store;

SELECT * FROM Store 

---- The dataset contains 21 columns and 9,994 rows.

--- Postal Code has some missing values (9983 non-null out of 9994).

--- Order Date and Ship Date are stored as text (object) instead of a proper DATE format.

--- There are duplicate records, especially for orders with the same Order ID, Customer ID, Product ID.






--- Data cleaning 

--- Firstly identify duplicates based on Order ID, Customer ID, Product ID, and Sales

SELECT Order_ID, Customer_ID, Product_ID, Sales, COUNT(*) AS duplicate_count
FROM Store
GROUP BY Order_ID, Customer_ID, Product_ID, Sales
HAVING COUNT(*) > 1;

--- To See Detailed Duplicate Entries

WITH DuplicateRecords AS (
    SELECT Order_ID, Customer_ID, Product_ID, Sales, 
           COUNT(*) OVER (PARTITION BY Order_ID, Customer_ID, Product_ID, Sales) AS duplicate_count
    FROM Store
)
SELECT * FROM DuplicateRecords WHERE duplicate_count > 1;

--- To remove the duplicates records

WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY Order_ID, Customer_ID, Product_ID, Sales ORDER BY Order_Date) AS row_num
    FROM store
)
DELETE FROM CTE WHERE row_num > 1;


--- Converting the Order Date and Ship Date to DATE format


ALTER TABLE Store
ALTER COLUMN [Order_Date] DATE;

ALTER TABLE Store
ALTER COLUMN [Ship_Date] DATE;


--- Fill Missing Postal Code Values

ALTER TABLE Store
ALTER COLUMN [Postal_Code] NVARCHAR(20);

UPDATE Store
SET [Postal_Code] = 'Unknown'
WHERE [Postal_Code] IS NULL;


---  Creating Tables 

--- Customers Table 

CREATE TABLE Customers(
    Customer_ID NVARCHAR(50) PRIMARY KEY,
    Customer_Name NVARCHAR(255) NOT NULL,
    Segment NVARCHAR(50) NOT NULL,
    Postal_Code NVARCHAR(20),
    City NVARCHAR(50) NOT NULL,
    Country_Region NVARCHAR(50) NOT NULL,
    State NVARCHAR(50) NOT NULL 
);


SELECT * FROM Customers


--- Products Table

CREATE TABLE Products(
    Product_ID NVARCHAR(50) PRIMARY KEY,
    Product_Name NVARCHAR(255) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    Sub_Category NVARCHAR(50) NOT NULL
);

SELECT * FROM Products


--- Orders Table 

CREATE TABLE Orders(
    Order_ID NVARCHAR(50) PRIMARY KEY,
    Order_Date DATE NOT NULL,
    Ship_Date DATE NOT NULL,
    Ship_Mode NVARCHAR(50) NOT NULL,
    Customer_ID NVARCHAR(50) NOT NULL,
    Postal_Code NVARCHAR(20),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
);

 SELECT * FROM Orders


--- Sales Table 

CREATE TABLE Sales(
    Order_ID NVARCHAR(50) NOT NULL,
    Product_ID NVARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    Sales DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(5,2) NOT NULL,
    Profit DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);


SELECT * FROM Sales


--- Populating The Tables

INSERT INTO Customers (Customer_ID, Customer_Name, Segment, Postal_Code, City, Country_Region, State)
SELECT Customer_ID, 
       MAX(Customer_Name), 
       MAX(Segment), 
       MAX(Postal_Code), 
       MAX(City), 
       MAX(Country_Region), 
       MAX(State)
FROM Store
GROUP BY Customer_ID;

SELECT * FROM Customers


INSERT INTO Products (Product_ID, Product_Name, Category, Sub_Category)
SELECT Product_ID, 
       MAX(Product_Name),  
       MAX(Category),     
       MAX(Sub_Category)   
FROM Store  
GROUP BY Product_ID;


INSERT INTO Orders (Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Postal_Code)
SELECT Order_ID, 
       MAX(Order_Date),  
       MAX(Ship_Date),    
       MAX(Ship_Mode),    
       Customer_ID,      
       MAX(Postal_Code)   
FROM Store  
GROUP BY Order_ID, Customer_ID;  

INSERT INTO Sales (Order_ID, Product_ID, Quantity, Sales, Discount, Profit)
SELECT Order_ID, 
       Product_ID, 
       SUM(Quantity) AS Quantity,               
       SUM(Sales) AS Sales,                    
       AVG(Discount) AS Discount,               
       SUM(Profit) AS Profit                     
FROM Store  
GROUP BY Order_ID, Product_ID;



---- To get The Total number of orders placed 

SELECT COUNT(*) AS Total_Orders
FROM Orders;

--- List unique product categories and sub-categories.

SELECT DISTINCT Category, Sub_Category
FROM Products;

--- Find the total sales and profit per Country_region.

SELECT c.Country_Region,
       SUM(s.Sales) AS Total_Sales,
       SUM(s.Profit) AS Total_Profit
FROM Sales s
JOIN Orders o ON s.Order_ID = o.Order_ID
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Country_Region;


--- Retrieve the top 5 customers based on total purchase amount.

SELECT TOP 5 c.Customer_ID,
       c.Customer_Name,
       SUM(s.Sales) AS Total_Purchase_Amount
FROM Sales s
JOIN Orders o ON s.Order_ID = o.Order_ID
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Purchase_Amount DESC;

--- Count the number of orders per shipping mode.

SELECT Ship_Mode, 
       COUNT(*) AS Number_of_Orders
FROM Orders
GROUP BY Ship_Mode;


--- Retrieve order details along with customer information using JOIN.

SELECT o.Order_ID,
       o.Order_Date,
       o.Ship_Date,
       o.Ship_Mode,
       o.Postal_Code,
       c.Customer_ID,
       c.Customer_Name,
       c.Country_Region,
       c.State,
       c.City
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID;


--- Get the total sales per product category.

SELECT p.Category,
       SUM(s.Sales) AS Total_Sales
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Category;


--- Find the customers who purchased "Technology" products.

SELECT DISTINCT c.Customer_ID, c.Customer_Name, c.Country_Region,c.State, c.City, p.Category
FROM Sales s
JOIN Orders o ON s.Order_ID = o.Order_ID
JOIN Customers c ON o.Customer_ID = c.Customer_ID
JOIN Products p ON s.Product_ID = p.Product_ID
WHERE p.Category = 'Technology';


--- Find total revenue, quantity sold, and average discount per category.

SELECT p.Category,
       SUM(s.Sales) AS Total_Revenue,
       SUM(s.Quantity) AS Total_Quantity_Sold,
       AVG(s.Discount) AS Average_Discount
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Category;


--- 

SELECT TOP 1 p.Product_ID,
       p.Product_Name,
       SUM(s.Profit) AS Total_Profit
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Profit DESC;


--- Identify the state with the highest number of orders.

SELECT TOP 1 c.State,
       COUNT(o.Order_ID) AS Number_of_Orders
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.State
ORDER BY Number_of_Orders DESC;


--- Find the orders where the sales amount is greater than the average sales.

SELECT o.Order_ID,
       o.Order_Date,
       o.Ship_Date,
       o.Ship_Mode,
       SUM(s.Sales) AS Total_Sales
FROM Sales s
JOIN Orders o ON s.Order_ID = o.Order_ID
GROUP BY o.Order_ID, o.Order_Date, o.Ship_Date, o.Ship_Mode
HAVING SUM(s.Sales) > (SELECT AVG(Sales) FROM Sales);


--- Retrieve the customer(s) who placed the highest number of orders.

SELECT TOP 1 c.Customer_ID,
       c.Customer_Name,
       COUNT(o.Order_ID) AS Number_of_Orders
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Number_of_Orders DESC;


--- List the products that were ordered more than the average quantity per order.

SELECT p.Product_ID,
       p.Product_Name,
       SUM(s.Quantity) AS Total_Quantity_Ordered
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING SUM(s.Quantity) > (SELECT AVG(s.Quantity) FROM Sales s);


--- Your manager wants to identify the best customer in each region based on total profit generated. 
--- This information will be used for targeted marketing campaigns.
--- Write an SQL query to retrieve the top-performing customer in each region based on total profit.

WITH RankedCustomers AS (
    SELECT c.Customer_ID,
           c.Customer_Name,
           c.Country_Region,
           SUM(s.Profit) AS Total_Profit,
           ROW_NUMBER() OVER (PARTITION BY c.Country_Region ORDER BY SUM(s.Profit) DESC) AS Rank
    FROM Sales s
    JOIN Orders o ON s.Order_ID = o.Order_ID
    JOIN Customers c ON o.Customer_ID = c.Customer_ID
    GROUP BY c.Customer_ID, c.Customer_Name, c.Country_Region
)
SELECT Customer_ID,
       Customer_Name,
       Country_Region,
       Total_Profit
FROM RankedCustomers
WHERE Rank = 1;


--- The logistics team is analyzing shipping efficiency and wants to identify the shipping method
---  that takes the longest time for high-value orders (orders above the average sales value). 
--- Write an SQL query to calculate the average shipping duration (in days) 
--- per shipping mode but only for orders where the sales amount is above the average sales amount across all orders.

WITH HighValueOrders AS (
    SELECT o.Order_ID,
           o.Ship_Mode,
           DATEDIFF(DAY, o.Ship_Date, o.Order_Date) AS Shipping_Duration,
           s.Sales
    FROM Sales s
    JOIN Orders o ON s.Order_ID = o.Order_ID
    WHERE s.Sales > (SELECT AVG(Sales) FROM Sales)
)
SELECT Ship_Mode,
       AVG(Shipping_Duration) AS Average_Shipping_Duration
FROM HighValueOrders
GROUP BY Ship_Mode
ORDER BY Average_Shipping_Duration DESC;


--- The sales team wants to optimize inventory by understanding which product category is the most ordered in each region. 
--- Write an SQL query to find the most popular product category in each region based on total quantity sold.

WITH RankedCategories AS (
    SELECT c.Country_Region,
           p.Category,
           SUM(s.Quantity) AS Total_Quantity_Sold,
           ROW_NUMBER() OVER (PARTITION BY c.Country_Region ORDER BY SUM(s.Quantity) DESC) AS Rank
    FROM Sales s
    JOIN Orders o ON s.Order_ID = o.Order_ID
    JOIN Customers c ON o.Customer_ID = c.Customer_ID
    JOIN Products p ON s.Product_ID = p.Product_ID
    GROUP BY c.Country_Region, p.Category
)
SELECT Country_Region,
       Category,
       Total_Quantity_Sold
FROM RankedCategories
WHERE Rank = 1;


--- The marketing team wants to target customers who are highly engaged with a variety of products. 
--- A customer is considered highly engaged if they have purchased at least three different product categories. 
--- Write an SQL query to list customers who have purchased from three or more distinct product categories.


SELECT o.Customer_ID,
       c.Customer_Name,
       COUNT(DISTINCT p.Category) AS Distinct_Categories_Purchased
FROM Sales s
JOIN Orders o ON s.Order_ID = o.Order_ID
JOIN Customers c ON o.Customer_ID = c.Customer_ID
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY o.Customer_ID, c.Customer_Name
HAVING COUNT(DISTINCT p.Category) >= 3;


--- The finance team is interested in determining the most profitable product in each state,
---  to focus marketing efforts on high-margin items. 
--- Write an SQL query to find the product that generated the highest total profit in each state.


WITH RankedProducts AS (
    SELECT c.State,
           p.Product_ID,
           p.Product_Name,
           SUM(s.Profit) AS Total_Profit,
           ROW_NUMBER() OVER (PARTITION BY c.State ORDER BY SUM(s.Profit) DESC) AS Rank
    FROM Sales s
    JOIN Orders o ON s.Order_ID = o.Order_ID
    JOIN Customers c ON o.Customer_ID = c.Customer_ID
    JOIN Products p ON s.Product_ID = p.Product_ID
    GROUP BY c.State, p.Product_ID, p.Product_Name
)
SELECT State,
       Product_ID,
       Product_Name,
       Total_Profit
FROM RankedProducts
WHERE Rank = 1;































