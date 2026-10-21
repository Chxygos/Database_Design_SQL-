-- creating a database
CREATE DATABASE OnlineBank;

--using the database created
USE OnlineBank;
GO

--creating table customers table
CREATE TABLE Customers (
CustomerID int NOT NULL PRIMARY KEY,
FirstName nvarchar (50) NOT NULL,
LastName nvarchar (50) NOT NULL,
AddressID int NOT NULL,
DOB date NOT NULL,
UserID nvarchar (50) UNIQUE NOT NULL,
PasswordHash nvarchar (255) NOT NULL,
EmailAddress nvarchar (100) UNIQUE NULL CHECK  (EmailAddress LIKE '%._%@_%._%'),
Telephone nvarchar (20) NULL);

--create the account table
CREATE TABLE  AccountProducts (
AccountID int NOT NULL PRIMARY KEY,
CustomerID int NOT NULL FOREIGN KEY (CustomerID) REFERENCES  Customers (CustomerID),
ProductName nvarchar (50) NOT NULL,
ProductType nvarchar (50) NOT NULL,
OpeningDate date NOT NULL,
AccountStatus nvarchar (50) NOT NULL,
StatusDate date NOT NULL,
LoanRef nvarchar (50) NULL,

--adding constraint
CONSTRAINT chk_product_name CHECK ( ProductName IN  
        ( 'Regular Savings', 'Standard Current', 'Business Checking', 'SME Loan', 'Student Loan',
           'Business Credit Card', 'Stocks & Shares ISA', 'Child Trust Fund')),
CONSTRAINT chk_product_type CHECK ( ProductType IN ('Savings', 'Checking', 'Loan', 'Credit Card', 'Investment')),
CONSTRAINT chk_status CHECK ( AccountStatus IN ('Active', 'Dormant', 'Closed', 'Frozen'))
)

 --creating a transaction table
 CREATE TABLE Transactions (
 TransactionID int NOT NULL  PRIMARY KEY,
 CustomerID int NOT NULL FOREIGN KEY (CustomerID)
         REFERENCES Customers (CustomerID),
 AccountID int NOT NULL  FOREIGN KEY (AccountID) 
         REFERENCES AccountProducts (AccountID),
TransactionType nvarchar (50) NOT NULL,
TransactionAmount decimal (15, 2) NOT NULL,
TransactionStatus nvarchar (50) NOT NULL,
TransactionDate datetime NOT NULL,
DueDate date,
CompletionDate datetime NULL,

 -- Constraints on the transaction table
CONSTRAINT chk_amount_positive CHECK ( TransactionAmount > 0),
CONSTRAINT chk_transaction_type CHECK ( TransactionType IN 
        ( 'Deposit', 'Withdrawal', 'Transfer',  'Payment', 'Fee', 'Interest' )),
CONSTRAINT chk_tx_status CHECK ( TransactionStatus IN 
        ('Pending', 'Completed', 'Failed', 'Cancelled')),
CONSTRAINT chk_completion_date CHECK (
        (TransactionStatus = 'Pending' AND CompletionDate IS NULL) OR
        (TransactionStatus != 'Pending' AND CompletionDate IS NOT NULL)),
CONSTRAINT chk_due_date CHECK ( DueDate IS NULL OR DueDate >= TransactionDate )
)


-- Creating Overdue table
CREATE TABLE  OverdueFee (
OverdueFeeID int NOT NULL PRIMARY KEY IDENTITY,
CustomerID int NOT NULL FOREIGN KEY (CustomerID)
         REFERENCES Customers (CustomerID),
TransactionID int NOT NULL FOREIGN KEY ( TransactionID) 
        REFERENCES Transactions (TransactionID),
 AccountID int NOT NULL  FOREIGN KEY (AccountID)
        REFERENCES AccountProducts (AccountID),
DaysOverdue int NOT NULL,
OriginalFeeAmount decimal (15, 2) NOT NULL,
TotalRepaid decimal (15, 2) NOT NULL DEFAULT 0.00,
OutstandingBal decimal (15, 2) NOT NULL,
FeeStatus nvarchar (20) NOT NULL DEFAULT 'Outstanding',
FeeCalculationDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),

