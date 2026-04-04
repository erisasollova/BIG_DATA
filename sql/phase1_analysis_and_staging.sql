/*KJO PJESE PERFSHIN:
   - kontrollin e WorldBankDataBase
   - kontrollin e KaggleDataBase
   - analizen fillestare
   - rregullimin e Kaggle
   - mbushjen e staging tables
  */

USE BigDataProject;
GO


/* -------------------- WORLDBANK: KONTROLLI BAZE -------------------- */

SELECT TOP 10 *
FROM WorldBankDataBase;

SELECT COUNT(*) AS TotalRows
FROM WorldBankDataBase;

SELECT COUNT(DISTINCT Country_Code) AS TotalCountries
FROM WorldBankDataBase;

SELECT COUNT(DISTINCT Indicator_Code) AS TotalIndicators
FROM WorldBankDataBase;

SELECT MIN([Year]) AS MinYear, MAX([Year]) AS MaxYear
FROM WorldBankDataBase;
GO


/* -------------------- WORLDBANK: KONTROLLI I PROBLEMEVE -------------------- */

SELECT *
FROM WorldBankDataBase
WHERE Country_Name IS NULL
   OR Country_Code IS NULL
   OR Indicator_Name IS NULL
   OR Indicator_Code IS NULL
   OR [Year] IS NULL;

SELECT Country_Code, Indicator_Code, [Year], COUNT(*) AS DuplicateCount
FROM WorldBankDataBase
GROUP BY Country_Code, Indicator_Code, [Year]
HAVING COUNT(*) > 1;
GO


/* -------------------- WORLDBANK: ANALIZA BAZE -------------------- */

SELECT TOP 10 Country_Name, AVG(Value) AS AvgValue
FROM WorldBankDataBase
GROUP BY Country_Name
ORDER BY AvgValue DESC;

SELECT [Year], AVG(Value) AS AvgValue
FROM WorldBankDataBase
GROUP BY [Year]
ORDER BY [Year];
GO


/* -------------------- KAGGLE: KONTROLLI BAZE -------------------- */

SELECT TOP 10 *
FROM KaggleDataBase;

SELECT COUNT(*) AS TotalRows
FROM KaggleDataBase;

SELECT DISTINCT [Year]
FROM KaggleDataBase;
GO


/* -------------------- KAGGLE: RREGULLIMI I EMRAVE TE SHTETEVE -------------------- */

UPDATE KaggleDataBase
SET Country = 'United States'
WHERE Country = 'United Stat';

UPDATE KaggleDataBase
SET Country = 'South Korea'
WHERE Country = 'South Kore';

UPDATE KaggleDataBase
SET Country = 'United Kingdom'
WHERE Country = 'United King';

UPDATE KaggleDataBase
SET Country = 'Saudi Arabia'
WHERE Country = 'Saudi Arabi';

UPDATE KaggleDataBase
SET Country = 'Netherlands'
WHERE Country = 'Netherland';
GO


/* -------------------- KAGGLE: ANALIZA BAZE -------------------- */

SELECT TOP 10 *
FROM KaggleDataBase;

SELECT COUNT(*) AS TotalRows
FROM KaggleDataBase;

SELECT DISTINCT [Year]
FROM KaggleDataBase;

SELECT TOP 10 Country, GDP_per_capita
FROM KaggleDataBase
ORDER BY GDP_per_capita DESC;

SELECT TOP 10 Country, Population_2023
FROM KaggleDataBase
ORDER BY Population_2023 DESC;

SELECT TOP 10 Country, Share_of_World_GDP
FROM KaggleDataBase
ORDER BY Share_of_World_GDP DESC;
GO


/* -------------------- KAGGLE: KONTROLLI I PROBLEMEVE -------------------- */

SELECT *
FROM KaggleDataBase
WHERE Country IS NULL
   OR [Year] IS NULL
   OR GDP_per_capita IS NULL
   OR Population_2023 IS NULL
   OR Share_of_World_GDP IS NULL;

SELECT Country, [Year], COUNT(*) AS DuplicateCount
FROM KaggleDataBase
GROUP BY Country, [Year]
HAVING COUNT(*) > 1;
GO


/* -------------------- KONTROLLI I STAGING TABLES -------------------- */

SELECT COUNT(*) AS StagingWorldBankRows
FROM Staging_WorldBank;

SELECT COUNT(*) AS StagingKaggleRows
FROM Staging_Kaggle;
GO


/* -------------------- MBUSHJA E STAGING_WORLDBANK -------------------- */
/* RUN KETE VETEM NQS STAGING_WORLDBANK ESHTE BOSH */

INSERT INTO Staging_WorldBank
(
    Country_Name,
    Country_Code,
    Indicator_Name,
    Indicator_Code,
    [Year],
    Value
)
SELECT
    Country_Name,
    Country_Code,
    Indicator_Name,
    Indicator_Code,
    [Year],
    Value
FROM WorldBankDataBase;
GO


/* -------------------- MBUSHJA E STAGING_KAGGLE -------------------- */
/* RUN KETO VETEM NQS STAGING_KAGGLE ESHTE BOSH */

INSERT INTO Staging_Kaggle
(
    Country_Name,
    [Year],
    Category,
    Value
)
SELECT
    Country,
    [Year],
    'GDP_per_capita',
    CAST(GDP_per_capita AS FLOAT)
FROM KaggleDataBase
WHERE GDP_per_capita IS NOT NULL;
GO

INSERT INTO Staging_Kaggle
(
    Country_Name,
    [Year],
    Category,
    Value
)
SELECT
    Country,
    [Year],
    'Population',
    CAST(Population_2023 AS FLOAT)
FROM KaggleDataBase
WHERE Population_2023 IS NOT NULL;
GO

INSERT INTO Staging_Kaggle
(
    Country_Name,
    [Year],
    Category,
    Value
)
SELECT
    Country,
    [Year],
    'Share_of_World_GDP',
    CAST(Share_of_World_GDP AS FLOAT)
FROM KaggleDataBase
WHERE Share_of_World_GDP IS NOT NULL;
GO


/* -------------------- VERIFIKIMI PAS MBUSHJES SE STAGING -------------------- */

SELECT COUNT(*) AS WorldBankStageRows
FROM Staging_WorldBank;

SELECT COUNT(*) AS KaggleStageRows
FROM Staging_Kaggle;

SELECT TOP 10 *
FROM Staging_WorldBank;

SELECT TOP 10 *
FROM Staging_Kaggle;
GO


/* -------------------- KONTROLLI I EMRAVE QE NUK PERPUTHEN -------------------- */
/* KJO TREGON SHTETET QE JANE TE KAGGLE POR JO TE DWH */

SELECT DISTINCT Country_Name
FROM Staging_Kaggle
SELECT DISTINCT Country_Name
FROM DimCountry;
GO