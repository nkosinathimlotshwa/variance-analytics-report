-- ============================================================
-- ShopInDoor_DWH | Silver Layer | HFM_Budget
-- Case Study: Australia & USA Sales | FY2020
-- ============================================================

USE ShopInDoor_DWH;
GO

SET DATEFIRST  1;
SET DATEFORMAT ymd;
SET LANGUAGE   US_ENGLISH;
GO


-- ============================================================
-- STEP 1: Tear down existing objects (reverse dependency order)
-- ============================================================

IF OBJECT_ID('silver.HFM_Budget_Unpivoted', 'U') IS NOT NULL
    DROP TABLE silver.HFM_Budget_Unpivoted;
GO

IF OBJECT_ID('silver.HFM_Budget', 'U') IS NOT NULL
    DROP TABLE silver.HFM_Budget;
GO


-- ============================================================
-- STEP 2: Create wide staging table
-- ============================================================

CREATE TABLE silver.HFM_Budget (
    Account         NVARCHAR(50),
    Country         NVARCHAR(50),
    Product         NVARCHAR(100),
    Jan_LC          NVARCHAR(50),
    Feb_LC          NVARCHAR(50),
    Mar_LC          NVARCHAR(50),
    Apr_LC          NVARCHAR(50),
    May_LC          NVARCHAR(50),
    Jun_LC          NVARCHAR(50),
    Jul_LC          NVARCHAR(50),
    Aug_LC          NVARCHAR(50),
    Sep_LC          NVARCHAR(50),
    Oct_LC          NVARCHAR(50),
    Nov_LC          NVARCHAR(50),
    Dec_LC          NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


-- ============================================================
-- STEP 3: Load wide table from bronze layer
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
    CAST([Unnamed: 0] AS NVARCHAR(50))  AS Account,
    CAST([Unnamed: 1] AS NVARCHAR(50))  AS Country,
    CAST([Unnamed: 2] AS NVARCHAR(100)) AS Product,
    CAST([Local_]     AS NVARCHAR(50))  AS Jan_LC,
    CAST([Local_.1]   AS NVARCHAR(50))  AS Feb_LC,
    CAST([Local_.2]   AS NVARCHAR(50))  AS Mar_LC,
    CAST([Local_.3]   AS NVARCHAR(50))  AS Apr_LC,
    CAST([Local_.4]   AS NVARCHAR(50))  AS May_LC,
    CAST([Local_.5]   AS NVARCHAR(50))  AS Jun_LC,
    CAST([Local_.6]   AS NVARCHAR(50))  AS Jul_LC,
    CAST([Local_.7]   AS NVARCHAR(50))  AS Aug_LC,
    CAST([Local_.8]   AS NVARCHAR(50))  AS Sep_LC,
    CAST([Local_.9]   AS NVARCHAR(50))  AS Oct_LC,
    CAST([Local_.10]  AS NVARCHAR(50))  AS Nov_LC,
    CAST([Local_.11]  AS NVARCHAR(50))  AS Dec_LC
FROM bronze.HFM_Budget
WHERE [Unnamed: 0] IS NOT NULL
  AND CAST([Unnamed: 0] AS NVARCHAR(50))
      NOT IN ('nan', 'RptCur', 'FY20', 'Budget', 'Final', 'Jan');
GO


-- ============================================================
-- STEP 4: Create long (unpivoted) table
--         Final data types declared upfront — no post-ALTER needed
-- ============================================================

CREATE TABLE silver.HFM_Budget_Unpivoted (
    Account         VARCHAR(20)     NOT NULL,
    Country         VARCHAR(20)     NOT NULL,
    ProductName     VARCHAR(60)     NOT NULL,
    BudgetYear      INT             NOT NULL,
    MonthName       VARCHAR(20)     NOT NULL,
    BudgetAmount    DECIMAL(19, 4)  NULL,
    FullDate        DATE            NOT NULL,
    dwh_create_date DATETIME2       DEFAULT GETDATE(),

    CONSTRAINT FK_HFM_Budget_Unpivoted_FullDate
        FOREIGN KEY (FullDate)
        REFERENCES silver.DateDimension (TheDate)
);
GO


-- ============================================================
-- STEP 5: Unpivot months and load long table
-- ============================================================

INSERT INTO silver.HFM_Budget_Unpivoted (
    Account,
    Country,
    ProductName,
    BudgetYear,
    MonthName,
    BudgetAmount,
    FullDate
)
SELECT
    b.Account,
    b.Country,
    b.Product                                                   AS ProductName,
    2020                                                        AS BudgetYear,
    v.MonthName,
    TRY_CAST(v.RawAmount AS DECIMAL(19, 4))                     AS BudgetAmount,
    DATEFROMPARTS(
        2020,
        MONTH(CAST('01 ' + v.MonthName + ' 2000' AS DATE)),
        1
    )                                                           AS FullDate
FROM silver.HFM_Budget AS b
CROSS APPLY (
    VALUES
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
) AS v (MonthName, RawAmount);
GO


-- ============================================================
-- STEP 6: Validation queries
-- ============================================================

-- 6a. Row counts
SELECT COUNT(*) AS HFM_Budget_Rows          FROM silver.HFM_Budget;
SELECT COUNT(*) AS HFM_Budget_Unpivoted_Rows FROM silver.HFM_Budget_Unpivoted;

-- 6b. Confirm all 12 months resolved correctly
SELECT DISTINCT
    MonthName,
    FullDate,
    BudgetYear
FROM silver.HFM_Budget_Unpivoted
ORDER BY FullDate;

-- 6c. Flag any amounts that failed to cast
SELECT *
FROM silver.HFM_Budget_Unpivoted
WHERE BudgetAmount IS NULL;

-- 6d. Monthly totals by country
SELECT
    Country,
    MonthName,
    FullDate,
    SUM(BudgetAmount) AS TotalBudgetAmount,
    COUNT(*)          AS TotalRows
FROM silver.HFM_Budget_Unpivoted
GROUP BY Country, MonthName, FullDate
ORDER BY Country, FullDate;

-- 6e. Spot-check join to DateDimension
SELECT TOP 20
    b.Account,
    b.Country,
    b.ProductName,
    b.MonthName,
    b.FullDate,
    b.BudgetAmount,
    d.TheMonthName,
    d.TheQuarter,
    d.AU_FiscalYear,
    d.AU_FiscalQuarter,
    d.USA_FiscalYear,
    d.USA_FiscalQuarter
FROM silver.HFM_Budget_Unpivoted AS b
JOIN silver.DateDimension         AS d ON d.TheDate = b.FullDate
ORDER BY b.Country, b.FullDate, b.Account;
GO
