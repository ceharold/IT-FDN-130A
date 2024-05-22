--*************************************************************************--
-- Title: Assignment06
-- Author: ChristieGlancy
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-05-20,ChristieGlancy,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ChristieGlancy')
	 Begin 
	  Alter Database [Assignment06DB_ChristieGlancy] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ChristieGlancy;
	 End
	Create Database Assignment06DB_ChristieGlancy;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ChristieGlancy;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

CREATE VIEW vCategories
WITH SchemaBinding
 AS
 SELECT CategoryID, CategoryName
 FROM dbo.Categories
 ;
GO

CREATE VIEW vEmployees
WITH SchemaBinding
 AS
 SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
 FROM dbo.Employees
 ;
GO

CREATE VIEW vInventories
WITH SchemaBinding
 AS
 SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
 FROM dbo.Inventories
 ;
GO

CREATE VIEW vProducts
WITH SchemaBinding
 AS
 SELECT ProductID, ProductName, CategoryID, UnitPrice
 FROM dbo.Products
 ;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_ChristieGlancy;
Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- SELECT CategoryName, ProductName, UnitPrice
-- FROM Categories AS c
-- JOIN Products AS p 
-- ON c.CategoryID = p.CategoryID
-- ORDER BY CategoryName, ProductName ASC
-- ;

-- CREATE VIEW vProductsByCategories
-- AS
--  SELECT TOP 100000 
--  CategoryName
--  ,ProductName
--  ,UnitPrice
--  FROM Categories AS c
--  JOIN Products AS p 
--  ON c.CategoryID = p.CategoryID
--  ORDER BY CategoryName, ProductName ASC
-- ;
-- GO

CREATE VIEW vProductsByCategories
AS
 SELECT
 CategoryName
 ,ProductName
 ,UnitPrice
 FROM Categories AS c
 JOIN Products AS p 
 ON c.CategoryID = p.CategoryID
;
GO

SELECT * FROM vProductsByCategories
ORDER BY CategoryName, ProductName ASC
;

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- SELECT ProductName, Count, InventoryDate
-- FROM Products AS p
-- JOIN Inventories AS i
-- ON p.ProductID = i.ProductId
-- ORDER BY InventoryDate, ProductName, Count ASC
-- ;

CREATE VIEW vInventoriesByProductsByDates
AS
 SELECT 
  ProductName
  ,InventoryDate
  ,Count
 FROM Products AS p
 JOIN Inventories AS i
 ON p.ProductID = i.ProductId
;
GO

SELECT * FROM vInventoriesByProductsByDates
ORDER BY 1,2,3
;

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- SELECT DISTINCT InventoryDate, CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
-- FROM Employees AS e
-- JOIN Inventories AS i
-- ON e.EmployeeID = i.EmployeeID
-- ORDER BY InventoryDate ASC
-- ;

CREATE VIEW vInventoriesByEmployeesByDates
AS
 SELECT DISTINCT
 InventoryDate
 ,CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
 FROM Employees AS e
 JOIN Inventories AS i
 ON e.EmployeeID = i.EmployeeID
;

SELECT * FROM vInventoriesByEmployeesByDates
ORDER BY InventoryDate ASC
;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- SELECT CategoryName, ProductName, InventoryDate, Count
-- FROM Categories AS c
-- JOIN Products AS p
-- ON c.CategoryID = p.CategoryID
-- JOIN Inventories AS i
-- ON i.ProductID = p.ProductID
-- ORDER BY CategoryName, ProductName, InventoryDate, Count ASC
-- ;

CREATE VIEW vInventoriesByProductsByCategories
AS
 SELECT 
 CategoryName
 ,ProductName
 ,InventoryDate
 ,Count
 FROM Categories AS c
 JOIN Products AS p
 ON c.CategoryID = p.CategoryID
 JOIN Inventories AS i
 ON i.ProductID = p.ProductID
 ;
 GO

