USE BigDataProject;
GO
-- po zgjedhim databazën ku ndodhen tabelat tona (Data Warehouse)

 /* =========================================================
   PERFORMANCE OPTIMIZATION (BONUS)
   ========================================================= */

-- Index për përmirësim performance në query analitike
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_FactEconomicData_Keys')
-- kontrollon nëse ekziston një index me këtë emër në databazë
BEGIN
    CREATE NONCLUSTERED INDEX idx_FactEconomicData_Keys
    ON FactEconomicData (CountryKey, IndicatorKey, TimeKey);
    -- krijon një index në tabelën FactEconomicData mbi këto kolona
    -- këto janë foreign keys që përdoren shpesh në JOIN
    -- indexi ndihmon që query-t të ekzekutohen më shpejt (performance më e mirë)
END;
GO

/* =========================================================
   VIEW 1 – Country Year Trend Analysis
   ========================================================= */

CREATE OR ALTER VIEW vw_CountryYearTrend
-- krijon një view (si tabelë virtuale që ruan një query)
AS
SELECT 
    dc.Country_Name,
    -- emri i shtetit nga dimension table

    dt.[Year],
    -- viti nga dimensioni Time

    AVG(f.Value) AS AvgValue
    -- mesatarja e vlerave për atë shtet dhe vit
FROM FactEconomicData f
-- fact table (ruan vlerat numerike)

JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
-- lidh fact me dimension Country

JOIN DimTime dt ON f.TimeKey = dt.TimeKey
-- lidh fact me dimension Time

GROUP BY dc.Country_Name, dt.[Year];
-- grupimi sipas shtetit dhe vitit për me llogarit AVG
GO

/* =========================================================
   VIEW 2 – Indicator Trend Analysis
   ========================================================= */

CREATE OR ALTER VIEW vw_IndicatorTrend
AS
SELECT 
    di.Indicator_Name,
    -- emri i indikatorit (GDP, etj.)

    dt.[Year],
    -- viti

    AVG(f.Value) AS AvgValue
    -- mesatarja e vlerave për atë indikator dhe vit
FROM FactEconomicData f

JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
-- lidh me dimension Indicator

JOIN DimTime dt ON f.TimeKey = dt.TimeKey
-- lidh me dimension Time

GROUP BY di.Indicator_Name, dt.[Year];
-- grupim për analizë trendi të indikatorëve ndër vite
GO

/* =========================================================
   VIEW 3 – WorldBank vs Kaggle Comparison
   ========================================================= */

CREATE OR ALTER VIEW vw_WorldBank_Kaggle_Comparison
AS
SELECT 
    dc.Country_Name,
    -- shteti

    dt.[Year],
    -- viti

    k.Category,
    -- kategoria nga dataset Kaggle

    AVG(f.Value) AS WorldBankAvg,
    -- mesatarja e të dhënave nga WorldBank (Fact table)

    AVG(k.Value) AS KaggleAvg
    -- mesatarja nga dataset Kaggle
FROM FactEconomicData f

JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
-- lidh me dimension Country

JOIN DimTime dt ON f.TimeKey = dt.TimeKey
-- lidh me dimension Time

JOIN Staging_Kaggle k 
    ON dc.Country_Name = k.Country_Name 
   AND dt.[Year] = k.[Year]
-- lidh me dataset Kaggle sipas shtetit dhe vitit

WHERE k.Value IS NOT NULL
-- merr vetëm ato rreshta ku ka vlerë në Kaggle

GROUP BY dc.Country_Name, dt.[Year], k.Category;
-- grupim për krahasim mes dy burimeve
GO

/* =========================================================
   STORED PROCEDURE 1 – Country Trend
   ========================================================= */

CREATE OR ALTER PROCEDURE sp_GetCountryTrend
    @Country NVARCHAR(255)
    -- parametër hyrës: emri i shtetit
AS
BEGIN
    SET NOCOUNT ON;
    -- ndalon mesazhet “rows affected” (për performance dhe pastërti output)

    SELECT 
        dc.Country_Name,
        dt.[Year],
        f.Value
        -- merr vlerat për çdo vit për atë shtet
    FROM FactEconomicData f

    JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN DimTime dt ON f.TimeKey = dt.TimeKey

    WHERE dc.Country_Name = @Country
    -- filter sipas shtetit që jep përdoruesi

    ORDER BY dt.[Year];
    -- rendit sipas vitit (trend kronologjik)
END;
GO

/* =========================================================
   STORED PROCEDURE 2 – Indicator Analysis
   ========================================================= */

CREATE OR ALTER PROCEDURE sp_GetIndicatorData
    @Indicator NVARCHAR(255)
    -- parametër: emri i indikatorit
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        di.Indicator_Name,
        dc.Country_Name,
        dt.[Year],
        f.Value
        -- merr vlerat sipas indikatorit, shtetit dhe vitit
    FROM FactEconomicData f

    JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN DimTime dt ON f.TimeKey = dt.TimeKey

    WHERE di.Indicator_Name = @Indicator
    -- filter sipas indikatorit

    ORDER BY dc.Country_Name, dt.[Year];
    -- rendit sipas shtetit dhe vitit
END;
GO

/* =========================================================
   TESTIMI I VIEW
   ========================================================= */

SELECT TOP 20 * FROM vw_CountryYearTrend;
-- teston view 1 (trend për shtet dhe vit)

SELECT TOP 20 * FROM vw_IndicatorTrend;
-- teston view 2 (trend për indikator)

SELECT TOP 20 * FROM vw_WorldBank_Kaggle_Comparison;
-- teston view 3 (krahasim dy datasets)
GO

/* =========================================================
   TESTIMI I STORED PROCEDURES
   ========================================================= */

EXEC sp_GetCountryTrend 'Germany';
-- ekzekuton procedurën për një shtet specifik

EXEC sp_GetIndicatorData 'GDP growth';
-- ekzekuton procedurën për një indikator
GO