USE BigDataProject;
GO

/* =========================================================
   VIEW 1 – Country Year Trend Analysis
   QËLLIMI:
   Analizon trendin e indikatorëve ekonomikë për çdo shtet ndër vite.
   Përdoret për Line Charts dhe analiza të zhvillimit ekonomik.

   LOGJIKA:
   - Lidhen FactEconomicData me DimCountry dhe DimTime
   - Llogaritet mesatarja e vlerave për çdo shtet dhe vit

   REZULTATI:
   Jep trendin e zhvillimit për çdo shtet ndër vite
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
   QËLLIMI:
   Analizon performancën e indikatorëve ekonomikë ndër vite.

   LOGJIKA:
   - Lidhen FactEconomicData me DimIndicator dhe DimTime
   - Llogaritet mesatarja për çdo indikator dhe vit

   REZULTATI:
   Jep krahasim të indikatorëve ndër vite
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
   QËLLIMI:
   Krahasimi i të dhënave nga WorldBank me dataset-in Kaggle.

   LOGJIKA:
   - Bashkohen FactEconomicData me Staging_Kaggle
   - Krahasohen vlerat sipas shtetit, vitit dhe kategorisë

   REZULTATI:
   Jep krahasim analitik ndërmjet burimeve të ndryshme të të dhënave
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
GROUP BY dc.Country_Name, dt.[Year], k.Category;
GO


/* =========================================================
   STORED PROCEDURE 1 – Country Trend
   QËLLIMI:
   Merr trendin e një shteti të caktuar ndër vite.

   LOGJIKA:
   Filtron sipas emrit të shtetit dhe kthen vlerat sipas viteve.

   PERDORIM:
   EXEC sp_GetCountryTrend 'Germany';
========================================================= */

CREATE OR ALTER PROCEDURE sp_GetCountryTrend
    @Country NVARCHAR(255)
AS
BEGIN
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
   QËLLIMI:
   Merr të dhënat për një indikator specifik për të gjitha shtetet.

   LOGJIKA:
   Filtron sipas indikatorit dhe shfaq vlerat sipas shtetit.

   PERDORIM:
   EXEC sp_GetIndicatorData 'GDP growth';
========================================================= */

CREATE OR ALTER PROCEDURE sp_GetIndicatorData
    @Indicator NVARCHAR(255)
AS
BEGIN
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