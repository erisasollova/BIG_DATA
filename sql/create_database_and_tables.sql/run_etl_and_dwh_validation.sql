-- =============================================
-- FILE: run_etl_and_dwh_validation.sql
-- =============================================
-- KY FILE PERMBUSH KETO KERKESA TE PROJEKTIT:
-- 1. Pjesa 1 - Ngarkimi ne staging
-- 2. Pjesa 2 - Ekzekutimi i ETL
-- 3. Verifikimi i te dhenave ne DWH
-- 4. Integrimi me dataset-in Kaggle
-- 5. Query analitike fillestare
--
-- IDEJA KRYESORE:
-- Ky file:
-- 1. fut te dhenat ne staging
-- 2. ekzekuton stored procedure ETL
-- 3. kontrollon nese DWH eshte mbushur mire
-- 4. ben query lidhese me Kaggle
-- =============================================

USE BigDataProject;
GO


/* 
   KJO PJESE PERFSHIN:
   - dimensionet
   - fact tables
   - ETL
   - kontrollin e DWH
   - query lidhes me Kaggle
*/


-- FUTJA E TE DHENAVE NE STAGING --
-- Ketu te dhenat merren nga tabela burimore WorldBankDataBase
-- dhe futen ne Staging_WorldBank.
-- Kjo eshte pjese e Extract + Load fillestar ne ETL.
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


-- EKZEKUTIMI I ETL --
-- Kjo thirr proceduren sp_LoadDWH.
-- Pas kesaj komande, mbushen dimensionet dhe fact tables ne Data Warehouse.
EXEC sp_LoadDWH;


-- -------------------- KONTROLLI I DIMENSIONEVE --------------------

-- Numron sa rreshta jane futur ne DimCountry.
-- Kjo ndihmon me pa nese dimensioni i shteteve eshte mbushur.
SELECT COUNT(*) AS CountryDimRows
FROM DimCountry;

-- Numron sa rreshta jane futur ne DimIndicator.
-- Kjo tregon nese indikatorët jane ngarkuar me sukses.
SELECT COUNT(*) AS IndicatorDimRows
FROM DimIndicator;

-- Numron sa vite jane futur ne DimTime.
-- Kjo tregon nese dimensioni kohor eshte krijuar si duhet.
SELECT COUNT(*) AS TimeDimRows
FROM DimTime;

-- Shfaq 10 rreshtat e pare te DimCountry.
-- Perdoret per kontroll vizual te te dhenave.
SELECT TOP 10 * FROM DimCountry;

-- Shfaq 10 rreshtat e pare te DimIndicator.
-- Tregon si duken kodet dhe emrat e indikatorëve ne dimension.
SELECT TOP 10 * FROM DimIndicator;

-- Shfaq 10 rreshtat e pare te DimTime.
-- Kjo ndihmon me pa nese TimeKey dhe Year jane futur mire.
SELECT TOP 10 * FROM DimTime;
GO


/* -------------------- KONTROLLI I FACT TABLES -------------------- */

-- Numron sa rreshta jane futur ne FactEconomicData.
-- Kjo eshte matja kryesore e ngarkimit ne fact table.
SELECT COUNT(*) AS FactRows
FROM FactEconomicData;

-- Numron sa rreshta jane futur ne FactTrendAnalysis.
-- Kjo tregon nese pjesa e trendeve/mesatareve eshte krijuar.
SELECT COUNT(*) AS TrendRows
FROM FactTrendAnalysis;

-- Shfaq 10 rreshtat e pare te FactEconomicData.
-- Ketu mund te shihen foreign keys dhe vlerat reale.
SELECT TOP 10 *
FROM FactEconomicData;

-- Shfaq 10 rreshtat e pare te FactTrendAnalysis.
-- Ketu mund te shihen CountryKey, TimeKey dhe AvgValue.
SELECT TOP 10 *
FROM FactTrendAnalysis;
GO


/* -------------------- EKZEKUTIMI I ETL -------------------- */
/* RUN PASI TE JENE MBUSHUR STAGING TABLES */

-- Ri-ekzekuton ETL.
-- Kjo eshte shume e rendesishme per te provuar qe procedura nuk krijon duplikime.
-- Pra po testohet karakteri idempotent i ETL.
EXEC sp_LoadDWH;
GO


/* -------------------- VERIFIKIMI PAS ETL -------------------- */

-- Kontrollon perseri numrin e rreshtave ne dimensione.
-- Nese ETL eshte i sakte, keto vlera nuk duhet te rriten gabimisht nga duplikimet.
SELECT COUNT(*) AS CountryDimRows
FROM DimCountry;

SELECT COUNT(*) AS IndicatorDimRows
FROM DimIndicator;

SELECT COUNT(*) AS TimeDimRows
FROM DimTime;

-- Kontrollon perseri numrin e rreshtave ne fact tables.
-- Nese nuk ka duplikime, numrat duhet te jene konsistent.
SELECT COUNT(*) AS FactRows
FROM FactEconomicData;

SELECT COUNT(*) AS TrendRows
FROM FactTrendAnalysis;

-- Shfaq mostra nga fact tables pas ekzekutimit te dyte.
SELECT TOP 10 *
FROM FactEconomicData;

SELECT TOP 10 *
FROM FactTrendAnalysis;
GO


/* -------------------- QUERY LIDHES MES WORLDBANK DHE KAGGLE -------------------- */

-- Kjo query ben integrimin e te dhenave nga DWH me dataset-in Kaggle.
-- Bashkimi behet ne baze te emrit te shtetit dhe vitit.
-- Ky eshte nje shembull i qarte i data integration.
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

-- Kjo query ben krahasim analitik mes WorldBank dhe Kaggle.
-- Perdoret AVG per te krahasuar mesataret sipas shtetit dhe kategorise.
-- Kjo permbush pjesen e analizave me JOIN, GROUP BY dhe agregim.
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
/* KJO NDIHMON NQS QUERY LIDHESE DEL BOSH */

-- Kjo query tregon sa rreshta ka FactEconomicData per secilin vit.
-- Eshte shume e dobishme per debugging dhe verifikim.
-- Nese viti 2023 mungon, query-t me Kaggle mund te dalin bosh.
SELECT dt.[Year], COUNT(*) AS Cnt
FROM FactEconomicData f
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
GROUP BY dt.[Year]
ORDER BY dt.[Year];
GO


/* -------------------- KONTROLLI I KAGGLE PAS LOAD -------------------- */
/* KJO NDIHMON NQS QUERY LIDHESE DEL BOSH */

-- Numron sa rreshta jane ne Staging_Kaggle.
-- Kjo tregon nese tabela eshte mbushur me sukses.
SELECT COUNT(*) AS KaggleStageRows
FROM Staging_Kaggle;

-- Shfaq 20 rreshtat e pare te Staging_Kaggle.
-- Kjo ndihmon me pa emrat e shteteve, vitin, kategorine dhe vleren.
SELECT TOP 20 *
FROM Staging_Kaggle;
GO


-- Kontroll final i volumit ne te dy staging tables.
-- Kjo eshte nje menyre e thjeshte per te kontrolluar nese importimi fillestar ka ndodhur.
SELECT COUNT(*) AS StagingWorldBankRows
FROM Staging_WorldBank;

SELECT COUNT(*) AS StagingKaggleRows
FROM Staging_Kaggle;