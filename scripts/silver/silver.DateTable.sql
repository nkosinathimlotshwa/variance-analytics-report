USE ShopInDoor_DWH;
GO

-- Drop the view if it already exists to avoid creation conflicts
IF OBJECT_ID('gold.vDimDate', 'V') IS NOT NULL
    DROP VIEW gold.vDimDate;
GO

CREATE VIEW gold.vDimDate AS
SELECT 
     [TheDate]              AS [Date]               -- Clean Primary Date column for relationships
    ,[TheYear]              AS [Year]
    ,[TheQuarter]           AS [Quarter]
    ,[TheMonth]             AS [MonthNumber]
    ,[TheMonthName]         AS [MonthName]          -- Full, qualified month names (e.g., January)
    ,[TheWeek]              AS [WeekNumber]
    ,[TheISOWeek]           AS [ISOWeekNumber]
    ,[TheDay]               AS [DayOfMonth]
    ,[TheDayName]           AS [DayName]
    ,[TheDayOfWeek]         AS [DayOfWeekNumber]
    ,[TheDayOfYear]         AS [DayOfYearNumber]
    ,[TheDaySuffix]         AS [DaySuffix]
    ,[IsWeekend]            AS [IsWeekend]
    
    -- First and Last date bounds (very useful for specialized DAX measures)
    ,[TheFirstOfMonth]      AS [FirstDateOfMonth]
    ,[TheLastOfMonth]       AS [LastDateOfMonth]
    ,[TheFirstOfQuarter]    AS [FirstDateOfQuarter]
    ,[TheLastOfQuarter]     AS [LastDateOfQuarter]
    ,[TheFirstOfYear]       AS [FirstDateOfYear]
    ,[TheLastOfYear]        AS [LastDateOfYear]
    
    -- Pre-formatted text style options for labels
    ,[StyleAU]              AS [DateLabel_AU]       -- DD/MM/YYYY format
    ,[StyleUSA]             AS [DateLabel_US]       -- MM/DD/YYYY format
    ,[StyleISO]             AS [DateLabel_ISO]      -- YYYY-MM-DD format
    ,[MMYYYY]               AS [MonthYearLabel]     -- MMYYYY text string
    
    -- Fiscal calendar tracks for regional analytical depth
    ,[AU_FiscalYear]        AS [AU_FiscalYear]
    ,[AU_FiscalQuarter]     AS [AU_FiscalQuarter]
    ,[AU_FiscalMonth]       AS [AU_FiscalMonth]
    ,[USA_FiscalYear]       AS [US_FiscalYear]
    ,[USA_FiscalQuarter]    AS [US_FiscalQuarter]
FROM [ShopInDoor_DWH].[silver].[DateDimension];
GO

PRINT 'Success - gold.vDimDate view created successfully containing fully qualified month names.';
GO