-- OverdueFees Constraints
CONSTRAINT chk_days_overdue CHECK (DaysOverdue > 0),
CONSTRAINT chk_fee_amount CHECK (OriginalFeeAmount > 0),
CONSTRAINT chk_total_repaid CHECK (TotalRepaid >= 0),
CONSTRAINT chk_outstanding_balance CHECK (OutstandingBal >= 0),
CONSTRAINT chk_balance_consistency CHECK ( OutstandingBal = (OriginalFeeAmount - TotalRepaid)),
CONSTRAINT chk_repaid_not_exceed CHECK ( TotalRepaid <= OriginalFeeAmount),
CONSTRAINT chk_fee_status CHECK ( FeeStatus IN ('Outstanding', 'Partly Paid', 'Paid'))
)

-- creating the Repayment table
CREATE TABLE Repayment (
RepaymentID int NOT NULL PRIMARY KEY IDENTITY,
OverdueFeeID int NOT NULL FOREIGN KEY (OverdueFeeID) 
        REFERENCES OverdueFee (OverdueFeeID),
RepaymentDate datetime NOT NULL DEFAULT GETDATE(),
RepaymentAmount decimal (15, 2) NOT NULL,
PaymentMethod nvarchar (30) NOT NULL,
CreatedDate datetime NOT NULL DEFAULT GETDATE(),

-- Repayment Constraints
CONSTRAINT chk_repayment_amount CHECK (RepaymentAmount > 0),
CONSTRAINT chk_payment_method CHECK (PaymentMethod IN 
        ('Bank Transfer', 'Card', 'Cash', 'Check'))
)

-- Creating the address table
CREATE TABLE CustomerAddress (
AddressID int NOT NULL PRIMARY KEY,
CustomerID int NOT NULL FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),
AddressLine nvarchar (100) NOT NULL,
City nvarchar (20) NULL,
Postcode nvarchar(20) NOT NULL, 

--address Constraint
CONSTRAINT UC_Address UNIQUE (AddressLine, Postcode)
)

--Inserting records to the tables
INSERT INTO Customers (
            CustomerID, FirstName, LastName, AddressID, DOB, UserID, PasswordHash, EmailAddress, Telephone )
VALUES
( 101, 'James', 'Thompson', 101, '1985-03-15',  'jthompson01', 'pwhash01', 'j.thompson@email.com', '07700123456'),
( 102, 'Amina', 'Ahmed', 102,  '1990-11-18',  'aahmed01', 'pwhash02', 'a.ahmed@email.com', '07700123459'),
( 103, 'Fatima', 'Islam', 102, '1993-04-20',  'fislam01', 'pwhash03', 'f.islam@email.com', '07700123463'),
( 104, 'Nicole', 'Campbell', 104, '2001-01-21', 'ncampell01', 'pwhash04', 'n.campbell@email.com', '07700123465'),
( 105, 'Amara', 'Okonkwo', 105, '2005-08-25', 'aokonkwo01', 'pwhash05', 'a.okonkwo@email.com', '07700123467'),
( 106, 'Sarah', 'Wilson', 106, '2002-04-12', 'swilson01', 'pwhash06', 's.wilson@email.com', '07700123457'),
( 107, 'Oliver', 'Martinez', 107, '1998-06-19', 'omartinez01', 'pwhash07', 'o.martinez@email.com', '07700123468'),
( 108, 'Kwame', 'Osei', 108, '1994-07-17', 'kosei01', 'pwhash08', 'k.osei@email.com', '07700123466'),
( 109, 'Marcus', 'Johnson', 109, '1999-10-10', 'mjohnson01', 'pwhash09',  'm.johnson@email.com', '07700123464'),
( 110, 'Priya', 'Sharma', 110, '2001-08-13', 'psharma01', 'pwhash10', 'p.sharma@email.com', '07700123461'),
( 111, 'Lucas', 'Chidi', 111, '2006-11-05', 'lchidi01', 'pwhash11', 'l.chidi@email.com', '07700123433'),
( 112 , 'Tomi', 'Tunde', 112, '1998-03-15', 'ttunde01', 'pwhash12', 't.tunde@email.com', '07700123439')

--Viewing the record inserted
SELECT * FROM Customers

