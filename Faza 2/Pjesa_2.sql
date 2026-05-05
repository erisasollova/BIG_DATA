USE BigDataProjectTEST;
GO

/* =========================================================
   VIEW 1 – Country Year Trend
========================================================= */
CREATE OR ALTER VIEW dbo.vw_CountryYearTrend
AS
SELECT 
    dc.Country_Name,
    dt.[Year],
    AVG(f.Value) AS AvgValue
FROM dbo.FactEconomicData f
JOIN dbo.DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN dbo.DimTime dt ON f.TimeKey = dt.TimeKey
GROUP BY dc.Country_Name, dt.[Year];
GO


/* =========================================================
   VIEW 2 – Indicator Trend
========================================================= */
CREATE OR ALTER VIEW dbo.vw_IndicatorTrend
AS
SELECT 
    di.Indicator_Name,
    dt.[Year],
    AVG(f.Value) AS AvgValue
FROM dbo.FactEconomicData f
JOIN dbo.DimIndicator di ON f.IndicatorKey = di.IndicatorKey
JOIN dbo.DimTime dt ON f.TimeKey = dt.TimeKey
GROUP BY di.Indicator_Name, dt.[Year];
GO


/* =========================================================
   VIEW 3 – WorldBank vs Kaggle Comparison
========================================================= */
CREATE OR ALTER VIEW dbo.vw_WorldBank_Kaggle_Comparison
AS
SELECT 
    dc.Country_Name,
    dt.[Year],
    k.Category,
    AVG(f.Value) AS WorldBankAvg,
    AVG(k.Value) AS KaggleAvg
FROM dbo.FactEconomicData f
JOIN dbo.DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN dbo.DimTime dt ON f.TimeKey = dt.TimeKey
JOIN dbo.Staging_Kaggle k 
    ON dc.Country_Name = k.Country_Name
   AND dt.[Year] = k.[Year]
GROUP BY dc.Country_Name, dt.[Year], k.Category;
GO


/* =========================================================
   STORED PROCEDURE 1 – Country Trend
========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_GetCountryTrend
    @Country NVARCHAR(255)
AS
BEGIN
    SELECT 
        dc.Country_Name,
        dt.[Year],
        AVG(f.Value) AS AvgValue
    FROM dbo.FactEconomicData f
    JOIN dbo.DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN dbo.DimTime dt ON f.TimeKey = dt.TimeKey
    WHERE dc.Country_Name = @Country
    GROUP BY dc.Country_Name, dt.[Year]
    ORDER BY dt.[Year];
END;
GO


/* =========================================================
   STORED PROCEDURE 2 – Indicator Data
========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_GetIndicatorData
    @Indicator NVARCHAR(255)
AS
BEGIN
    SELECT 
        di.Indicator_Name,
        dc.Country_Name,
        dt.[Year],
        f.Value
    FROM dbo.FactEconomicData f
    JOIN dbo.DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    JOIN dbo.DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN dbo.DimTime dt ON f.TimeKey = dt.TimeKey
    WHERE di.Indicator_Name = @Indicator
    ORDER BY dc.Country_Name, dt.[Year];
END;
GO


/* =========================================================
   TEST QUERIES
========================================================= */

SELECT TOP 20 * FROM dbo.vw_CountryYearTrend;
SELECT TOP 20 * FROM dbo.vw_IndicatorTrend;
SELECT TOP 20 * FROM dbo.vw_WorldBank_Kaggle_Comparison;
GO


/* =========================================================
   TEST PROCEDURES
========================================================= */

EXEC dbo.sp_GetCountryTrend 'Germany';
EXEC dbo.sp_GetIndicatorData 'GDP growth';
GO


/* =========================================================
   CHECK TABLES (DEBUG)
========================================================= */

SELECT * 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'Staging_Kaggle';
GO