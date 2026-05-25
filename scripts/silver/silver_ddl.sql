-- ============================================================
-- DDL Script  : Create Silver Tables
-- Project     : ShopInDoor Variance Analytics
-- Description : Creates silver tables as NVARCHAR
--               Data types converted in next step
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
    CustomerContinent   NVARCHAR(50),
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
    Account             NVARCHAR(50),   -- Unnamed: 0 (700000)
    Country             NVARCHAR(50),   -- Unnamed: 1 (Australia)
    Product             NVARCHAR(100),  -- Unnamed: 2 (MP4&MP3)
    Jan_LC              NVARCHAR(50),   -- Local_
    Feb_LC              NVARCHAR(50),   -- Local_.1
    Mar_LC              NVARCHAR(50),   -- Local_.2
    Apr_LC              NVARCHAR(50),   -- Local_.3
    May_LC              NVARCHAR(50),   -- Local_.4
    Jun_LC              NVARCHAR(50),   -- Local_.5
    Jul_LC              NVARCHAR(50),   -- Local_.6
    Aug_LC              NVARCHAR(50),   -- Local_.7
    Sep_LC              NVARCHAR(50),   -- Local_.8
    Oct_LC              NVARCHAR(50),   -- Local_.9
    Nov_LC              NVARCHAR(50),   -- Local_.10
    Dec_LC              NVARCHAR(50),   -- Local_.11
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO
