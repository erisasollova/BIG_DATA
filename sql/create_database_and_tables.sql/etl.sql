-- =============================================
-- FILE: etl.sql
-- =============================================
-- KY FILE PERMBUSH KETO KERKESA TE PROJEKTIT:
-- 1. Pjesa 2 - ETL procesi
--    -> transformimi dhe integrimi i te dhenave
--    -> mbushja e dimensioneve dhe fact tables
--    -> perdorimi i procedurave per automatizim
--    -> shmangia e duplikimeve
--
-- IDEJA KRYESORE:

-- Ky file krijon stored procedure sp_LoadDWH.
-- Kjo procedure ben:
-- 1. Load te dimensioneve
-- 2. Load te fact table kryesore
-- 3. Load te fact table se trendeve
--
-- Pra kjo eshte zemra e ETL ne projekt.
-- =============================================


-- Siguron databazen e sakte.
USE BigDataProject;
GO


-- Krijon ose ndryshon proceduren sp_LoadDWH.
-- CREATE OR ALTER eshte shume praktik gjate zhvillimit,
-- sepse nese procedura ekziston, ajo thjesht perditesohet.
CREATE OR ALTER PROCEDURE sp_LoadDWH
AS
BEGIN

    -- SET NOCOUNT ON ndalon mesazhet si "(10 rows affected)".
    -- Kjo e ben output-in me te paster kur ekzekutohet procedura.
    SET NOCOUNT ON;

    ---------------------------------------------------
    -- LOAD DIMENSIONS
    ---------------------------------------------------

    -- Mbush DimCountry nga Staging_WorldBank.
    -- Merr vetem shtetet unike dhe i fut ne dimension.
    -- WHERE NOT EXISTS ben qe i njejti shtet te mos futet dy here.
    INSERT INTO DimCountry (Country_Code, Country_Name)
    SELECT DISTINCT Country_Code, Country_Name
    FROM Staging_WorldBank s
    WHERE NOT EXISTS (
        -- Ky nenquery kontrollon nese kodi i shtetit ekziston tashme ne dimension.
        -- Nese ekziston, ai rresht nuk futet perseri.
        SELECT 1 FROM DimCountry d
        WHERE d.Country_Code = s.Country_Code
    );

    -- Mbush DimIndicator nga Staging_WorldBank.
    -- Merr indikatorët unikë dhe i ruan ne dimension.
    -- Kjo eshte pjese e "Load Dimension Tables" ne ETL.
    INSERT INTO DimIndicator (Indicator_Code, Indicator_Name)
    SELECT DISTINCT Indicator_Code, Indicator_Name
    FROM Staging_WorldBank s
    WHERE NOT EXISTS (
        -- Kontrollon nese indikatori ekziston tashme.
        -- Keshtu shmangen duplikimet.
        SELECT 1 FROM DimIndicator d
        WHERE d.Indicator_Code = s.Indicator_Code
    );

    -- Mbush DimTime nga Staging_WorldBank.
    -- TimeKey dhe Year ne kete projekt jane te njejta.
    -- Pra nese viti eshte 2023, futet TimeKey = 2023 dhe Year = 2023.
    INSERT INTO DimTime (TimeKey, [Year])
    SELECT DISTINCT [Year], [Year]
    FROM Staging_WorldBank s
    WHERE NOT EXISTS (
        -- Kontrollon nese ai vit ekziston tashme ne dimensionin kohor.
        SELECT 1 FROM DimTime d
        WHERE d.[Year] = s.[Year]
    );

    ---------------------------------------------------
    -- LOAD FACT ECONOMIC DATA
    ---------------------------------------------------

    -- Kjo pjese mbush FactEconomicData.
    -- Ketu ndodh transformimi kryesor:
    -- nga raw data (Country_Code, Indicator_Code, Year)
    -- ne foreign keys (CountryKey, IndicatorKey, TimeKey).
    INSERT INTO FactEconomicData (CountryKey, IndicatorKey, TimeKey, Value)
    SELECT
        -- Merr CountryKey nga DimCountry.
        dc.CountryKey,

        -- Merr IndicatorKey nga DimIndicator.
        di.IndicatorKey,

        -- Merr TimeKey nga DimTime.
        dt.TimeKey,

        -- Merr vleren numerike nga staging.
        s.Value
    FROM Staging_WorldBank s

    -- Lidh staging me DimCountry ne baze te Country_Code.
    -- Kjo ben te mundur kthimin nga kodi i shtetit ne surrogate key.
    JOIN DimCountry dc ON s.Country_Code = dc.Country_Code

    -- Lidh staging me DimIndicator ne baze te Indicator_Code.
    -- Kjo ben te mundur kthimin nga kodi i indikatorit ne key analitik.
    JOIN DimIndicator di ON s.Indicator_Code = di.Indicator_Code

    -- Lidh staging me DimTime ne baze te vitit.
    JOIN DimTime dt ON s.[Year] = dt.[Year]

    WHERE NOT EXISTS (
        -- Ky kontrollon nese kombinimi CountryKey + IndicatorKey + TimeKey
        -- ekziston tashme ne fact table.
        -- Nese po, rreshti nuk futet perseri.
        -- Kjo e ben procesin idempotent.
        SELECT 1
        FROM FactEconomicData f
        WHERE f.CountryKey = dc.CountryKey
          AND f.IndicatorKey = di.IndicatorKey
          AND f.TimeKey = dt.TimeKey
    );

    ---------------------------------------------------
    -- LOAD FACT TREND ANALYSIS
    ---------------------------------------------------

    -- Kjo pjese mbush FactTrendAnalysis.
    -- Ketu nuk ruhet cdo indikator veqmas,
    -- por llogaritet nje mesatare sipas shtetit dhe vitit.
    INSERT INTO FactTrendAnalysis (CountryKey, TimeKey, AvgValue)
    SELECT
        -- Shteti nga dimensioni.
        dc.CountryKey,

        -- Koha/viti nga dimensioni kohor.
        dt.TimeKey,

        -- Mesatarja e vlerave per ate shtet ne ate vit.
        AVG(s.Value)
    FROM Staging_WorldBank s

    -- Lidhja me dimensionin e shtetit.
    JOIN DimCountry dc ON s.Country_Code = dc.Country_Code

    -- Lidhja me dimensionin kohor.
    JOIN DimTime dt ON s.[Year] = dt.[Year]

    -- GROUP BY i grupon rreshtat sipas shtetit dhe vitit.
    -- Brenda secilit grup llogaritet AVG(s.Value).
    GROUP BY dc.CountryKey, dt.TimeKey

    HAVING NOT EXISTS (
        -- Kontrollon nese nje rekord me te njejtin CountryKey dhe TimeKey
        -- ekziston tashme ne FactTrendAnalysis.
        -- Nese ekziston, nuk futet perseri.
        SELECT 1
        FROM FactTrendAnalysis f
        WHERE f.CountryKey = dc.CountryKey
          AND f.TimeKey = dt.TimeKey
    );
END;
GO