--insering records on the account/product
INSERT INTO AccountProducts (AccountID, CustomerID, ProductName, ProductType, OpeningDate, AccountStatus, StatusDate, LoanRef ) 
VALUES
        (10, 101, 'Business Checking', 'Checking', '2019-06-20', 'Active', '2024-01-15', NULL),
        (11, 101, 'SME Loan', 'Loan', '2023-02-10', 'Active', '2024-01-15', 'LN2000'),
        (12, 101, 'Stocks & Shares ISA', 'Investment', '2023-01-10', 'Active', '2024-01-15', NULL),
        (13, 102, 'Regular Savings', 'Savings', '2021-07-22', 'Frozen', '2024-01-16', NULL),
        (14, 102, 'Business Credit Card', 'Credit Card', '2022-05-15', 'Active', '2024-01-16', NULL),
        (15, 102, 'Student Loan', 'Loan', '2023-05-20', 'Active', '2024-01-16', 'LN2006'),
        (16, 103, 'Regular Savings', 'Savings', '2019-11-05', 'Active', '2024-01-17', NULL),
        (17, 103, 'Standard Current', 'Checking', '2018-09-12', 'Active', '2024-01-17', NULL),
        (18, 103, 'SME Loan', 'Loan', '2021-04-20', 'Active', '2024-01-17', 'LN2001'),
        (19, 104, 'Business Credit Card', 'Credit Card', '2022-11-20', 'Active', '2024-01-18', NULL),
        (20, 104, 'Regular Savings', 'Savings', '2022-03-01', 'Active', '2024-01-18', NULL),
        (21, 104, 'Standard Current', 'Checking', '2020-06-15', 'Dormant', '2023-08-20', NULL),
        (22, 104, 'Student Loan', 'Loan', '2023-03-15', 'Closed', '2024-02-18', 'LN2008'),
        (23, 105, 'Regular Savings', 'Savings', '2020-02-14', 'Active', '2024-01-19', NULL),
        (24, 105, 'Student Loan', 'Loan', '2022-09-01', 'Active', '2024-01-19', 'LN2002'),
        (25, 106, 'Regular Savings', 'Savings', '2023-05-10', 'Active', '2024-01-20', NULL),
        (26, 106, 'Business Credit Card', 'Credit Card', '2021-10-25', 'Frozen', '2024-01-20', NULL),
        (27, 107, 'Business Checking', 'Checking', '2020-03-22', 'Active', '2023-12-01', NULL),
        (28, 107, 'SME Loan', 'Loan', '2023-06-15', 'Active', '2024-01-21', 'LN2003'),
        (29, 108, 'Standard Current', 'Checking', '2021-04-05', 'Active', '2024-01-22', NULL),
        (30, 108, 'Child Trust Fund', 'Investment', '2023-02-15', 'Active', '2024-02-02', NULL),
        (31, 109, 'Regular Savings', 'Savings', '2020-11-20', 'Active', '2024-01-23', NULL),
        (32, 109, 'Standard Current', 'Checking', '2019-05-15', 'Active', '2024-01-23', NULL),
        (33, 109, 'Business Credit Card', 'Credit Card', '2022-03-10', 'Closed', '2023-11-30', NULL),
        (34, 110, 'Standard Current', 'Checking', '2020-02-18', 'Active', '2024-01-24', NULL),
        (35, 110, 'Student Loan', 'Loan', '2020-10-12', 'Active', '2024-01-24', 'LN2004'),
        (36, 110, 'SME Loan', 'Loan', '2023-06-15', 'Active', '2024-02-15', 'LN2014'),
        (37, 111, 'Stocks & Shares ISA', 'Investment', '2022-06-20', 'Active', '2024-01-25', NULL),
        (38, 111, 'Standard Current', 'Checking', '2019-12-10', 'Active', '2024-01-25', NULL),
        (39, 112, 'Regular Savings', 'Savings', '2020-07-15', 'Dormant', '2023-06-30', NULL),
        (40, 112, 'Business Checking', 'Checking', '2021-01-20', 'Active', '2024-01-26', NULL),
        (41, 112, 'Child Trust Fund', 'Investment', '2023-03-15', 'Active', '2024-01-26', NULL);
 
 SELECT * FROM AccountProducts

 -- Insert diverse transactions for all customers and accounts
INSERT INTO Transactions (TransactionID, CustomerID, AccountID, TransactionType, TransactionAmount, 
                                                TransactionStatus, TransactionDate, DueDate, CompletionDate) 