SELECT * FROM vInventoriesByProductsByCategories
ORDER BY CategoryName, ProductName, InventoryDate, Count ASC
;

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- SELECT CategoryName, ProductName, InventoryDate, Count, CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
-- FROM Categories AS c
-- JOIN Products AS p
-- ON c.CategoryID = p.CategoryID
-- JOIN Inventories AS i
-- ON i.ProductID = p.ProductID
-- JOIN Employees AS e
-- ON e.EmployeeID = i.EmployeeID
-- ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName ASC
-- ;

CREATE VIEW vInventoriesByProductsByEmployees
AS
 SELECT 
 CategoryName
 ,ProductName
 ,InventoryDate
 ,Count
 ,CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
 FROM Categories AS c
 JOIN Products AS p
 ON c.CategoryID = p.CategoryID
 JOIN Inventories AS i
 ON i.ProductID = p.ProductID
 JOIN Employees AS e
 ON e.EmployeeID = i.EmployeeID
;
GO

SELECT * FROM vInventoriesByProductsByEmployees
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName ASC
;

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- SELECT CategoryName
--  ,ProductName
--  ,InventoryDate
--  ,Count
--  ,CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
-- FROM Categories AS c
-- JOIN Products AS p
-- ON c.CategoryID = p.CategoryID
-- JOIN Inventories AS i
-- ON i.ProductID = p.ProductID
-- JOIN Employees AS e
-- ON e.EmployeeID = i.EmployeeID
-- WHERE 
--  p.ProductName IN (SELECT ProductName FROM Products WHERE ProductName = 'Chai' OR ProductName = 'Chang')
-- ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName ASC
-- ;

CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
 SELECT CategoryName
 ,ProductName
 ,InventoryDate
 ,Count
 ,CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeName
 FROM Categories AS c
 JOIN Products AS p
 ON c.CategoryID = p.CategoryID
 JOIN Inventories AS i
 ON i.ProductID = p.ProductID
 JOIN Employees AS e
 ON e.EmployeeID = i.EmployeeID
 WHERE 
 p.ProductName IN (SELECT ProductName FROM Products WHERE ProductName = 'Chai' OR ProductName = 'Chang')
;

SELECT * FROM vInventoriesForChaiAndChangByEmployees
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName ASC
;

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- SELECT
--  CONCAT (m.EmployeeFirstName, ' ', m.EmployeeLastName) AS Manager
--  ,CONCAT (e.EmployeeFirstName, ' ', e.EmployeeLastName) AS Employee
-- FROM Employees AS e
-- JOIN Employees AS m
-- ON e.ManagerID = m.EmployeeID
-- ORDER BY Manager ASC
-- ;

CREATE VIEW vEmployeesByManager
AS
 SELECT
  CONCAT (m.EmployeeFirstName, ' ', m.EmployeeLastName) AS Manager
  ,CONCAT (e.EmployeeFirstName, ' ', e.EmployeeLastName) AS Employee
 FROM Employees AS e
 JOIN Employees AS m
 ON e.ManagerID = m.EmployeeID
 ;

SELECT * FROM vEmployeesByManager
ORDER BY Manager ASC
;

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--  SELECT CategoryID, CategoryName
--  FROM dbo.Categories
--  SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
--  FROM dbo.Employees
--  SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
--  FROM dbo.Inventories
--  SELECT ProductID, ProductName, CategoryID, UnitPrice
--  FROM dbo.Products

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
 SELECT c.CategoryID
 ,c.CategoryName
 ,p.ProductID
 ,p.ProductName
 ,p.UnitPrice
 ,e.EmployeeID
 ,e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
 ,e.ManagerID
 ,i.InventoryID
 ,i.InventoryDate
 ,i.Count
 ,m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager
 FROM Inventories as i
  INNER JOIN Products as p
  ON i.ProductID = p.ProductID
  INNER JOIN Categories as c
  ON p.CategoryID = c.CategoryID
  INNER JOIN Employees as e
  ON i.EmployeeID = e.EmployeeID
  INNER JOIN Employees as m
  ON e.ManagerID = m.EmployeeID
  ;
GO

SELECT * FROM vInventoriesByProductsByCategoriesByEmployees
ORDER BY CategoryID, ProductName, InventoryID, Employee ASC
;


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/