USE BigDataProject;
GO

/* CLEAN RESET */
   

IF OBJECT_ID('FactEconomicData_Partitioned') IS NOT NULL
    DROP TABLE FactEconomicData_Partitioned;

IF OBJECT_ID('Staging_Kaggle_Partitioned') IS NOT NULL
    DROP TABLE Staging_Kaggle_Partitioned;
GO

IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name='ps_YearScheme')
    DROP PARTITION SCHEME ps_YearScheme;
IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name='ps_CategoryScheme')
    DROP PARTITION SCHEME ps_CategoryScheme;
GO

IF EXISTS (SELECT * FROM sys.partition_functions WHERE name='pf_YearRange')
    DROP PARTITION FUNCTION pf_YearRange;
IF EXISTS (SELECT * FROM sys.partition_functions WHERE name='pf_Category')
    DROP PARTITION FUNCTION pf_Category;
GO

/* 1. FILEGROUPS */

IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name='FG_2015_2019')
    ALTER DATABASE BigDataProject ADD FILEGROUP FG_2015_2019;

IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name='FG_2020_2022')
    ALTER DATABASE BigDataProject ADD FILEGROUP FG_2020_2022;

IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE name='FG_2023')
    ALTER DATABASE BigDataProject ADD FILEGROUP FG_2023;
GO

/*  FILES */

IF NOT EXISTS (SELECT * FROM sys.database_files WHERE name='Data_2015_2019')
ALTER DATABASE BigDataProject ADD FILE (
    NAME = Data_2015_2019,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Data_2015_2019.ndf'
) TO FILEGROUP FG_2015_2019;

IF NOT EXISTS (SELECT * FROM sys.database_files WHERE name='Data_2020_2022')
ALTER DATABASE BigDataProject ADD FILE (
    NAME = Data_2020_2022,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Data_2020_2022.ndf'
) TO FILEGROUP FG_2020_2022;

IF NOT EXISTS (SELECT * FROM sys.database_files WHERE name='Data_2023')
ALTER DATABASE BigDataProject ADD FILE (
    NAME = Data_2023,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Data_2023.ndf'
) TO FILEGROUP FG_2023;
GO

/* PARTITION FUNCTION + SCHEME (YEAR) */

CREATE PARTITION FUNCTION pf_YearRange (SMALLINT)
AS RANGE RIGHT FOR VALUES (2019, 2022);
GO

CREATE PARTITION SCHEME ps_YearScheme
AS PARTITION pf_YearRange
TO (FG_2015_2019, FG_2020_2022, FG_2023);
GO

/* PARTITIONED FACT TABLE (FIXED PK)*/

CREATE TABLE FactEconomicData_Partitioned (
    FactID INT IDENTITY(1,1),
    CountryKey INT,
    IndicatorKey INT,
    TimeKey INT,
    [Year] SMALLINT,
    Value FLOAT,

    CONSTRAINT PK_FactEconomicData 
    PRIMARY KEY CLUSTERED (FactID, [Year])
)
ON ps_YearScheme([Year]);
GO

/* CLUSTERED INDEX aligned */
CREATE CLUSTERED INDEX CIX_FactEconomicData_Partitioned
ON FactEconomicData_Partitioned([Year], FactID)
ON ps_YearScheme([Year]);
GO

/* LOAD DATA */

INSERT INTO FactEconomicData_Partitioned
(CountryKey, IndicatorKey, TimeKey, [Year], Value)
SELECT f.CountryKey,f.IndicatorKey,f.TimeKey,dt.[Year],f.Value
FROM FactEconomicData f
JOIN DimTime dt ON f.TimeKey = dt.TimeKey;
GO

/* CATEGORY PARTITION (SIMULATION) */

CREATE PARTITION FUNCTION pf_Category (INT)
AS RANGE LEFT FOR VALUES (1,2);
GO

CREATE PARTITION SCHEME ps_CategoryScheme
AS PARTITION pf_Category ALL TO ([PRIMARY]);
GO

CREATE TABLE Staging_Kaggle_Partitioned (
    Country_Name NVARCHAR(255),
    [Year] SMALLINT,
    Category NVARCHAR(255),
    Value FLOAT,
    CategoryKey AS 
        CASE 
            WHEN Category='GDP_per_capita' THEN 1
            WHEN Category='Population' THEN 2
            ELSE 3
        END PERSISTED
)
ON ps_CategoryScheme(CategoryKey);
GO

INSERT INTO Staging_Kaggle_Partitioned
SELECT Country_Name,[Year],Category,Value
FROM Staging_Kaggle;
GO


CREATE TABLE FactEconomicData_Partitioned (
    FactID INT IDENTITY(1,1) NOT NULL,
    CountryKey INT,
    IndicatorKey INT,
    TimeKey INT,
    [Year] SMALLINT NOT NULL,
    Value FLOAT,
    CONSTRAINT PK_FactEconomicData 
        PRIMARY KEY CLUSTERED ([Year], FactID)   -- VENDOS YEAR I PARI
) 
INSERT INTO FactEconomicData_Partitioned
(CountryKey, IndicatorKey, TimeKey, [Year], Value)
SELECT f.CountryKey,f.IndicatorKey,f.TimeKey,dt.[Year],f.Value
FROM FactEconomicData f
JOIN DimTime dt ON f.TimeKey = dt.TimeKey;

ON ps_YearScheme([Year]);
GO