VALUES
    (301, 101, 10, 'Withdrawal', 1000.00, 'Completed', '2024-01-20 14:20:00', NULL, '2024-01-20 14:25:00'),
    (302, 101, 11,  'Payment', 2500.00, 'Pending', '2023-02-10 00:00:00', '2026-04-20', NULL),
    (303, 102, 14, 'Payment', 10000.00, 'Completed', '2024-01-12 10:00:00', NULL, '2024-01-12 10:05:00'),
    (304, 102, 15,'Payment', 3000.00, 'Pending', '2024-01-28 16:20:00', '2025-01-28 16:20:00', NULL),
    (305, 103, 16,  'Deposit', 3000.00, 'Completed', '2024-01-11 08:15:00', NULL, '2024-01-11 08:20:00'),
    (306, 103, 17, 'Transfer', 1500.00, 'Completed', '2024-01-24 14:30:00', NULL, '2024-01-24 14:35:00'),
    (307, 104, 21, 'Withdrawal', 100.00, 'Failed', '2024-01-16 14:00:00', NULL, '2024-01-16 14:05:00'),
    (308, 104, 22,  'Payment', 1500.00, 'Completed', '2024-01-31 16:30:00', NULL, '2024-01-31 16:35:00'),
    (309, 105, 24, 'Payment', 450.00, 'Pending', '2024-02-21 00:00:00', '2024-03-21', NULL),
    (310, 106, 25, 'Withdrawal', 2000.00, 'Completed', '2024-01-26 12:15:00', NULL, '2024-01-26 12:20:00'),
    (311, 107, 28,  'Payment', 800.00, 'Pending', '2024-02-19 00:00:00', '2026-03-19', NULL),
    (312, 108, 29, 'Transfer', 3000.00, 'Completed', '2024-01-22 11:00:00', NULL, '2024-01-22 11:05:00'),
    (313, 108, 30, 'Interest', 35.20, 'Completed', '2024-02-01 00:00:00', NULL, '2024-02-01 00:05:00'),
    (314, 111, 38,  'Deposit', 5000.00, 'Completed', '2024-01-17 09:30:00', NULL, '2024-01-17 09:35:00'),
    (315, 112, 40, 'Deposit', 6000.00, 'Completed', '2024-01-08 06:45:00', NULL, '2024-01-08 06:50:00'),
    (316, 112, 41, 'Payment', 1200.00, 'Pending', '2024-02-25 00:00:00', '2024-03-25', NULL)

SELECT * FROM Transactions


--  generating OverdueFee records automatically using the transactions table
INSERT INTO OverdueFee (
                CustomerID, TransactionID, AccountID, DaysOverdue, OriginalFeeAmount, 
                TotalRepaid, OutstandingBal, FeeStatus, FeeCalculationDate)
SELECT 
    t.CustomerID, t.TransactionID, t.AccountID,
    DATEDIFF(DAY, t.DueDate, CAST(GETDATE() AS DATE)) AS DaysOverdue,
    CASE 
        WHEN DATEDIFF(DAY, t.DueDate, CAST(GETDATE() AS DATE)) <= 10 THEN 25.00
        WHEN DATEDIFF(DAY, t.DueDate, CAST(GETDATE() AS DATE)) <= 30 THEN 50.00
        ELSE 100.00
    END AS OriginalFeeAmount,
    0.00 AS TotalRepaid,
    CASE 
        WHEN DATEDIFF(DAY, t.DueDate, CAST(GETDATE() AS DATE)) <= 10 THEN 25.00
        WHEN DATEDIFF(DAY, t.DueDate, CAST(GETDATE() AS DATE)) <= 30 THEN 50.00
        ELSE 100.00
    END AS OutstandingBal,
    'Outstanding' AS FeeStatus,
    CAST(GETDATE() AS DATE) AS FeeCalculationDate
FROM Transactions t
WHERE t.TransactionStatus = 'Pending'
  AND t.DueDate < CAST(GETDATE() AS DATE)
  AND t.AccountID IN (
    SELECT AccountID FROM AccountProducts WHERE ProductType IN ('Loan', 'Credit Card'))
    AND t.TransactionID NOT IN (
    SELECT TransactionID FROM OverdueFee )

-- Verify the inserts
SELECT * FROM OverdueFee;

