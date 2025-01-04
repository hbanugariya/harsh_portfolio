
-- Create Database
CREATE DATABASE PharmaDB;
GO

-- Use the newly created database
USE PharmaDB;
GO

-- Create Clients Table
CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    ClientName NVARCHAR(100) NOT NULL,
    ContactInfo NVARCHAR(100),
    ClientType NVARCHAR(50) CHECK (ClientType IN ('Doctor', 'Pharmacy')),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Users Table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARBINARY(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Roles Table
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) UNIQUE NOT NULL
);
GO

-- Create UserRoles Table
CREATE TABLE UserRoles (
    UserID INT,
    RoleID INT,
    AssignedAt DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (UserID, RoleID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

-- Create Orders Table
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    ClientID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderAmount DECIMAL(10, 2) CHECK (OrderAmount > 0),
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);
GO

-- Create Stored Procedure for Adding New Clients
CREATE PROCEDURE AddNewClient
    @ClientName NVARCHAR(100),
    @ContactInfo NVARCHAR(100),
    @ClientType NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Clients (ClientName, ContactInfo, ClientType)
        VALUES (@ClientName, @ContactInfo, @ClientType);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Create ClientAudit Table
CREATE TABLE ClientAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ClientID INT,
    Action NVARCHAR(50),
    ActionDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);
GO

-- Create Trigger for Auditing Client Insertions
CREATE TRIGGER trgAfterClientInsert
ON Clients
AFTER INSERT
AS
BEGIN
    INSERT INTO ClientAudit (ClientID, Action)
    SELECT ClientID, 'INSERT'
    FROM Inserted;
END;
GO

-- Common Table Expression (CTE) for Client Analysis
WITH ClientCounts AS (
    SELECT ClientType, COUNT(*) AS TotalClients
    FROM Clients
    GROUP BY ClientType
)
SELECT ClientType, TotalClients
FROM ClientCounts
WHERE TotalClients > 10;
GO

-- Window Function for Running Total of Orders
SELECT ClientID, OrderDate, 
       SUM(OrderAmount) OVER (PARTITION BY ClientID ORDER BY OrderDate) AS RunningTotal
FROM Orders;
GO

-- Dynamic SQL for Flexible Queries
DECLARE @TableName NVARCHAR(50) = 'Clients';
DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'SELECT * FROM ' + QUOTENAME(@TableName) + ' WHERE ClientType = @ClientType';

EXEC sp_executesql @SQL, N'@ClientType NVARCHAR(50)', @ClientType = 'Pharmacy';
GO
