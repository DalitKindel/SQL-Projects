
--------DALIT KINDEL__SQL PROJECT---------

--------QUESTION NUMBER 1--------

USE AdventureWorks2019                

SELECT   ProductID, Name, Color, ListPrice, Size
FROM     Production.Product
WHERE    ProductID NOT IN (SELECT s.ProductID
                           FROM   Sales.SalesOrderDetail s
                           WHERE  ProductID = s.ProductID)


--------UPDATE--------

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


--------QUESTION NUMBER 2--------

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


--------QUESTION NUMBER 3--------

USE AdventureWorks2019

SELECT   DISTINCT TOP 10 c.CustomerID, p.FirstName, p.LastName, 
         COUNT (s.SalesOrderId) OVER (PARTITION BY s.CustomerID) AS CountOfOrders
FROM     Sales.Customer c JOIN Person.Person p 
ON       p.BusinessEntityID = c.PersonID
         JOIN Sales.SalesOrderHeader s 
ON       s.CustomerID = c.CustomerID
ORDER BY CountOfOrders DESC


--------QUESTION NUMBER 4--------

USE AdventureWorks2019

WITH CTE_Employee
AS
        (SELECT p.FirstName, p.LastName, e.JobTitle, e.HireDate,
	            COUNT (*) OVER(PARTITION BY e.JobTitle) AS CountOfTitle
         FROM   HumanResources.Employee e JOIN Person.Person p 
         ON     p.BusinessEntityID = e.BusinessEntityID)

SELECT   FirstName, LastName, JobTitle, HireDate, CountOfTitle 
FROM     CTE_Employee 


--------QUESTION NUMBER 5--------

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


--------QUESTION NUMBER 6--------

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


--------QUESTION NUMBER 7--------

USE AdventureWorks2019

SELECT   * 
FROM    (SELECT MONTH(OrderDate) AS 'Month', YEAR(OrderDate) AS 'Year', SalesOrderID 
         FROM Sales.SalesOrderHeader) 
A PIVOT (COUNT(SalesOrderID) FOR Year IN ([2011],[2012],[2013],[2014])) PIV 
ORDER BY Month


--------QUESTION NUMBER 8--------

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

		 
--------QUESTION NUMBER 9--------

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


--------QUESTION NUMBER 10--------

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