--inserting records to the repayment table
INSERT INTO Repayment( OverdueFeeID, RepaymentDate, RepaymentAmount, PaymentMethod, CreatedDate ) 
VALUES
     
        (1, '2025-01-28 16:20:00', 3000.00, 'Bank Transfer', '2025-01-28 16:20:00'),
        (2, '2024-03-21 00:00:00', 450.00, 'Bank Transfer', '2024-03-21 08:00:00'),
        (3, '2024-03-19 00:00:00', 800.00, 'Bank Transfer', '2024-03-19 08:00:00')

--verifying the inserted repayment
SELECT* FROM Repayment

--inserting records to the customers address
INSERT INTO CustomerAddress (AddressID, CustomerID, AddressLine, City, Postcode)
VALUES
        (101, 101, '42 Oxford Street', 'London', 'W1D 1AN'),
        (102, 102, '10 Downing Street', 'London', 'SW1A 2AA'),
        (103, 103, '221B Baker Street', 'London', 'NW1 6XE'),
        (104, 104, '1 Manchester Square', 'Manchester', 'M1 1AD'),
        (105, 105, '50 Deansgate', 'Manchester', 'M3 2BA'),
        (106, 106, '113 Princess Street', 'Manchester', 'M1 6JB'),
        (107, 107, '1 The Strand', 'Birmingham', 'B1 1AA'),
        (108, 108, '100 Colmore Row', 'Birmingham', 'B3 2EQ'),
        (109, 109, '25 Broad Street', 'Birmingham', 'B1 2HF'),
        (110, 110, '1 Whitley Street', 'Leeds', 'LS1 1BA'),
        (111, 111, '67 City Square', 'Leeds', 'LS1 1NA'),
        (112, 112, '15 Park Row', 'Leeds', 'LS1 5NH')

--Viewing the customer address table
SELECT * FROM CustomerAddress

--Stored procedure for searching account or product
CREATE PROCEDURE sp_SearchAccountsByProductName
    @ProductName NVARCHAR(50)
AS
BEGIN
    SELECT 
        ap.AccountID, ap.CustomerID, c.FirstName, c.LastName, ap.ProductName,
        ap.ProductType, ap.OpeningDate, ap.AccountStatus, ap.StatusDate, ap.LoanRef
    FROM AccountProducts ap
    INNER JOIN Customers c 
        ON ap.CustomerID = c.CustomerID
    WHERE ap.ProductName = @ProductName
    ORDER BY ap.OpeningDate DESC;
END;

-- EXECUTE: Search for SME Loans
EXEC sp_SearchAccountsByProductName @ProductName = 'SME Loan';


-- loan/credit due in 5days
CREATE PROCEDURE sp_PaymentsDueSoon
    @DaysThreshold INT = 5 AS
BEGIN
    SELECT 
        t.TransactionID, c.CustomerID, c.FirstName, c.LastName, ap.AccountID, 
        ap.ProductName, ap.ProductType, t.TransactionAmount, t.TransactionType, t.DueDate,
        DATEDIFF(DAY, CAST(GETDATE() AS DATE), t.DueDate) AS DaysUntilDue,
        t.TransactionStatus
    FROM Transactions t
    INNER JOIN Customers c 
        ON t.CustomerID = c.CustomerID
    INNER JOIN AccountProducts ap 
        ON t.AccountID = ap.AccountID
    WHERE t.TransactionStatus = 'Pending'
      AND ap.ProductType IN ('Loan', 'Credit Card')
      AND t.DueDate IS NOT NULL
      AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), t.DueDate) BETWEEN 0 AND @DaysThreshold
    ORDER BY t.DueDate ASC;
END;

-- EXECUTE: Get payments due in next 5 days
EXEC sp_PaymentsDueSoon @DaysThreshold = 5;


-- inserting a new customer 
CREATE PROCEDURE sp_InsertNewCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @DOB DATE,
    @UserID NVARCHAR(50),
    @PasswordHash NVARCHAR(255),
    @EmailAddress NVARCHAR(100),
    @Telephone NVARCHAR(20),
    @AddressLine NVARCHAR(100),
    @City NVARCHAR(20),
    @Postcode NVARCHAR(20)
