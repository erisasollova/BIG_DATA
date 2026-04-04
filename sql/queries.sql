USE BigDataProject;
GO

-- Query 1: Mesatarja e vlerës sipas shtetit
SELECT 
    dc.Country_Name, 
    AVG(f.Value) AS AvgValue
FROM FactEconomicData f
JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
GROUP BY dc.Country_Name
ORDER BY AvgValue DESC;

-- Query 2: Trendi sipas viteve
SELECT 
    dt.[Year], 
    AVG(f.Value) AS AvgValuePerYear
FROM FactEconomicData f
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
GROUP BY dt.[Year]
ORDER BY dt.[Year];

-- Query 3: Mesatarja sipas indikatorit
SELECT 
    di.Indicator_Name, 
    AVG(f.Value) AS AvgIndicatorValue
FROM FactEconomicData f
JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
GROUP BY di.Indicator_Name
ORDER BY AvgIndicatorValue DESC;

-- Query 4: Top 10 vendet për një indikator në vitin 2023
SELECT TOP 10
    dc.Country_Name,
    di.Indicator_Name,
    dt.[Year],
    f.Value
FROM FactEconomicData f
JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
WHERE dt.[Year] = 2023
ORDER BY f.Value DESC;

-- Query 5: Krahasim me dataset-in e Kaggle (Data Integration)
SELECT 
    dc.Country_Name,
    k.Category,
    AVG(f.Value) AS AvgWorldBankValue,
    AVG(k.Value) AS AvgKaggleValue
FROM FactEconomicData f
JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
JOIN Staging_Kaggle k ON dc.Country_Name = k.Country_Name AND dt.[Year] = k.[Year]
WHERE dt.[Year] = 2023
GROUP BY dc.Country_Name, k.Category
ORDER BY dc.Country_Name;
GO