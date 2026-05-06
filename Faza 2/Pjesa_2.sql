USE BigDataProject;
GO

-- =========================================
-- KRIJIMI I XML VARIABLËS
-- =========================================
DECLARE @xml XML;
-- Këtu krijohet një “kuti” (variable) ku do ruhet XML-i që e gjenerojmë nga SQL

-- =========================================
-- KONVERTIMI NGA DATA WAREHOUSE NË XML
-- =========================================
SET @xml = (
    SELECT 
        dc.Country_Name AS [country],
        -- marrim emrin e shtetit dhe e kthejmë në tag XML <country>

        dt.[Year] AS [year],
        -- marrim vitin dhe e kthejmë në <year>

        di.Indicator_Name AS [indicator],
        -- marrim indikatorin ekonomik (GDP, inflacion, etj.)

        f.Value AS [value]
        -- marrim vlerën numerike nga fact table

    FROM FactEconomicData f
    -- tabela kryesore ku ruhen të dhënat numerike

    INNER JOIN DimCountry dc ON f.CountryKey = dc.CountryKey
    -- lidh faktin me shtetin (dimensioni Country)

    INNER JOIN DimIndicator di ON f.IndicatorKey = di.IndicatorKey
    -- lidh faktin me indikatorin ekonomik

    INNER JOIN DimTime dt ON f.TimeKey = dt.TimeKey
    -- lidh faktin me kohën (vitet)

    FOR XML PATH('record'), ROOT('economic_data'), TYPE
    -- çdo rresht bëhet <record>
    -- të gjitha record-et futen brenda <economic_data>
    -- TYPE e mban si XML real (jo tekst)
);

-- =========================================
-- SHFAQJA E XML-it TË GJENERUAR
-- =========================================
SELECT @xml AS Economic_Data;
-- këtu shohim komplet XML-in që u krijua

-- =========================================
-- XPATH 1 – MARRJA E SHTETEVE
-- =========================================
SELECT @xml.query('/economic_data/record/country') AS Countries;
-- shkon në XML dhe merr vetëm tag-un <country>
-- pra listë e shteteve

-- =========================================
-- XPATH 2 – FILTRIM SIPAS VITIT 2023
-- =========================================
SELECT @xml.query('/economic_data/record[year=2023]') AS Records_2023;
-- merr vetëm record-et ku viti është 2023
-- si WHERE në SQL

-- =========================================
-- XQUERY 1 – FILTRIM (si WHERE)
-- =========================================
SELECT @xml.query('
for $x in /economic_data/record
-- kalon në çdo record një nga një

where $x/year = 2023
-- merr vetëm ato që janë të vitit 2023

return 
<result>
    {$x/country}
    -- shfaq shtetin

    {$x/value}
    -- shfaq vlerën
</result>
') AS Filtered_2023;

-- =========================================
-- XQUERY 2 – TRANSFORMIM I STRUKTURËS
-- =========================================
SELECT @xml.query('
for $x in /economic_data/record
-- kalon në çdo record

return 
<country_data>
    <name>{data($x/country)}</name>
    -- merr tekstin e country dhe e ndryshon emrin në "name"

    <year>{data($x/year)}</year>
    -- merr vitin si tekst të thjeshtë
</country_data>
') AS Transformed_XML;

-- =========================================
-- XQUERY 3 – NXJERRJA E INDIKATORËVE
-- =========================================
SELECT @xml.query('
for $x in /economic_data/record
-- kalon në çdo record

return 
<indicator>
    {data($x/indicator)}
    -- merr vetëm emrin e indikatorit
</indicator>
') AS Indicators;

-- =========================================
-- BONUS – FILTRIM PËR NJË SHTET SPECIFIK
-- =========================================
SELECT @xml.query('
for $x in /economic_data/record
-- kalon në çdo record

where $x/country = "Albania"
-- merr vetëm Shqipërinë

return 
<country_data>
    {$x/year}
    -- shfaq vitin

    {$x/value}
    -- shfaq vlerën
</country_data>
') AS Albania_Data;