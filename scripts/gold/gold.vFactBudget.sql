USE ShopInDoor_DWH;
GO

-- Drop old view if it exists
IF OBJECT_ID('gold.vFactBudget', 'V') IS NOT NULL
    DROP VIEW gold.vFactBudget;
GO

-- Create new fact budget view
CREATE VIEW gold.vFactBudget AS

SELECT
     
     -- Date Dimension Key
     b.[FullDate] AS [Date]

    -- Geography Dimension Key
    ,g.[GeographySK]

    -- Product Dimension Key
    ,p.[ProductSK]

    -- Degenerate / Business Attributes
    ,b.[Account]

    -- Original Budget in Local Currency
    ,CAST(b.[BudgetAmount] AS DECIMAL(19,4)) AS [BudgetAmount_LC]

    -- Budget Converted to USD
    ,CAST(
        CASE

            -- Prevent divide-by-zero errors
            WHEN g.[FXRateToUSD] IS NULL
                 OR g.[FXRateToUSD] = 0
                 THEN 0

            -- UK override from business case
            WHEN b.[Country] IN ('United Kingdom', 'UK')
                 THEN b.[BudgetAmount] / 0.79

            -- Standard FX conversion
            ELSE b.[BudgetAmount] / g.[FXRateToUSD]

        END
    AS DECIMAL(19,4)) AS [BudgetAmount_USD]

    -- Audit Column
    ,b.[dwh_create_date]

FROM [silver].[HFM_Budget_Unpivoted] b

-- Geography Dimension
LEFT JOIN [gold].[vDimGeography] g
    ON b.[Country] = g.[Country]

-- Product Dimension
LEFT JOIN [gold].[vDimProduct] p
    ON b.[ProductName] = p.[ProductName];

GO

PRINT 'gold.vFactBudget created successfully.';
GO
