# ShopInDoor_DWH

A data warehouse project built on SQL Server 2022 using the Medallion Architecture 
(Bronze / Silver / Gold) to support the ShopInDoor EMEA variance analytics report.

## Architecture
- **Bronze** : Raw data ingested as-is from source systems (ERP & HFM)
- **Silver** : Cleaned, standardized, and FX-converted data
- **Gold**   : Business-ready aggregated data powering the Power BI report

## Highlights
- Budget vs Actuals variance analysis across EMEA countries
- Multi-currency support with FX conversion to USD
- Weighted customer ranking model by sales, margin, and units sold
- Designed to feed a Power BI Desktop report for stakeholder reporting
