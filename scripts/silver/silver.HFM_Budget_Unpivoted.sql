-- ============================================================
-- ShopInDoor_DWH | Silver Layer | HFM_Budget
-- Case Study: Australia & USA Sales | 2020
-- ============================================================

USE ShopInDoor_DWH;
GO

SET DATEFIRST  1,
    DATEFORMAT ymd,
    LANGUAGE   US_ENGLISH;
GO

-- ============================================================
-- STEP 1: Drop and Create silver.HFM_Budget (wide format)
-- ============================================================

IF OBJECT_ID('silver.HFM_Budget_Unpivoted', 'U') IS NOT NULL
    DROP TABLE silver.HFM_Budget_Unpivoted;
GO

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
-- STEP 2: Load data from bronze.HFM_Budget
-- ============================================================

INSERT INTO silver.HFM_Budget (
    Account,
    Country,
    Product,
    Jan_LC, Feb_LC, Mar_LC, Apr_LC,
    May_LC, Jun_LC, Jul_LC, Aug_LC,
    Sep_LC, Oct_LC, Nov_LC, Dec_LC
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
  AND CAST([Unnamed: 0] AS NVARCHAR(50))
      NOT IN ('nan','RptCur','FY20','Budget','Final','Jan');
GO

-- ============================================================
-- STEP 3: Create silver.HFM_Budget_Unpivoted (long format)
-- ============================================================

CREATE TABLE silver.HFM_Budget_Unpivoted (
    Account         NVARCHAR(50),
    Country         NVARCHAR(50),
    Product         NVARCHAR(100),
    BudgetYear      INT             NOT NULL,
    MonthName       NVARCHAR(3)     NOT NULL,
    Amount          DECIMAL(18,2)   NULL,
    FullDate        DATE            NOT NULL,
    dwh_create_date DATETIME2       DEFAULT GETDATE(),

    CONSTRAINT FK_HFM_Budget_Unpivoted_FullDate
        FOREIGN KEY (FullDate)
        REFERENCES silver.DateDimension(TheDate)
);
GO

-- ============================================================
-- STEP 4: Insert unpivoted rows with FullDate
-- ============================================================

INSERT INTO silver.HFM_Budget_Unpivoted (
    Account, Country, Product,
    BudgetYear, MonthName, Amount, FullDate
)
SELECT
    b.Account,
    b.Country,
    b.Product,
    BudgetYear = 2020,
    MonthName  = v.MonthName,
    Amount     = TRY_CAST(v.Amount AS DECIMAL(18,2)),
    FullDate   = DATEFROMPARTS(
                     2020,
                     MONTH(CAST('01 ' + v.MonthName + ' 2000' AS date)),
                     1
                 )
FROM silver.HFM_Budget b
CROSS APPLY (VALUES
    ('Jan', b.Jan_LC),
    ('Feb', b.Feb_LC),
    ('Mar', b.Mar_LC),
    ('Apr', b.Apr_LC),
    ('May', b.May_LC),
    ('Jun', b.Jun_LC),
    ('Jul', b.Jul_LC),
    ('Aug', b.Aug_LC),
    ('Sep', b.Sep_LC),
    ('Oct', b.Oct_LC),
    ('Nov', b.Nov_LC),
    ('Dec', b.Dec_LC)
) v(MonthName, Amount);
GO

-- ============================================================
-- STEP 5: Validation
-- ============================================================

-- 1. Wide table row count
SELECT COUNT(*) AS HFM_Budget_Rows 
FROM silver.HFM_Budget;

-- 2. Unpivoted table row count
SELECT COUNT(*) AS HFM_Budget_Unpivoted_Rows 
FROM silver.HFM_Budget_Unpivoted;

-- 3. Confirm all 12 months converted correctly
SELECT DISTINCT
    MonthName,
    FullDate,
    BudgetYear
FROM silver.HFM_Budget_Unpivoted
ORDER BY FullDate;

-- 4. Check for any Amount values that failed to convert
SELECT *
FROM silver.HFM_Budget_Unpivoted
WHERE Amount IS NULL;

-- 5. Summary by Country and Month
SELECT
    Country,
    MonthName,
    FullDate,
    SUM(Amount)     AS TotalAmount,
    COUNT(*)        AS TotalRows
FROM silver.HFM_Budget_Unpivoted
GROUP BY Country, MonthName, FullDate
ORDER BY Country, FullDate;

-- 6. Join test with DateDimension
SELECT TOP 20
    b.Account,
    b.Country,
    b.Product,
    b.MonthName,
    b.FullDate,
    b.Amount,
    d.TheMonthName,
    d.TheQuarter,
    d.AU_FiscalYear,
    d.AU_FiscalQuarter,
    d.USA_FiscalYear,
    d.USA_FiscalQuarter
FROM silver.HFM_Budget_Unpivoted b
JOIN silver.DateDimension         d ON d.TheDate = b.FullDate
ORDER BY b.Country, b.FullDate, b.Account;
GO
select * from SILVER.HFM_Budget_Unpivoted;

EXEC sp_rename 'silver.HFM_Budget_Unpivoted.Amount', 'BudgetAmount', 'COLUMN';

ALTER TABLE silver.HFM_Budget_Unpivoted ALTER COLUMN [MonthName] VARCHAR(20) NOT NULL;
ALTER TABLE silver.HFM_Budget_Unpivoted ALTER COLUMN [Country] VARCHAR(20) NOT NULL;
ALTER TABLE silver.HFM_Budget_Unpivoted ALTER COLUMN [Account] VARCHAR(20) NOT NULL;
ALTER TABLE silver.HFM_Budget_Unpivoted ALTER COLUMN ProductName VARCHAR(60) NOT NULL;
ALTER TABLE silver.HFM_Budget_Unpivoted ALTER COLUMN BudgetAmount DECIMAL(19,4) NOT NULL;
