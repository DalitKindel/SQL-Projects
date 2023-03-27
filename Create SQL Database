
------PROJECT GOAL-------
--Built a database to manage company sales information.


------Part A------ 
--Creating a database and tables with limitations. 
--Creating a database called sales and building the tables in it as they appear in the ERD diagram and table descriptions.


CREATE DATABASE Sales
GO

USE Sales 
GO

CREATE SCHEMA Person
GO
CREATE SCHEMA Purchasing
GO
CREATE SCHEMA Sales
GO

CREATE TABLE Person.Address (
       AddressID INT NOT NULL PRIMARY KEY,
       AddressLine1 NVARCHAR(60) NOT NULL,
       AddressLine2 NVARCHAR(60),
       City NVARCHAR(30) NOT NULL,
       StateProvinceID INT NOT NULL,
       PostalCode NVARCHAR(15) NOT NULL,
       SpatialLocation GEOGRAPHY,
       Rowguid UNIQUEIDENTIFIER NOT NULL,
       ModifiedDate DATETIME NOT NULL
       )

CREATE TABLE Purchasing.ShipMethod (
       ShipMethodID INT NOT NULL PRIMARY KEY,
       Name NVARCHAR(50) NOT NULL,
       ShipBase MONEY NOT NULL,
       ShipRate MONEY NOT NULL,
       Rowguid UNIQUEIDENTIFIER NOT NULL,
       ModifiedDate DATETIME NOT NULL
       )

CREATE TABLE Sales.SalesTerritory (
       TerritoryID INT NOT NULL PRIMARY KEY,
       Name NVARCHAR(50) NOT NULL,
       CountryRegionCode NVARCHAR(3) NOT NULL,
       [Group] NVARCHAR(50) NOT NULL,
       SalesYTD MONEY NOT NULL,
       SalesLastYear MONEY NOT NULL,
       CostYTD MONEY NOT NULL,
       CostLastYear MONEY NOT NULL,
       Rowguid UNIQUEIDENTIFIER NOT NULL,
       ModifiedDate DATETIME NOT NULL
       )

CREATE TABLE Sales.Customer (
       CustomerID INT NOT NULL PRIMARY KEY,
       PersonID INT,
       StoreID INT,
       TerritoryID INT FOREIGN KEY REFERENCES Sales.SalesTerritory (TerritoryID),
       Rowguid UNIQUEIDENTIFIER NOT NULL,
       ModifiedDate DATETIME NOT NULL
       )

CREATE TABLE Sales.SalesPerson (
       BusinessEntityID INT NOT NULL PRIMARY KEY,
       TerritoryID INT FOREIGN KEY REFERENCES Sales.SalesTerritory (TerritoryID),
       SalesQuota MONEY,
       Bonus MONEY NOT NULL,
       CommissionPct SMALLMONEY NOT NULL,
       SalesYTD MONEY NOT NULL,
       SalesLastYear MONEY NOT NULL,
       Rowguid UNIQUEIDENTIFIER NOT NULL,
       ModifiedDate DATETIME NOT NULL
       )

CREATE TABLE Sales.CreditCard (
       CreditCardID INT NOT NULL PRIMARY KEY,
       CardType NVARCHAR(50) NOT NULL,
       CardNumber NVARCHAR(25) NOT NULL,
       ExpMonth TINYINT NOT NULL,
       ExpYear SMALLINT NOT NULL,
       ModifiedDate DATETIME NOT NULL
       )

CREATE TABLE Sales.SpecialOfferProduct (
       SpecialOfferID INT NOT NULL,
       ProductID INT NOT NULL,
       Rowguid UNIQUEIDENTIFIER NOT NULL,
       ModifiedDate DATETIME NOT NULL,
       PRIMARY KEY (SpecialOfferID, ProductID)
       )

CREATE TABLE Sales.CurrencyRate (
       CurrencyRateID INT NOT NULL PRIMARY KEY,
       CurrencyRateDate DATETIME NOT NULL,
       FromCurrencyCode NCHAR(3) NOT NULL,
       ToCurrencyCode NCHAR(3) NOT NULL,
       AverageRate MONEY NOT NULL,
       EndOfDayRate MONEY NOT NULL,
       ModifiedDate DATETIME NOT NULL
       )

