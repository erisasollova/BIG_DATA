/* 
   KJO PJESE PERFSHIN:
   - dimensionet
   - fact tables
   - ETL
   - kontrollin e DWH
   - query lidhes me Kaggle
   */

USE BigDataProject;
GO

-- FUTJA E TE DHENAVE NE STAGING --

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

-- EKZEKUTIMI I ETL--

EXEC sp_LoadDWH;

/* -------------------- KONTROLLI I DIMENSIONEVE -------------------- */

SELECT COUNT(*) AS CountryDimRows
FROM DimCountry;

SELECT COUNT(*) AS IndicatorDimRows
FROM DimIndicator;

SELECT COUNT(*) AS TimeDimRows
FROM DimTime;

SELECT TOP 10 * FROM DimCountry;
SELECT TOP 10 * FROM DimIndicator;
SELECT TOP 10 * FROM DimTime;
GO


/* -------------------- KONTROLLI I FACT TABLES -------------------- */

SELECT COUNT(*) AS FactRows
FROM FactEconomicData;

SELECT COUNT(*) AS TrendRows
FROM FactTrendAnalysis;

SELECT TOP 10 *
FROM FactEconomicData;

SELECT TOP 10 *
FROM FactTrendAnalysis;
GO


/* -------------------- EKZEKUTIMI I ETL -------------------- */
/* RUN  PASI TE JENE MBUSHUR STAGING TABLES */

EXEC sp_LoadDWH;
GO


/* -------------------- VERIFIKIMI PAS ETL -------------------- */

SELECT COUNT(*) AS CountryDimRows
FROM DimCountry;

SELECT COUNT(*) AS IndicatorDimRows
FROM DimIndicator;

SELECT COUNT(*) AS TimeDimRows
FROM DimTime;

SELECT COUNT(*) AS FactRows
FROM FactEconomicData;

SELECT COUNT(*) AS TrendRows
FROM FactTrendAnalysis;

SELECT TOP 10 *
FROM FactEconomicData;

SELECT TOP 10 *
FROM FactTrendAnalysis;
GO


/* -------------------- QUERY LIDHES MES WORLDBANK DHE KAGGLE -------------------- */

SELECT 
    dc.Country_Name,
    dt.[Year],
    f.Value AS WorldBankValue,
    k.Category,
    k.Value AS KaggleValue
FROM FactEconomicData f
JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
JOIN Staging_Kaggle k
    ON dc.Country_Name = k.Country_Name
   AND dt.[Year] = k.[Year]
WHERE dt.[Year] = 2023;
GO


/* -------------------- QUERY ANALITIK ME KAGGLE -------------------- */

SELECT 
    dc.Country_Name,
    k.Category,
    AVG(f.Value) AS AvgWorldBankValue,
    AVG(k.Value) AS AvgKaggleValue
FROM FactEconomicData f
JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
JOIN Staging_Kaggle k
    ON dc.Country_Name = k.Country_Name
   AND dt.[Year] = k.[Year]
WHERE dt.[Year] = 2023
GROUP BY dc.Country_Name, k.Category
ORDER BY dc.Country_Name, k.Category;
GO


/* -------------------- KONTROLLI I VITEVE NE FACT TABLE -------------------- */
/* KJO  NDIHMON NQS QUERY LIDHESE DEL BOSH */

SELECT dt.[Year], COUNT(*) AS Cnt
FROM FactEconomicData f
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
GROUP BY dt.[Year]
ORDER BY dt.[Year];
GO


/* -------------------- KONTROLLI I KAGGLE PAS LOAD -------------------- */
/* KJO  NDIHMON NQS QUERY LIDHESE DEL BOSH */

SELECT COUNT(*) AS KaggleStageRows
FROM Staging_Kaggle;

SELECT TOP 20 *
FROM Staging_Kaggle;
GO\

-------------------------------------------
SELECT COUNT(*) AS StagingWorldBankRows
FROM Staging_WorldBank;

SELECT COUNT(*) AS StagingKaggleRows
FROM Staging_Kaggle;