AS
BEGIN
    DECLARE @CustomerID INT;
    DECLARE @AddressID INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Check if UserID already exists
        IF EXISTS (SELECT 1 FROM Customers WHERE UserID = @UserID)
        BEGIN
            THROW 50001, 'UserID already exists', 1;
        END;
        -- Check if Email already exists
        IF @EmailAddress IS NOT NULL AND EXISTS (SELECT 1 FROM Customers WHERE EmailAddress = @EmailAddress)
        BEGIN
            THROW 50002, 'Email address already in use', 1;
        END;
        -- Generate new CustomerID and AddressID (assuming sequential)
        SET @CustomerID = (SELECT ISNULL(MAX(CustomerID), 100) + 1 FROM Customers);
        SET @AddressID = (SELECT ISNULL(MAX(AddressID), 210) + 1 FROM CustomerAddress);
        -- Insert Customer and Address
        INSERT INTO Customers ( CustomerID, FirstName, LastName, AddressID, DOB, UserID, PasswordHash, EmailAddress, Telephone)
        VALUES ( @CustomerID, @FirstName, @LastName, @AddressID, @DOB, @UserID, @PasswordHash, @EmailAddress, @Telephone);
        INSERT INTO CustomerAddress (AddressID, CustomerID, AddressLine, City, Postcode)
        VALUES ( @AddressID, @CustomerID, @AddressLine, @City, @Postcode);
        COMMIT TRANSACTION;
        SELECT 'Customer inserted successfully' AS Message, 
                        @CustomerID AS NewCustomerID, 
                        @AddressID AS NewAddressID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- EXECUTE: Insert new customer
EXEC sp_InsertNewCustomer
    @FirstName = 'David',
    @LastName = 'Brown',
    @DOB = '1999-05-14',
    @UserID = 'dbrown01',
    @PasswordHash = 'pwhash13',
    @EmailAddress = 'd.brown@email.com',
    @Telephone = '07700123470',
    @AddressLine = '25 Park Lane',
    @City = 'Liverpool',
    @Postcode = 'L1 1AA'


-- updating customer details
CREATE PROCEDURE sp_UpdateCustomerDetails
    @CustomerID INT,
    @FirstName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @EmailAddress NVARCHAR(100) = NULL,
    @Telephone NVARCHAR(20) = NULL,
    @AddressLine NVARCHAR(100) = NULL,
    @City NVARCHAR(20) = NULL,
    @Postcode NVARCHAR(20) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;  
        -- Check if customer exists
        IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = @CustomerID)
        BEGIN
            THROW 50003, 'Customer does not exist', 1;
        END;
        -- Update Customer details if provided
        IF @FirstName IS NOT NULL OR @LastName IS NOT NULL OR 
           @EmailAddress IS NOT NULL OR @Telephone IS NOT NULL
        BEGIN
            UPDATE Customers
            SET 
                FirstName = ISNULL(@FirstName, FirstName),
                LastName = ISNULL(@LastName, LastName),
                EmailAddress = ISNULL(@EmailAddress, EmailAddress),
                Telephone = ISNULL(@Telephone, Telephone)
            WHERE CustomerID = @CustomerID;
        END;
        -- Update Address details if provided
        IF @AddressLine IS NOT NULL OR 
            @City IS NOT NULL OR 
            @Postcode IS NOT NULL
        BEGIN
            UPDATE CustomerAddress
            SET 
                AddressLine = ISNULL(@AddressLine, AddressLine),
                City = ISNULL(@City, City),
                Postcode = ISNULL(@Postcode, Postcode)
            WHERE CustomerID = @CustomerID;
        END;
        COMMIT TRANSACTION;
        SELECT 'Customer details updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- EXECUTE: Update customer details
EXEC sp_UpdateCustomerDetails
    @CustomerID = 101,
    @EmailAddress = 'j.thompson.new@email.com',
    @Telephone = '07700999999';

 -- view Showing all transactions with associated overdue fees
