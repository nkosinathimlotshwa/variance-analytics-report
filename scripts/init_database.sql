USE master;
GO

/** Drop and recreate the 'ShopInDoor_DWH' database **/
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'ShopInDoor_DWH')
BEGIN
	ALTER DATABASE ShopInDoor_DWH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ShopInDoor_DWH;
END;
GO

/** Database Creation **/
CREATE DATABASE ShopInDoor_DWH;
GO

USE ShopInDoor_DWH;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
