USE BigDataProject;
GO

/* =========================================================
   PERFORMANCE OPTIMIZATION (BONUS)
   ========================================================= */

-- Index për përmirësim performance në query analitike
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_FactEconomicData_Keys')
BEGIN
    CREATE NONCLUSTERED INDEX idx_FactEconomicData_Keys
    ON FactEconomicData (CountryKey, IndicatorKey, TimeKey);
END;
GO


/* =========================================================
   VIEW 1 – Country Year Trend Analysis
   ========================================================= */

CREATE OR ALTER VIEW vw_CountryYearTrend
AS
SELECT 
    dc.Country_Name,
    dt.[Year],
    AVG(f.Value) AS AvgValue
FROM FactEconomicData f
JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
GROUP BY dc.Country_Name, dt.[Year];
GO


/* =========================================================
   VIEW 2 – Indicator Trend Analysis
   ========================================================= */

CREATE OR ALTER VIEW vw_IndicatorTrend
AS
SELECT 
    di.Indicator_Name,
    dt.[Year],
    AVG(f.Value) AS AvgValue
FROM FactEconomicData f
JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
GROUP BY di.Indicator_Name, dt.[Year];
GO


/* =========================================================
   VIEW 3 – WorldBank vs Kaggle Comparison
   ========================================================= */

CREATE OR ALTER VIEW vw_WorldBank_Kaggle_Comparison
AS
SELECT 
    dc.Country_Name,
    dt.[Year],
    k.Category,
    AVG(f.Value) AS WorldBankAvg,
    AVG(k.Value) AS KaggleAvg
FROM FactEconomicData f
JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
JOIN Staging_Kaggle k 
    ON dc.Country_Name = k.Country_Name 
   AND dt.[Year] = k.[Year]
WHERE k.Value IS NOT NULL
GROUP BY dc.Country_Name, dt.[Year], k.Category;
GO


/* =========================================================
   STORED PROCEDURE 1 – Country Trend
   ========================================================= */

CREATE OR ALTER PROCEDURE sp_GetCountryTrend
    @Country NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        dc.Country_Name,
        dt.[Year],
        f.Value
    FROM FactEconomicData f
    JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    WHERE dc.Country_Name = @Country
    ORDER BY dt.[Year];
END;
GO


/* =========================================================
   STORED PROCEDURE 2 – Indicator Analysis
   ========================================================= */

CREATE OR ALTER PROCEDURE sp_GetIndicatorData
    @Indicator NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        di.Indicator_Name,
        dc.Country_Name,
        dt.[Year],
        f.Value
    FROM FactEconomicData f
    JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    WHERE di.Indicator_Name = @Indicator
    ORDER BY dc.Country_Name, dt.[Year];
END;
GO


/* =========================================================
   TESTIMI I VIEW
   ========================================================= */

SELECT TOP 20 * FROM vw_CountryYearTrend;
SELECT TOP 20 * FROM vw_IndicatorTrend;
SELECT TOP 20 * FROM vw_WorldBank_Kaggle_Comparison;
GO


/* =========================================================
   TESTIMI I STORED PROCEDURES
   ========================================================= */

EXEC sp_GetCountryTrend 'Germany';
EXEC sp_GetIndicatorData 'GDP growth';
GO