USE BigDataProject;
GO

-- =========================================
-- DEKLARIMI I XML
-- =========================================
DECLARE @xml XML;

-- =========================================
-- GJENERIMI I XML NGA DATA WAREHOUSE
-- =========================================
SET @xml = (
    SELECT 
        dc.Country_Name AS [country],
        dt.[Year] AS [year],
        di.Indicator_Name AS [indicator],
        f.Value AS [value]
    FROM FactEconomicData f
    INNER JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    INNER JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    INNER JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    FOR XML PATH('record'), ROOT('economic_data'), TYPE
);

-- =========================================
-- SHFAQJA E XML
-- =========================================
SELECT @xml AS Economic_Data;

-- =========================================
-- ✅ XPath 1 – Marrja e të gjitha shteteve
-- =========================================
-- =========================================
-- DEKLARIMI I XML
-- =========================================
DECLARE @xml XML;

-- =========================================
-- GJENERIMI I XML NGA DATA WAREHOUSE
-- =========================================
SET @xml = (
    SELECT 
        dc.Country_Name AS [country],
        dt.[Year] AS [year],
        di.Indicator_Name AS [indicator],
        f.Value AS [value]
    FROM FactEconomicData f
    INNER JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    INNER JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    INNER JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    FOR XML PATH('record'), ROOT('economic_data'), TYPE
);


SELECT @xml.query('/economic_data/record/country') AS Countries;

-- =========================================
-- ✅ XPath 2 – Filtrimi për vitin 2023
-- =========================================
-- =========================================
-- DEKLARIMI I XML
-- =========================================
DECLARE @xml XML;

-- =========================================
-- GJENERIMI I XML NGA DATA WAREHOUSE
-- =========================================
SET @xml = (
    SELECT 
        dc.Country_Name AS [country],
        dt.[Year] AS [year],
        di.Indicator_Name AS [indicator],
        f.Value AS [value]
    FROM FactEconomicData f
    INNER JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    INNER JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    INNER JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    FOR XML PATH('record'), ROOT('economic_data'), TYPE
);



SELECT @xml.query('/economic_data/record[year=2023]') AS Records_2023;

-- =========================================
-- ✅ XQuery 1 – Filtrim (si WHERE)
-- =========================================
-- =========================================
-- DEKLARIMI I XML
-- =========================================
DECLARE @xml XML;

-- =========================================
-- GJENERIMI I XML NGA DATA WAREHOUSE
-- =========================================
SET @xml = (
    SELECT 
        dc.Country_Name AS [country],
        dt.[Year] AS [year],
        di.Indicator_Name AS [indicator],
        f.Value AS [value]
    FROM FactEconomicData f
    INNER JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    INNER JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    INNER JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    FOR XML PATH('record'), ROOT('economic_data'), TYPE
);




SELECT @xml.query('
for $x in /economic_data/record
where $x/year = 2023
return 
<result>
    {$x/country}
    {$x/value}
</result>
') AS Filtered_2023;

-- =========================================
-- ✅ XQuery 2 – Transformim (strukturë e re)
-- =========================================
-- =========================================
-- DEKLARIMI I XML
-- =========================================
DECLARE @xml XML;

-- =========================================
-- GJENERIMI I XML NGA DATA WAREHOUSE
-- =========================================
SET @xml = (
    SELECT 
        dc.Country_Name AS [country],
        dt.[Year] AS [year],
        di.Indicator_Name AS [indicator],
        f.Value AS [value]
    FROM FactEconomicData f
    INNER JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    INNER JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    INNER JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    FOR XML PATH('record'), ROOT('economic_data'), TYPE
);



SELECT @xml.query('
for $x in /economic_data/record
return 
<country_data>
    <name>{data($x/country)}</name>
    <year>{data($x/year)}</year>
</country_data>
') AS Transformed_XML;

-- =========================================
-- ✅ XQuery 3 – merr vetëm indikatorët
-- =========================================
-- =========================================
-- DEKLARIMI I XML
-- =========================================
DECLARE @xml XML;

-- =========================================
-- GJENERIMI I XML NGA DATA WAREHOUSE
-- =========================================
SET @xml = (
    SELECT 
        dc.Country_Name AS [country],
        dt.[Year] AS [year],
        di.Indicator_Name AS [indicator],
        f.Value AS [value]
    FROM FactEconomicData f
    INNER JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    INNER JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    INNER JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    FOR XML PATH('record'), ROOT('economic_data'), TYPE
);



SELECT @xml.query('
for $x in /economic_data/record
return 
<indicator>
    {data($x/indicator)}
</indicator>
') AS Indicators;

-- =========================================
-- ✅ BONUS – merr vetëm një shtet
-- =========================================
-- =========================================
-- DEKLARIMI I XML
-- =========================================
DECLARE @xml XML;

-- =========================================
-- GJENERIMI I XML NGA DATA WAREHOUSE
-- =========================================
SET @xml = (
    SELECT 
        dc.Country_Name AS [country],
        dt.[Year] AS [year],
        di.Indicator_Name AS [indicator],
        f.Value AS [value]
    FROM FactEconomicData f
    INNER JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    INNER JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    INNER JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    FOR XML PATH('record'), ROOT('economic_data'), TYPE
);


SELECT @xml.query('
for $x in /economic_data/record
where $x/country = "Albania"
return 
<country_data>
    {$x/year}
    {$x/value}
</country_data>
') AS Albania_Data;