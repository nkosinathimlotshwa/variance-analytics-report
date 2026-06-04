USE ShopInDoor_DWH;
GO

-- Drop the view if it already exists to avoid creation conflicts
IF OBJECT_ID('gold.vDimCustomer', 'V') IS NOT NULL
    DROP VIEW gold.vDimCustomer;
GO

CREATE VIEW gold.vDimCustomer AS
WITH UniqueCustomers AS (
    SELECT 
         -- Fallback handling to keep data clean if keys or names are ever blank
         ISNULL([CustomerKey], -1) AS [CustomerKey]
        ,ISNULL([CustomerName], 'Unknown Customer') AS [CustomerName]
        ,ISNULL([CustomerType], 'Unknown Type') AS [CustomerType]
        ,MIN([dwh_create_date]) AS [RowCreatedDate] -- Lineage tracking for when they first appeared
    FROM [ShopInDoor_DWH].[silver].[ERP_Sales]
    GROUP BY 
         [CustomerKey]
        ,[CustomerName]
        ,[CustomerType]
)
SELECT 
    -- Generates a clean, sequential integer Surrogate Key for Power BI relationships
    ROW_NUMBER() OVER (ORDER BY [CustomerKey] ASC) AS [CustomerSK]
    ,[CustomerKey] -- Kept for traceabilty/data lineage
    ,[CustomerName]
    ,[CustomerType] -- CRITICAL: Used for the stakeholder's requested Customer Type RLS
    ,[RowCreatedDate]
FROM UniqueCustomers;
GO

PRINT 'Success - gold.vDimCustomer view created successfully.';
GO


SELECT * FROM gold.vDimCustomer;
