-- =========================================================
-- FAZA 1 - ANALIZA + PASRTRIMI + STAGING
-- =========================================================
-- KJO PJESË PERMBUSH:
-- - analizën fillestare të dataset-eve
-- - kontrollin e cilësisë (NULL, duplikime)
-- - pastrimin e të dhënave (data cleaning)
-- - përgatitjen për ETL
-- - mbushjen e staging tables
-- =========================================================


USE BigDataProject;
GO


/* -------------------- WORLDBANK: KONTROLLI BAZE -------------------- */

-- Shfaq 10 rreshtat e parë për të parë strukturën e të dhënave.
SELECT TOP 10 *
FROM WorldBankDataBase;

-- Numëron totalin e rreshtave (madhësia e dataset-it).
SELECT COUNT(*) AS TotalRows
FROM WorldBankDataBase;

-- Numëron sa shtete unike ekzistojnë.
-- DISTINCT përdoret për të shmangur përsëritjet.
SELECT COUNT(DISTINCT Country_Code) AS TotalCountries
FROM WorldBankDataBase;

-- Numëron sa indikatorë unikë ekzistojnë.
SELECT COUNT(DISTINCT Indicator_Code) AS TotalIndicators
FROM WorldBankDataBase;

-- Gjen vitin minimal dhe maksimal.
-- Kjo ndihmon për analizat ndër vite.
SELECT MIN([Year]) AS MinYear, MAX([Year]) AS MaxYear
FROM WorldBankDataBase;
GO


/* -------------------- WORLDBANK: KONTROLLI I PROBLEMEVE -------------------- */

-- Kontrollon nëse ka vlera NULL në kolonat kryesore.
-- Këto duhet të trajtohen sepse mund të prishin analizat.
SELECT *
FROM WorldBankDataBase
WHERE Country_Name IS NULL
   OR Country_Code IS NULL
   OR Indicator_Name IS NULL
   OR Indicator_Code IS NULL
   OR [Year] IS NULL;

-- Kontrollon duplikimet.
-- GROUP BY grupon sipas shtet + indikator + vit.
-- HAVING COUNT(*) > 1 tregon rreshtat e përsëritur.
SELECT Country_Code, Indicator_Code, [Year], COUNT(*) AS DuplicateCount
FROM WorldBankDataBase
GROUP BY Country_Code, Indicator_Code, [Year]
HAVING COUNT(*) > 1;
GO


/* -------------------- WORLDBANK: ANALIZA BAZE -------------------- */

-- Mesatarja e vlerave për çdo shtet.
-- AVG është funksion agregues.
SELECT TOP 10 Country_Name, AVG(Value) AS AvgValue
FROM WorldBankDataBase
GROUP BY Country_Name
ORDER BY AvgValue DESC;

-- Analiza e trendit sipas viteve.
-- Tregon si ndryshojnë vlerat me kohën.
SELECT [Year], AVG(Value) AS AvgValue
FROM WorldBankDataBase
GROUP BY [Year]
ORDER BY [Year];
GO


/* -------------------- KAGGLE: KONTROLLI BAZE -------------------- */

-- Shfaq 10 rreshtat e parë nga dataset-i Kaggle.
SELECT TOP 10 *
FROM KaggleDataBase;

-- Numëron totalin e rreshtave.
SELECT COUNT(*) AS TotalRows
FROM KaggleDataBase;

-- Shfaq vitet unike.
SELECT DISTINCT [Year]
FROM KaggleDataBase;
GO


/* -------------------- KAGGLE: RREGULLIMI I EMRAVE TE SHTETEVE -------------------- */

-- Kjo pjesë është DATA CLEANING.
-- Rregullon emrat që janë shkruar gabim që të përputhen me WorldBank.

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

-- Kontroll i thjeshtë i të dhënave.
SELECT TOP 10 *
FROM KaggleDataBase;

SELECT COUNT(*) AS TotalRows
FROM KaggleDataBase;

SELECT DISTINCT [Year]
FROM KaggleDataBase;

-- Top 10 shtetet me GDP më të lartë për person.
SELECT TOP 10 Country, GDP_per_capita
FROM KaggleDataBase
ORDER BY GDP_per_capita DESC;

-- Top 10 shtetet me popullsi më të madhe.
SELECT TOP 10 Country, Population_2023
FROM KaggleDataBase
ORDER BY Population_2023 DESC;

-- Top 10 shtetet me pjesë më të madhe në GDP globale.
SELECT TOP 10 Country, Share_of_World_GDP
FROM KaggleDataBase
ORDER BY Share_of_World_GDP DESC;
GO


/* -------------------- KAGGLE: KONTROLLI I PROBLEMEVE -------------------- */

-- Kontroll për vlera NULL.
SELECT *
FROM KaggleDataBase
WHERE Country IS NULL
   OR [Year] IS NULL
   OR GDP_per_capita IS NULL
   OR Population_2023 IS NULL
   OR Share_of_World_GDP IS NULL;

-- Kontroll për duplikime.
SELECT Country, [Year], COUNT(*) AS DuplicateCount
FROM KaggleDataBase
GROUP BY Country, [Year]
HAVING COUNT(*) > 1;
GO


/* -------------------- KONTROLLI I STAGING TABLES -------------------- */

-- Kontrollon nëse staging është bosh apo jo.
SELECT COUNT(*) AS StagingWorldBankRows
FROM Staging_WorldBank;

SELECT COUNT(*) AS StagingKaggleRows
FROM Staging_Kaggle;
GO


/* -------------------- MBUSHJA E STAGING_WORLDBANK -------------------- */

-- Fut të dhënat nga tabela burimore në staging.
-- Kjo është pjesë e ETL (Load fillestar).
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

-- Transformon dataset-in Kaggle në format Category + Value.
-- Kjo e bën më fleksibël për analiza.

-- GDP per capita
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

-- Population
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

-- Share of GDP
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


/* -------------------- VERIFIKIMI PAS STAGING -------------------- */

-- Kontrollon sa rreshta janë futur.
SELECT COUNT(*) AS WorldBankStageRows
FROM Staging_WorldBank;

SELECT COUNT(*) AS KaggleStageRows
FROM Staging_Kaggle;

-- Shfaq mostra për kontroll vizual.
SELECT TOP 10 *
FROM Staging_WorldBank;

SELECT TOP 10 *
FROM Staging_Kaggle;
GO


/* -------------------- KONTROLLI I PERPUTHJES -------------------- */

-- Kontrollon nëse emrat e shteteve përputhen mes dataset-eve.
SELECT DISTINCT Country_Name
FROM Staging_Kaggle;

SELECT DISTINCT Country_Name
FROM DimCountry;
GO