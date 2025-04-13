--Create the database
CREATE DATABASE OnlineRetailDB;
GO

--Use the database
USE OnlineRetailDB;
GO

--Create the Customers Table
CREATE TABLE Customers(
CustomerID INT PRIMARY KEY IDENTITY(1,1),
FirstName VARCHAR(50),
LastName VARCHAR(50),
Email VARCHAR(100),
Phone VARCHAR(50),
Address VARCHAR(30),
City VARCHAR(30),
State VARCHAR(30),
Zipcode VARCHAR(30),
Country VARCHAR(30),
CreatedAt DATETIME DEFAULT GETDATE()
);

--Create the Products table
CREATE TABLE Products(
ProductId INT PRIMARY KEY IDENTITY(1,1),
ProductName VARCHAR(100),
CategoryID INT,
Price DECIMAL(10,2),
Stock INT,
CreatedAt DATETIME DEFAULT GETDATE()
);


--Create the Categories Table
CREATE TABLE Categories(
CategoryID INT PRIMARY KEY IDENTITY(1,1),
CategoryName VARCHAR(100),
Description VARCHAR(200)
);


--Create the Orders Table

CREATE TABLE Orders(
OrderId INT PRIMARY KEY IDENTITY(1,1),
CustomerID INT,
OrderedDate DATETIME DEFAULT GETDATE(),
TotalAmount DECIMAL(10,2),
FOREIGN KEY(CustomerID) REFERENCES Customers (CustomerID)
);
--Alter / Rename the Column Name

EXEC sp_rename 'Orders.OrderId', 'OrderID';

--Create the OrderItems Table 

CREATE TABLE OrderItems(
OrderItemID INT PRIMARY KEY IDENTITY(1,1),
OrderID INT,
ProductID INT,
Quantity INT,
FOREIGN KEY (ProductID) REFERENCES Products(ProductId),
FOREIGN KEY (OrderID) REFERENCES Orders(OrderId)
);



--Insert sample data into Categories Table
INSERT INTO Categories(CategoryName, Description)
VALUES('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');

INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-Shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150);

-- Insert sample data into Customers Table

INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, Zipcode, Country)
VALUES('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-789', '123 Elm St.', 'SpringField', 'IL', '62701', 'USA'), 
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 'WI', '53703', 'USA'),
('Alice', 'Johnson', 'alice.johnson@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 'Maharashtra', '41520', 'INDIA');


--Insert sample data into Orders Table


INSERT INTO Orders(CustomerID, OrderedDate, TotalAmount)
VALUES(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);


--Insert sample data into OrderItems Table


Insert INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1, 49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99); 

ALTER TABLE OrderItems
Add Price DECIMAL(10,2); 




-- Query1: Retrieve all orders for a specific customer

Select o.OrderID, o.OrderedDate, o.TotalAmount, oi.ProductID, p.ProductName, oi.Quantity, oi.Price
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE o.CustomerID = 1;


--Query2: Find the total sales for each product

SELECT  p.ProductID, p.ProductName, SUM(oi.Quantity * oi.Price) AS TotalSales
FROM OrderItems oi
Join Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName;


EXEC sp_rename 'Products.ProductId', 'ProductID';


use OnlineRetailDB;




--Query 3: Calculate the average order value

SELECT AVG(TotalAmount) AS AverageOrderValue FROM Orders ;


--Query 4: List the top 5 customers by total spending

SELECT TOP 5 c.CustomerID, c.FirstName, c.LastName, c.Email, SUM(o.TotalAmount) AS TotalSpending
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email
ORDER BY TotalSpending ASC;


--Query 5: Retrieve the most popular product category

SELECT TOP 1 c.CategoryID, c.CategoryName, SUM(oi.Quantity) AS TotalQuantitySold
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalQuantitySold ASC;


--Query6: List all products that are out of stock, i.e, Stock = 0

--Inserted a prodcuts that are out of stock i.e, stock = 0

INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Keyboard', 1, 39.99, 0);


SELECT * FROM Products WHERE Stock= 0;


--Query7: Find customers who placed orders in the last 30 days

SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone, c.Address
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderedDate >= DATEADD(DAY, -30, GETDATE());

--Query8: Calculate the total number of orders placed each month

SELECT COUNT(OrderID) AS TotalOrders , YEAR(OrderedDate) AS OrderYear,
MONTH(OrderedDate) as OrderMonth
FROM Orders
GROUP BY  YEAR(OrderedDate), MONTH(OrderedDate)
ORDER BY OrderYear, OrderMonth;


--Query9: Retrieve the details of the most recent order

SELECT TOP 1 o.OrderID, o.OrderedDate, o.TotalAmount, c.FirstName, c.LastName, c.Phone
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderedDate DESC;


--Query10: Find the average price of products in each category

SELECT c.CategoryID, c.CategoryName, AVG(p.Price) AS AveragePrice
FROM Categories c
JOIN Products p ON c.CategoryID = p.ProductID
GROUP BY c.CategoryID, c.CategoryName;

--Query11: List customers who have never placed an order

-- FOR REFERENCE ::

--INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, Zipcode, Country)
--VALUES('Samyukta', 'Dahal', 'samyukta.dahal@gmail.com', '787899889', '123 EML St.', 'Portland', 'IL', '998800', 'Nepal');

SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone, c.Address, o.OrderID, o.TotalAmount
FROM Customers c 
FULL JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

--Ouery12: Retrieve the total quantity sold for each product

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) AS TotalQuantitySold
FROM OrderItems oi 
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName;


--Query13: Calculate the total revenue generated from each category

SELECT c.CategoryID, c.CategoryName, SUM(oi.Quantity * oi.Price) AS TotalRevenue
FROM OrderItems oi 
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalRevenue DESC;

--Query14: Find the highest-priced product in each category

SELECT c.CategoryID, c.CategoryName, p.ProductID, p.ProductName, p.Price
FROM Categories c 
JOIN Products p ON c.CategoryID = p.CategoryID
WHERE p.Price = (SELECT Max(Price) FROM Products);

----Query15: Retrieve orders with a total amount greater than a specific value (e.g, $500)

SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, o.TotalAmount
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.TotalAmount > 500
ORDER BY o.TotalAmount DESC;


--QUERY16: Calculate the total number of customers from each country

SELECT Country, Count(CustomerID) AS TotalCustomers
FROM Customers
GROUP BY Country;



















