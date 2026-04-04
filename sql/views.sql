-- View 1: Mesataret vjetore për shtet
CREATE OR ALTER VIEW vw_CountryYearlyAverage
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

-- View 2: Analiza e indikatorëve sipas viteve
CREATE OR ALTER VIEW vw_IndicatorAnalysis
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

-- View 3: Integrimi i plotë me Kaggle
CREATE OR ALTER VIEW vw_KaggleComparison
AS
SELECT 
    dc.Country_Name,
    dt.[Year],
    k.Category,
    f.Value AS WorldBankValue,
    k.Value AS KaggleValue
FROM FactEconomicData f
JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
JOIN Staging_Kaggle k ON dc.Country_Name = k.Country_Name AND dt.[Year] = k.[Year];
GO