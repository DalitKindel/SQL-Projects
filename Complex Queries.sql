
------PROJECT GOAL------ 
--Applying SQL commands on the "AdventureWorks2019" database and answering 10 complex SQL questions.


--------QUESTION #1--------
--Write a query that displays the information about unpurchased products in the orders table.
--Display: product, name (product name), color, list price, size.

USE AdventureWorks2019                

SELECT   ProductID, Name, Color, ListPrice, Size
FROM     Production.Product
WHERE    ProductID NOT IN (SELECT s.ProductID
                           FROM   Sales.SalesOrderDetail s
                           WHERE  ProductID = s.ProductID)


--------UPDATE--------
--Before solving question #2, run the following updates:

USE AdventureWorks2019

UPDATE   Sales.Customer 
SET      PersonID = CustomerID     
WHERE    CustomerID <= 290  

UPDATE   Sales.Customer 
SET      PersonID = CustomerID + 1700     
WHERE    CustomerID >= 300 AND CustomerID <= 350  
    
UPDATE   Sales.Customer 
SET      PersonID = CustomerID + 1700     
WHERE    CustomerID >= 352 AND CustomerID <= 701


--------QUESTION #2--------
--Write a query that displays information about customers who have not placed orders.
--Display: Customerid, LastName, FirstName (customer name).
--Sort the report by Customerid in ascending order.
--If the customer does not have a first and last name, display 'unknown'.

USE AdventureWorks2019

SELECT   c.CustomerID, 
         CASE WHEN p.LastName IS NULL THEN 'Unknown' ELSE p.LastName END AS LastName, 
         CASE WHEN p.FirstName IS NULL THEN 'Unknown' ELSE p.FirstName END AS FirstName 
FROM     Sales.Customer c LEFT JOIN Person.Person p
ON       p.BusinessEntityID = c.PersonID
WHERE    c.CustomerID NOT IN (SELECT CustomerID
                              FROM   Sales.SalesOrderHeader
                              WHERE  CustomerID = c.CustomerID)
ORDER BY c.CustomerID


--------QUESTION #3--------
--Write a query that displays the details of the 10 customers who made the most orders.
--Display: Customerid, FirstName, LastName, and the number of orders placed by the customers.
--Sort the report by CountOfOrders in ascending order.

USE AdventureWorks2019

SELECT   DISTINCT TOP 10 c.CustomerID, p.FirstName, p.LastName, 
         COUNT (s.SalesOrderId) OVER (PARTITION BY s.CustomerID) AS CountOfOrders
FROM     Sales.Customer c JOIN Person.Person p 
ON       p.BusinessEntityID = c.PersonID
         JOIN Sales.SalesOrderHeader s 
ON       s.CustomerID = c.CustomerID
ORDER BY CountOfOrders DESC


--------QUESTION #4--------
--Write a query that displays information about employees and their roles.
--Display: FirstName, LastName, JobTitle, HireDate, and the number of employees in the same position the employee is in.

USE AdventureWorks2019

WITH CTE_Employee
AS
        (SELECT p.FirstName, p.LastName, e.JobTitle, e.HireDate,
	            COUNT (*) OVER(PARTITION BY e.JobTitle) AS CountOfTitle
         FROM   HumanResources.Employee e JOIN Person.Person p 
         ON     p.BusinessEntityID = e.BusinessEntityID)

SELECT   FirstName, LastName, JobTitle, HireDate, CountOfTitle 
FROM     CTE_Employee 


--------QUESTION #5--------
--Write a query that shows each customer the date of the last order they made and the date of the order before the last one they made.
--Display: SalesOrderID, CustomerID, LastName, FirstName, date of last order, date of order before last.

USE AdventureWorks2019

WITH CTE_Sales
AS
        (SELECT  h.SalesOrderID, c.CustomerID, h.OrderDate AS LastOrder, 
                 LAG (h.OrderDate,1) OVER (PARTITION BY c.CustomerID ORDER BY h.OrderDate) AS PreviousOrder,
		         p.LastName, p.FirstName, h.ShipMethodID,
	             RANK () OVER (PARTITION BY c.CustomerID ORDER BY h.OrderDate DESC) AS RANK
         FROM    Sales.SalesOrderHeader h JOIN Sales.Customer c
         ON      h.CustomerID = c.CustomerID         
		         JOIN Person.Person p
         ON      c.PersonID = p.BusinessEntityID)

SELECT   SalesOrderID, CustomerID, LastName, FirstName, LastOrder, PreviousOrder
FROM     CTE_Sales
WHERE    RANK = 1
ORDER BY ShipMethodID DESC, CustomerID


--------QUESTION #6--------
--Write a query that shows the amount of the purchase in the most expensive order each year, you must show which customers these orders belong to.
--Display: order date year, order number, customer's last name and first name, and the Total (UnitPrice*(1- UnitPriceDiscount)*OrderQty).

USE AdventureWorks2019
 
WITH CTE_Join
AS
        (SELECT  YEAR (s.OrderDate) AS Year, s.SalesOrderID, d.LineTotal, 
		         s.CustomerID, p.LastName, p.FirstName,
                 SUM (d.UnitPrice*(1-d.UnitPriceDiscount)*d.OrderQty) OVER (PARTITION BY s.SalesOrderID) AS Sum_Total
         FROM    Sales.SalesOrderHeader s JOIN Sales.SalesOrderDetail d
         ON      s.SalesOrderID = d.SalesOrderID
		         JOIN Sales.Customer c
		 ON      s.CustomerID = c.CustomerID
		         JOIN Person.Person p
		 ON      p.BusinessEntityID = c.PersonID),