CREATE VIEW vw_AllTransactionsWithOverdueFees
AS
SELECT 
    t.TransactionID,
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    ap.AccountID,
    ap.ProductName,
    ap.ProductType,
    t.TransactionType,
    t.TransactionAmount,
    t.TransactionStatus,
    t.TransactionDate,
    t.DueDate,
    t.CompletionDate,
    CASE 
        WHEN od.OverdueFeeID IS NOT NULL THEN od.OriginalFeeAmount
        ELSE 0.00
    END AS OverdueFeeAmount,
    CASE 
        WHEN od.OverdueFeeID IS NOT NULL THEN od.OutstandingBal
        ELSE 0.00
    END AS OutstandingFeeBalance,
    CASE 
        WHEN od.OverdueFeeID IS NOT NULL THEN od.FeeStatus
        ELSE 'Completed'
    END AS FeeStatus,
    CASE 
        WHEN od.OverdueFeeID IS NOT NULL THEN od.DaysOverdue
        ELSE 0
    END AS DaysOverdue,
    (t.TransactionAmount + ISNULL(od.OutstandingBal, 0.00)) AS TotalOutstanding
FROM Transactions t
INNER JOIN Customers c ON t.CustomerID = c.CustomerID
INNER JOIN AccountProducts ap ON t.AccountID = ap.AccountID
LEFT JOIN OverdueFee od ON t.TransactionID = od.TransactionID;
GO

-- QUERY: View all transactions with overdue fees
SELECT * FROM vw_AllTransactionsWithOverdueFees
ORDER BY TransactionDate DESC;
GO

-- TRIGGER - Auto update the loan/credit card status on completed payment
-- When all scheduled payments for a Loan/Credit Card are completed
--  Account status changes from 'Active' to 'Closed'
-- StatusDate is updated to the date of final payment
-- Prevents manual closure until all payments are made
CREATE OR ALTER TRIGGER trg_UpdateAccountStatusOnFinalPayment
ON Transactions
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ap
    SET 
        ap.AccountStatus = 'Closed',
        ap.StatusDate = CAST(GETDATE() AS DATE)
    FROM AccountProducts ap
    INNER JOIN inserted i
        ON ap.AccountID = i.AccountID
    INNER JOIN deleted d
        ON i.TransactionID = d.TransactionID
    WHERE i.TransactionStatus = 'Completed'
      AND d.TransactionStatus = 'Pending'
      AND i.TransactionType = 'Payment'
      AND ap.ProductType IN ('Loan', 'Credit Card')
      AND ap.AccountStatus = 'Active'
      AND NOT EXISTS (
            SELECT 1 FROM Transactions t
            WHERE t.AccountID = ap.AccountID
              AND t.TransactionType = 'Payment'
              AND t.TransactionStatus = 'Pending')
      AND NOT EXISTS (
            SELECT 1 FROM OverdueFee od
            WHERE od.AccountID = ap.AccountID
              AND od.OutstandingBal > 0
      );
END;
GO

 --creating a function to return customers that paid 50% less overdue amount
CREATE OR ALTER FUNCTION fn_CustomersPaidLessThan50Percent()
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.CustomerID,
        c.FirstName,
        c.LastName,
        COUNT(od.OverdueFeeID) AS OverdueFeeCount,
        SUM(od.OriginalFeeAmount) AS TotalOriginalFees,
        SUM(od.TotalRepaid) AS TotalRepaid,
        SUM(od.OutstandingBal) AS TotalOutstandingBalance
    FROM Customers c
    INNER JOIN OverdueFee od
        ON c.CustomerID = od.CustomerID
    GROUP BY
        c.CustomerID,
        c.FirstName,
        c.LastName
    HAVING SUM(od.TotalRepaid) < 0.5 * SUM(od.OriginalFeeAmount)
);
GO

--calling the function
SELECT *
FROM fn_CustomersPaidLessThan50Percent();

-- demonstrating the workability
--stored procedure of the bank search
EXEC sp_SearchAccountsByProductName @ProductName = 'Regular Savings';
EXEC sp_SearchAccountsByProductName @ProductName = 'Standard Current';


--  Get payments due in next 30 and 365 days
EXEC sp_PaymentsDueSoon @DaysThreshold = 30;
EXEC sp_PaymentsDueSoon @DaysThreshold = 365;

--inserting a new customer
EXEC sp_InsertNewCustomer
    @FirstName = 'Taiwo',
    @LastName = 'Ayo',
    @DOB = '2001-12-09',
    @UserID = 'tayo01',
    @PasswordHash = 'pwhash14',
    @EmailAddress = 't.ayo@email.com',
    @Telephone = '07700475481',
    @AddressLine = '25 Water Lane',
    @City = 'Sunderland',
    @Postcode = 'S1 1TB'

