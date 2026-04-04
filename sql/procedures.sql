-- Procedure 1: Analiza specifike për një shtet
CREATE OR ALTER PROCEDURE sp_GetCountryAnalysis
    @CountryName NVARCHAR(255)
AS
BEGIN
    SELECT 
        dc.Country_Name,
        dt.[Year],
        AVG(f.Value) AS AvgValue
    FROM FactEconomicData f
    JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    WHERE dc.Country_Name = @CountryName
    GROUP BY dc.Country_Name, dt.[Year]
    ORDER BY dt.[Year];
END;
GO

-- Procedure 2: Analiza e të gjitha vendeve për një vit të caktuar
CREATE OR ALTER PROCEDURE sp_GetYearAnalysis
    @Year SMALLINT
AS
BEGIN
    SELECT 
        dc.Country_Name,
        di.Indicator_Name,
        f.Value
    FROM FactEconomicData f
    JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    WHERE dt.[Year] = @Year
    ORDER BY dc.Country_Name;
END;
GO

-- Procedure 3: Krahasimi me Kaggle për një vit specifik
CREATE OR ALTER PROCEDURE sp_CompareWithKaggle
    @Year SMALLINT
AS
BEGIN
    SELECT 
        dc.Country_Name,
        k.Category,
        f.Value AS WorldBankValue,
        k.Value AS KaggleValue
    FROM FactEconomicData f
    JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    JOIN Staging_Kaggle k ON dc.Country_Name = k.Country_Name AND dt.[Year] = k.[Year]
    WHERE dt.[Year] = @Year
    ORDER BY dc.Country_Name, k.Category;
END;
GO
-- Testimi i procedurave
EXEC sp_GetCountryAnalysis @CountryName = 'Germany';
EXEC sp_GetYearAnalysis @Year = 2023;
EXEC sp_CompareWithKaggle @Year = 2023;