CTE_Rank
AS
        (SELECT  DISTINCT Year, SalesOrderID, LastName, FirstName, Sum_Total AS Total,
                 DENSE_RANK () OVER(PARTITION BY Year ORDER BY Sum_Total DESC) AS Rank
         FROM    CTE_JOIN)

SELECT   Year, SalesOrderID, LastName, FirstName, Total
FROM     CTE_Rank 
WHERE    Rank = 1
ORDER BY Year 


--------QUESTION #7--------
--Write a query that shows the number of orders made in each month of the year.

USE AdventureWorks2019

SELECT   * 
FROM    (SELECT MONTH(OrderDate) AS 'Month', YEAR(OrderDate) AS 'Year', SalesOrderID 
         FROM Sales.SalesOrderHeader) 
A PIVOT (COUNT(SalesOrderID) FOR Year IN ([2011],[2012],[2013],[2014])) PIV 
ORDER BY Month


--------QUESTION #8--------
--Write a query that shows the number of orders for each month of the year and the total amount each year. 
--A line highlighting the year's summary must be presented.

USE AdventureWorks2019

WITH CTE_Sum
AS
         (SELECT  DISTINCT COUNT(h.SalesOrderID) OVER (PARTITION BY MONTH (h.OrderDate)) AS Sum_Orders,
                  YEAR (h.OrderDate) AS Year, MONTH (h.OrderDate) AS Month, 
                  SUM (d.UnitPrice*(1-d.UnitPriceDiscount)*d.OrderQty) 
				  OVER (PARTITION BY MONTH (h.OrderDate), YEAR (h.OrderDate)) AS Price
         FROM     Sales.SalesOrderHeader h JOIN Sales.SalesOrderDetail d
         ON       h.SalesOrderID = d.SalesOrderID),

CTE_Money
AS
         (SELECT  ROUND (Price,2) AS Sum_Price, Year, Month,
                  SUM (ROUND (Price,2)) OVER (PARTITION BY Year ORDER BY Month 
				  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'Money'
         FROM     CTE_Sum),

CTE_Rank
AS
         (SELECT  Year, Month, Sum_Price, Money,
				  DENSE_RANK () OVER (PARTITION BY Year ORDER BY MONEY DESC) AS RANK
         FROM     CTE_Money)

SELECT   Year, CAST (Month AS varchar) AS Month, Sum_Price, Money
FROM     CTE_Rank
UNION
SELECT   Year, 'grand_total', NULL, Money 
FROM     CTE_Rank
WHERE    RANK = 1
ORDER BY Year, Money

		 
--------QUESTION #9--------
--Write a query that shows the employees in the order they were hired in each department from the newest employee to the oldest employee.
--Display: DepartmentName, EmployeeID, FullName, employment date, seniority (months), FullName and employment date of the employee who was hired before him. 
--Display: The number of days that passed between the employment date of the employee and the previous employee.

USE AdventureWorks2019

WITH CTE_Join
AS
        (SELECT d.Name AS DepartmentName, 
                e.BusinessEntityID AS "Employee'sID",
	            p.FirstName + ' ' + p.LastName AS "Employee'sFullName", 
	            e.HireDate AS HireDate,
	            ISNULL (h.EndDate, '2021-07-31') AS Today
         FROM   HumanResources.Employee e JOIN HumanResources.EmployeeDepartmentHistory h 
         ON     e.BusinessEntityID = h.BusinessEntityID
                JOIN HumanResources.Department d
         ON     d.DepartmentID = h.DepartmentID
		        JOIN Person.Person p
		 ON     h.BusinessEntityID = p.BusinessEntityID
		 WHERE  h.EndDate IS NULL),

CTE_Lag
AS
        (SELECT DepartmentName, "Employee'sID", "Employee'sFullName", HireDate, 
                DATEDIFF (MM, HireDate, Today) AS Seniority,
		        LAG ("Employee'sFullName",1) OVER (PARTITION BY DepartmentName ORDER BY HireDate) AS PreviuseEmpName,
		        LAG (HireDate,1) OVER (PARTITION BY DepartmentName ORDER BY HireDate) AS PreviuseEmpDate,
		        ROW_NUMBER ()OVER (PARTITION BY DepartmentName ORDER BY HireDate DESC) AS ROW_NUM
         FROM   CTE_Join)

SELECT   DepartmentName, "Employee'sID", "Employee'sFullName", HireDate, Seniority,
         PreviuseEmpName, PreviuseEmpDate, DATEDIFF (DD, PreviuseEmpDate, HireDate) AS DiffDays
FROM     CTE_Lag 
ORDER BY DepartmentName, HireDate DESC


--------QUESTION #10--------
--Write a query that shows the details of employees who work in the same department and were hired on the same date. 
--The employees will be displayed as a list against each combination of receipt date and department number.

USE AdventureWorks2019

SELECT   e.HireDate AS hiredate,
		 h.DepartmentID AS departmentid,
         STRING_AGG ((CAST (e.BusinessEntityID AS nvarchar) + ' ' + p.LastName + ' ' + p.FirstName) ,', ') AS "a"
FROM     HumanResources.Employee e JOIN HumanResources.EmployeeDepartmentHistory h 
ON       e.BusinessEntityID = h.BusinessEntityID
		 JOIN Person.Person p
ON       h.BusinessEntityID = p.BusinessEntityID
WHERE    h.EndDate IS NULL
GROUP BY departmentid, hiredate