CREATE TABLE Sales.SalesOrderHeader (
       SalesOrderID INT NOT NULL PRIMARY KEY,
       RevisionNumber TINYINT NOT NULL,
       OrderDate DATETIME NOT NULL,
       DueDate DATETIME NOT NULL,
       ShipDate DATETIME,
       Status TINYINT NOT NULL,
       OnlineOrderFlag BIT NOT NULL,
       CustomerID INT NOT NULL,
       SalesPersonID INT,
       TerritoryID INT,
       BillToAddressID INT NOT NULL,
       ShipToAddressID INT NOT NULL,
       ShipMethodID INT NOT NULL,
       CreditCardID INT,
       CreditCardApprovalCode VARCHAR(15),
       CurrencyRateID INT,
       SubTotal MONEY NOT NULL,
       TaxAmt MONEY NOT NULL,
       Freight MONEY NOT NULL,
       FOREIGN KEY (CustomerID) REFERENCES Sales.Customer (CustomerID),
       FOREIGN KEY (TerritoryID) REFERENCES Sales.SalesTerritory (TerritoryID),
       FOREIGN KEY (SalesPersonID) REFERENCES Sales.SalesPerson (BusinessEntityID),
       FOREIGN KEY (CreditCardID) REFERENCES Sales.CreditCard (CreditCardID),
       FOREIGN KEY (BillToAddressID) REFERENCES Person.Address (AddressID),
       FOREIGN KEY (ShipMethodID) REFERENCES Purchasing.ShipMethod (ShipMethodID),
       FOREIGN KEY (CurrencyRateID) REFERENCES Sales.CurrencyRate (CurrencyRateID)
       )

CREATE TABLE Sales.SalesOrderDetail (
       SalesOrderID INT NOT NULL,
       SalesOrderDetailID INT NOT NULL,
       CarrierTrackingNumber NVARCHAR(25),
       OrderQty SMALLINT NOT NULL,
       ProductID INT NOT NULL,
       SpecialOfferID INT NOT NULL,
       UnitPrice MONEY NOT NULL,
       UnitPriceDiscount MONEY NOT NULL,
       Rowguid UNIQUEIDENTIFIER NOT NULL,
       ModifiedDate DATETIME NOT NULL,
       PRIMARY KEY (SalesOrderID, SalesOrderDetailID),
       FOREIGN KEY (SalesOrderID) REFERENCES Sales.SalesOrderHeader (SalesOrderID),
       FOREIGN KEY (SpecialOfferID, ProductID) REFERENCES Sales.SpecialOfferProduct (SpecialOfferID, ProductID) 
       )


------Part B------ 
--Populating tables with information. 
--Import information from the "AdventureWorks2019" database into the empty tables.


INSERT INTO Sales.Person.Address 
       SELECT *
       FROM AdventureWorks2019.Person.Address

INSERT INTO Sales.Purchasing.ShipMethod 
       SELECT *
       FROM AdventureWorks2019.Purchasing.ShipMethod

INSERT INTO Sales.Sales.SalesTerritory 
       SELECT *
       FROM AdventureWorks2019.Sales.SalesTerritory

INSERT INTO Sales.Sales.Customer 
            (CustomerID, PersonID, StoreID, TerritoryID, Rowguid, ModifiedDate)
       SELECT CustomerID, PersonID, StoreID, TerritoryID, Rowguid, ModifiedDate
       FROM AdventureWorks2019.Sales.Customer

INSERT INTO Sales.Sales.SalesPerson 
       SELECT *
       FROM AdventureWorks2019.Sales.SalesPerson

INSERT INTO Sales.Sales.CreditCard 
       SELECT *
       FROM AdventureWorks2019.Sales.CreditCard

INSERT INTO Sales.Sales.SpecialOfferProduct 
       SELECT *
       FROM AdventureWorks2019.Sales.SpecialOfferProduct

INSERT INTO Sales.Sales.CurrencyRate 
       SELECT *
       FROM AdventureWorks2019.Sales.CurrencyRate

INSERT INTO Sales.Sales.SalesOrderHeader 
            (SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, CustomerID, SalesPersonID,
            TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID,
            SubTotal, TaxAmt, Freight)
       SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, CustomerID, SalesPersonID,
            TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID,
            SubTotal, TaxAmt, Freight
       FROM AdventureWorks2019.Sales.SalesOrderHeader

INSERT INTO Sales.Sales.SalesOrderDetail 
            (SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice,
            UnitPriceDiscount, Rowguid, ModifiedDate)
       SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice,
            UnitPriceDiscount, Rowguid, ModifiedDate
       FROM AdventureWorks2019.Sales.SalesOrderDetail