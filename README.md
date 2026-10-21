# Database_Design_SQL-
A Design and Implementation of an Online Banking Database In 3NF

**Technologies:** Microsoft SQL Server · T-SQL · SQL Server Management Studio (SSMS) · Relational Database Design · Third Normal Form (3NF)

## Project overview

This project designs and implements a relational database for an online banking environment. The objective is to manage customer profiles, banking accounts and products, financial transactions, overdue fees, and repayments while supporting data integrity and consistent database operations.

I used a **top-down database design approach**, created the `OnlineBank` database in **Microsoft SQL Server**, and implemented database objects using **Transact-SQL (T-SQL)**. The work focuses on practical database engineering, business rules, and operational reporting rather than a customer-facing online banking website.

## Business problem

Online banking systems need reliable, structured records across multiple connected activities. Poorly designed databases can introduce duplicated customer information, inconsistent transaction states, difficulties monitoring repayment obligations, and inefficient reporting.

The design addresses these needs through relational modelling, normalization, appropriate SQL data types and constraints, reusable database objects, and reporting queries.

## Project objectives

- Design a relational banking database in **Third Normal Form (3NF)** to reduce redundancy.
- Model customer, account, transaction, overdue-fee, and repayment relationships.
- Apply primary keys, foreign keys, uniqueness rules, and validation constraints.
- Write parameterized stored procedures for banking administration and monitoring.
- Use a view to combine transactions with associated overdue-fee information.
- Automate account-status logic through a database trigger.
- Use a table-valued function to identify customers who have repaid less than 50% of overdue-fee amounts.
- Address performance, concurrency, security, and backup/recovery considerations.

**Relationship summary:** One customer can have multiple banking products, transactions and addresses. Banking products have transactions; overdue fees link to relevant customers, accounts and transactions; repayment entries link to overdue fees.


## Data modelling and integrity

The relational model applies:

- **Primary keys** to uniquely identify records.
- **Foreign keys** to link related tables.
- **`CHECK` constraints** to validate permitted product types, statuses, transaction types and positive amounts.
- **`UNIQUE` constraints** where distinct values are required.
- **`DECIMAL(15,2)`** for financial transaction and repayment amounts in the documented schema.
- **`DATE` / `DATETIME`** types for relevant calendar dates and events.

The banking product types supported in the design are **Savings, Checking, Loan, Credit Card, and Investment**. Product statuses include **Active, Dormant, Closed, and Frozen**. Transaction statuses include **Pending, Completed, Failed, and Cancelled**.

Separating customer addresses into a related table is one of the modelling choices used to support the documented 3NF design.

## Core SQL features implemented

### 1. Parameterized stored procedures

The project documents procedures to:

1. **Search banking accounts/products by name**, returning relevant customer and account information.
2. **Identify upcoming loan and credit-card payments** using a configurable days-to-due threshold (with a five-day example).
3. **Insert new customers** and their associated address information.
4. **Update existing customer details**.
5. **Find dormant or inactive accounts**, using a configurable number of months without activity.
6. **Update transaction statuses** with concurrency considerations.

### 2. Transaction and overdue-fee reporting view

A SQL view combines `Transactions`, `Customers`, `AccountProducts`, and `OverdueFee` records. The design uses a **`LEFT JOIN`** so transactions without an overdue fee can still appear in the result.

**Potential business value:** A consolidated view of transaction activity and associated fee exposure for monitoring and reporting.

### 3. Account closure trigger

A trigger is designed to update a **Loan** or **Credit Card** product from **Active** to **Closed** when the relevant final pending payment is completed and the documented settlement conditions are satisfied.

This enforces a banking business rule at the database level rather than depending entirely on manual account maintenance.

### 4. Repayment-monitoring function

A **table-valued user-defined function** identifies customers whose aggregate repayments are **less than 50% of their overdue-fee amounts**, returning overdue, repaid, and outstanding information.

**Potential business value:** Highlighting under-repaid obligations for collections or risk review.

### 5. Indexing and concurrency

The project includes **nonclustered indexes** on product names and payment due dates to support frequent lookup queries. It also discusses locking/concurrency control when updating transaction statuses to reduce conflicting changes.

## Implementation workflow

1. Identify business requirements, entities, attributes and relationships.
2. Design the relational schema and normalize it to 3NF.
3. Create the `OnlineBank` database and six tables in SQL Server.
4. Define keys, relationships, SQL data types and constraints.
5. Populate tables with demonstration records.
6. Create and execute stored procedures, views, functions and triggers.
7. Test parameter changes, transaction updates, and account-status behavior.
8. Document performance, integrity, concurrency, security and recovery considerations.

## Security and responsible data use

The database design discusses password hashing, data integrity, access control concerns, and SQL Server backup/restore practices. The demonstration dataset uses **placeholder password-hash strings**, which are **not actual securely generated hashes**.

**Note:** This is a learning and portfolio project, not production banking software which uses synthetic and non-sensitive data.

## Future enhancement: interactive Streamlit dashboard
