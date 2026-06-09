USE ShopInDoor_DWH;
GO

IF OBJECT_ID('gold.vDimProduct', 'V') IS NOT NULL
    DROP VIEW gold.vDimProduct;
GO

CREATE VIEW gold.vDimProduct AS
WITH UniqueProducts AS (
    SELECT 
         ISNULL([ProductKey], 'Unknown') AS [ProductKey]
        ,ISNULL([ProductName], 'Unknown Product') AS [ProductName]
        ,ISNULL([ProductCategory], 'Unknown Category') AS [ProductCategory]
    FROM [ShopInDoor_DWH].[silver].[ERP_Sales]
    GROUP BY [ProductKey], [ProductName], [ProductCategory]
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY [ProductKey] ASC) AS [ProductSK]
    ,[ProductKey]
    ,[ProductName]
    ,[ProductCategory]
FROM UniqueProducts;
GO