EXEC sp_InsertNewCustomer
    @FirstName = 'Samuel',
    @LastName = 'Ben',
    @DOB = '2000-06-01',
    @UserID = 'sben01',
    @PasswordHash = 'pwhash15',
    @EmailAddress = 's.ben@email.com',
    @Telephone = '077049409470',
    @AddressLine = '16 Victoria Street',
    @City = 'London',
    @Postcode = 'L2 7SA'

--Update customer details
EXEC sp_UpdateCustomerDetails
    @CustomerID = 114,
    @FirstName = 'Justice',
    @EmailAddress = 'j.ayo@email.com',
    @Telephone = '07700999999';

EXEC sp_UpdateCustomerDetails
    @CustomerID = 115,
    @FirstName = 'Jude',
    @EmailAddress = 'j.ben@email.com',
    @Telephone = '07700999999';

SELECT * FROM Customers
WHERE CustomerID IN (114, 115)

--calling the function
SELECT *
FROM fn_CustomersPaidLessThan50Percent();

---testing trigger on customer id 302 
SELECT * 
FROM Transactions
WHERE TransactionID = 302

--fire trigger
UPDATE Transactions
SET 
    TransactionStatus = 'Completed',
    CompletionDate = GETDATE()
WHERE TransactionID = 302;

--checking status (closed)
SELECT *
FROM AccountProducts
WHERE AccountID = 11

-- View all transactions with overdue fees
SELECT * FROM vw_AllTransactionsWithOverdueFees
ORDER BY TransactionDate DESC;

--creating a procedure to locate domant account
CREATE PROCEDURE usp_AnalyzeDormantAccounts
    @DormantMonths INT
AS
BEGIN
    SELECT 
        ap.AccountID, c.CustomerID, c.FirstName + ' ' + c.LastName AS CustomerName,
         c.EmailAddress, ap.ProductName, ap.ProductType, ap.AccountStatus, ap.StatusDate,
        MAX(t.TransactionDate) AS LastTransactionDate,
        DATEDIFF(MONTH, ISNULL(MAX(t.TransactionDate), ap.OpeningDate), 
        CAST(GETDATE() AS DATE)) AS MonthsSinceLastTransaction,
        COUNT(t.TransactionID) AS LifetimeTransactionCount
    FROM AccountProducts ap
    INNER JOIN Customers c
        ON ap.CustomerID = c.CustomerID
    LEFT JOIN Transactions t
        ON ap.AccountID = t.AccountID
    GROUP BY
        ap.AccountID,
        c.CustomerID,
        c.FirstName,
        c.LastName,
        c.EmailAddress,
        ap.ProductName,
        ap.ProductType,
        ap.AccountStatus,
        ap.StatusDate,
        ap.OpeningDate
    HAVING ap.AccountStatus = 'Dormant'
       OR (ap.AccountStatus = 'Active'
           AND DATEDIFF(MONTH, ISNULL(MAX(t.TransactionDate), ap.OpeningDate), 
           CAST(GETDATE() AS DATE)) >= @DormantMonths)
    ORDER BY LastTransactionDate ASC;
END;
--executing the procedure for dormant account
EXEC usp_AnalyzeDormantAccounts @DormantMonths  = 12


--creating a procedure to update transactions status
CREATE PROCEDURE sp_CompletePaymentSafely
    @TransactionID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Lock the transaction row before checking and updating it
        IF NOT EXISTS (
            SELECT 1
            FROM Transactions WITH (UPDLOCK, HOLDLOCK)
            WHERE TransactionID = @TransactionID
              AND TransactionStatus = 'Pending')
        BEGIN
            RAISERROR('Pending transaction not found or already processed.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        UPDATE Transactions
        SET
            TransactionStatus = 'Completed',
            CompletionDate = GETDATE()
        WHERE TransactionID = @TransactionID
          AND TransactionStatus = 'Pending';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

--executing update status procedure
EXEC sp_CompletePaymentSafely @TransactionID = 309

-- non clustered index
CREATE NONCLUSTERED INDEX idx_AccountProducts_ProductName
ON AccountProducts(ProductName);
GO

CREATE NONCLUSTERED INDEX idx_Transactions_DueDate
ON Transactions(DueDate);
GO

