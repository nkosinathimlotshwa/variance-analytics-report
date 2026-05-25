-- ============================================================
-- 1. SET DATABASE CONTEXT
-- ============================================================
USE ShopInDoor_DWH;
GO

-- ============================================================
-- 2. DDL SCRIPT : CREATE STAGING SILVER TABLES (NVARCHAR)
-- ============================================================

-- ── ERP_Sales ───────────────────────────────────────────────
IF OBJECT_ID('silver.ERP_Sales', 'U') IS NOT NULL
    DROP TABLE silver.ERP_Sales;
GO

CREATE TABLE silver.ERP_Sales (
    DeliveryDate        NVARCHAR(50),
    OrderDate           NVARCHAR(50),
    OrderNumber         NVARCHAR(50),
    Quantity            NVARCHAR(50),
    UnitCost            NVARCHAR(50),
    UnitDiscount        NVARCHAR(50),
    UnitPrice           NVARCHAR(50),
    NetPrice            NVARCHAR(50),
    Continent           NVARCHAR(50),  -- Changed from CustomerContinent to match later ALTER script
    CustomerRegion      NVARCHAR(50),
    CustomerType        NVARCHAR(50),
    CustomerKey         NVARCHAR(50),
    CustomerName        NVARCHAR(100),
    ProductCategory     NVARCHAR(50),
    Product             NVARCHAR(100),
    ProductKey          NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- ── HFM_Budget ──────────────────────────────────────────────
IF OBJECT_ID('silver.HFM_Budget', 'U') IS NOT NULL
    DROP TABLE silver.HFM_Budget;
GO

CREATE TABLE silver.HFM_Budget (
    Account             NVARCHAR(50),   
    Country             NVARCHAR(50),   
    Product             NVARCHAR(100),  
    Jan_LC              NVARCHAR(50),   
    Feb_LC              NVARCHAR(50),   
    Mar_LC              NVARCHAR(50),   
    Apr_LC              NVARCHAR(50),   
    May_LC              NVARCHAR(50),   
    Jun_LC              NVARCHAR(50),   
    Jul_LC              NVARCHAR(50),   
    Aug_LC              NVARCHAR(50),   
    Sep_LC              NVARCHAR(50),   
    Oct_LC              NVARCHAR(50),   
    Nov_LC              NVARCHAR(50),   
    Dec_LC              NVARCHAR(50),   
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================
-- 3. DATA POPULATION (BRONZE TO SILVER)
-- ============================================================

-- ── Insert ERP_Sales ─────────────────────────────────────────
INSERT INTO silver.ERP_Sales (
    DeliveryDate,
    OrderDate,
    OrderNumber,
    Quantity,
    UnitCost,
    UnitDiscount,
    UnitPrice,
    NetPrice,
    Continent,
    CustomerRegion,
    CustomerType,
    CustomerKey,
    CustomerName,
    ProductCategory,
    Product,
    ProductKey
)
SELECT
    CAST([Delivery Date]        AS NVARCHAR(50)),
    CAST([Order Date]           AS NVARCHAR(50)),
    CAST([Order Number]         AS NVARCHAR(50)),
    CAST([Quantity]             AS NVARCHAR(50)),
    CAST([Unit Cost]            AS NVARCHAR(50)),
    CAST([Unit Discount]        AS NVARCHAR(50)),
    CAST([Unit Price]           AS NVARCHAR(50)),
    CAST([Net Price]            AS NVARCHAR(50)),
    CAST([Customer - Continent] AS NVARCHAR(50)),
    CAST([Customer - Region]    AS NVARCHAR(50)),
    CAST([Customer Type]        AS NVARCHAR(50)),
    CAST([CustomerKey]          AS NVARCHAR(50)),
    CAST([Customer name]        AS NVARCHAR(100)),
    CAST([Product category]     AS NVARCHAR(50)),
    CAST([Product]              AS NVARCHAR(100)),
    CAST([ProductKey]           AS NVARCHAR(50))
FROM bronze.ERP_Sales;
GO

-- ── Insert HFM_Budget ────────────────────────────────────────
INSERT INTO silver.HFM_Budget (
    Account,
    Country,
    Product,
    Jan_LC,
    Feb_LC,
    Mar_LC,
    Apr_LC,
    May_LC,
    Jun_LC,
    Jul_LC,
    Aug_LC,
    Sep_LC,
    Oct_LC,
    Nov_LC,
    Dec_LC
)
SELECT
    CAST([Unnamed: 0]  AS NVARCHAR(50)),
    CAST([Unnamed: 1]  AS NVARCHAR(50)),
    CAST([Unnamed: 2]  AS NVARCHAR(100)),
    CAST([Local_]      AS NVARCHAR(50)),
    CAST([Local_.1]    AS NVARCHAR(50)),
    CAST([Local_.2]    AS NVARCHAR(50)),
    CAST([Local_.3]    AS NVARCHAR(50)),
    CAST([Local_.4]    AS NVARCHAR(50)),
    CAST([Local_.5]    AS NVARCHAR(50)),
    CAST([Local_.6]    AS NVARCHAR(50)),
    CAST([Local_.7]    AS NVARCHAR(50)),
    CAST([Local_.8]    AS NVARCHAR(50)),
    CAST([Local_.9]    AS NVARCHAR(50)),
    CAST([Local_.10]   AS NVARCHAR(50)),
    CAST([Local_.11]   AS NVARCHAR(50))
FROM bronze.HFM_Budget
WHERE [Unnamed: 0] IS NOT NULL
AND CAST([Unnamed: 0] AS NVARCHAR(50)) NOT IN ('nan', 'RptCur', 'FY20', 'Budget', 'Final', 'Jan');
GO

-- ============================================================
-- 4. RESTRUCTURE AND CLEAN DATA
-- ============================================================

-- ── Rename Columns ───────────────────────────────────────────
EXEC sp_rename 'silver.ERP_Sales.Product', 'ProductName', 'COLUMN';
EXEC sp_rename 'silver.ERP_Sales.CustomerRegion', 'Country', 'COLUMN';
GO

-- ── Clean and Convert Serial Dates to Proper Date String Format ──
UPDATE silver.ERP_Sales
SET 
    OrderDate = CONVERT(NVARCHAR(50), DATEADD(DAY, CAST(OrderDate AS INT), '1899-12-30'), 120),
    DeliveryDate = CONVERT(NVARCHAR(50), DATEADD(DAY, CAST(DeliveryDate AS INT), '1899-12-30'), 120);
GO

-- ============================================================
-- 5. ALTER DATA TYPES TO FINAL TARGET STATE
-- ============================================================

-- ── Decimal columns ──────────────────────────────────────────
ALTER TABLE silver.ERP_Sales ALTER COLUMN UnitCost       DECIMAL(19,4);
ALTER TABLE silver.ERP_Sales ALTER COLUMN UnitDiscount   DECIMAL(19,4);
ALTER TABLE silver.ERP_Sales ALTER COLUMN UnitPrice      DECIMAL(19,4);
ALTER TABLE silver.ERP_Sales ALTER COLUMN NetPrice       DECIMAL(19,4);

-- ── Integer columns ──────────────────────────────────────────
ALTER TABLE silver.ERP_Sales ALTER COLUMN Quantity       INT;
ALTER TABLE silver.ERP_Sales ALTER COLUMN CustomerKey    INT;

-- ── VARCHAR columns ──────────────────────────────────────────
ALTER TABLE silver.ERP_Sales ALTER COLUMN OrderNumber    VARCHAR(30)  NOT NULL;
ALTER TABLE silver.ERP_Sales ALTER COLUMN Continent      VARCHAR(20)  NOT NULL;
ALTER TABLE silver.ERP_Sales ALTER COLUMN Country        VARCHAR(20)  NOT NULL;
ALTER TABLE silver.ERP_Sales ALTER COLUMN CustomerType   VARCHAR(20)  NOT NULL;
ALTER TABLE silver.ERP_Sales ALTER COLUMN CustomerName   VARCHAR(50)  NOT NULL;
ALTER TABLE silver.ERP_Sales ALTER COLUMN ProductCategory VARCHAR(50)  NOT NULL;
ALTER TABLE silver.ERP_Sales ALTER COLUMN ProductName    VARCHAR(60)  NOT NULL;
ALTER TABLE silver.ERP_Sales ALTER COLUMN ProductKey     VARCHAR(10)  NOT NULL;

-- ── Date columns ─────────────────────────────────────────────
ALTER TABLE silver.ERP_Sales ALTER COLUMN OrderDate      DATE NOT NULL;
ALTER TABLE silver.ERP_Sales ALTER COLUMN DeliveryDate   DATE NOT NULL;
GO

-- ============================================================
-- 6. AUDIT & DATA VALIDATION
-- ============================================================

-- Row Count Validations
SELECT COUNT(*) AS bronze_erp    FROM bronze.ERP_Sales;
SELECT COUNT(*) AS silver_erp    FROM silver.ERP_Sales;
SELECT COUNT(*) AS bronze_budget FROM bronze.HFM_Budget;
SELECT COUNT(*) AS silver_budget FROM silver.HFM_Budget;
GO

-- Sample Validation
SELECT * FROM silver.HFM_Budget;
SELECT * FROM silver.ERP_Sales WHERE OrderNumber = '200912162CS946';
GO

-- Check for Duplicates
SELECT 
    [OrderNumber],
    [ProductName],
    [CustomerKey],
    COUNT(*) AS duplicate_count
FROM silver.ERP_Sales
GROUP BY
    [OrderNumber],
    [ProductName],
    [CustomerKey]
HAVING COUNT(*) > 1;
GO
