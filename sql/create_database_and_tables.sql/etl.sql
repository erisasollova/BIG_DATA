USE BigDataProject;
GO

CREATE OR ALTER PROCEDURE sp_LoadDWH
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------
    -- LOAD DIMENSIONS
    ---------------------------------------------------
    INSERT INTO DimCountry (Country_Code, Country_Name)
    SELECT DISTINCT Country_Code, Country_Name
    FROM Staging_WorldBank s
    WHERE NOT EXISTS (
        SELECT 1 FROM DimCountry d
        WHERE d.Country_Code = s.Country_Code
    );

    INSERT INTO DimIndicator (Indicator_Code, Indicator_Name)
    SELECT DISTINCT Indicator_Code, Indicator_Name
    FROM Staging_WorldBank s
    WHERE NOT EXISTS (
        SELECT 1 FROM DimIndicator d
        WHERE d.Indicator_Code = s.Indicator_Code
    );

    INSERT INTO DimTime (TimeKey, [Year])
    SELECT DISTINCT [Year], [Year]
    FROM Staging_WorldBank s
    WHERE NOT EXISTS (
        SELECT 1 FROM DimTime d
        WHERE d.[Year] = s.[Year]
    );

    ---------------------------------------------------
    -- LOAD FACT ECONOMIC DATA
    ---------------------------------------------------
    INSERT INTO FactEconomicData (CountryKey, IndicatorKey, TimeKey, Value)
    SELECT
        dc.CountryKey,
        di.IndicatorKey,
        dt.TimeKey,
        s.Value
    FROM Staging_WorldBank s
    JOIN DimCountry dc ON s.Country_Code = dc.Country_Code
    JOIN DimIndicator di ON s.Indicator_Code = di.Indicator_Code
    JOIN DimTime dt ON s.[Year] = dt.[Year]
    WHERE NOT EXISTS (
        SELECT 1
        FROM FactEconomicData f
        WHERE f.CountryKey = dc.CountryKey
          AND f.IndicatorKey = di.IndicatorKey
          AND f.TimeKey = dt.TimeKey
    );

    ---------------------------------------------------
    -- LOAD FACT TREND ANALYSIS
    ---------------------------------------------------
    INSERT INTO FactTrendAnalysis (CountryKey, TimeKey, AvgValue)
    SELECT
        dc.CountryKey,
        dt.TimeKey,
        AVG(s.Value)
    FROM Staging_WorldBank s
    JOIN DimCountry dc ON s.Country_Code = dc.Country_Code
    JOIN DimTime dt ON s.[Year] = dt.[Year]
    GROUP BY dc.CountryKey, dt.TimeKey
    HAVING NOT EXISTS (
        SELECT 1
        FROM FactTrendAnalysis f
        WHERE f.CountryKey = dc.CountryKey
          AND f.TimeKey = dt.TimeKey
    );
END;
GO