-- =============================================
-- FILE: dwh.sql
-- =============================================
-- KY FILE PERMBUSH KETO KERKESA TE PROJEKTIT:
-- 1. Pjesa 2 - Data Warehouse
--    -> ndertimi i Data Warehouse me Star Schema
-- 2. Krijimi i dimension tables
-- 3. Krijimi i fact tables
-- 4. Perdorimi i dimensionit te perbashket (p.sh. DimTime, DimCountry)
--
-- IDEJA KRYESORE:
-- Ky file krijon strukturen analitike te projektit.
-- Ketu kalojme nga raw/staging ne model analitik.
-- Pjeset kryesore jane:
-- - Dimension Tables: ruajne pershkrime
-- - Fact Tables: ruajne vlera numerike per analiza
-- =============================================


-- Siguron qe i gjithe ky kod po ekzekutohet ne databazen e duhur.
USE BigDataProject;
GO


-- =============================================
-- DIMENSIONS
-- =============================================

-- Krijon dimensionin e shteteve.
-- Kjo tabele ruan informacion pershkrues per shtetet
-- dhe eshte pjese e Star Schema.
CREATE TABLE DimCountry (

    -- CountryKey eshte surrogate key.
    -- IDENTITY(1,1) ben qe SQL Server ta gjeneroje automatikisht:
    -- 1, 2, 3, 4...
    -- Kjo perdoret si primary key dhe lidhet me fact tables.
    CountryKey INT IDENTITY(1,1) PRIMARY KEY,

    -- Country_Code duhet te jete unik.
    -- Kjo ndihmon qe i njejti shtet te mos futet dy here ne dimension.
    Country_Code NVARCHAR(50) UNIQUE,

    -- Country_Name ruan emrin e shtetit.
    -- Ky eshte atribut pershkrues i dimensionit.
    Country_Name NVARCHAR(255)
);


-- Krijon dimensionin e indikatorëve ekonomikë.
-- Kjo tabele ruan informacion pershkrues per indikatorin:
-- emrin dhe kodin e tij.
CREATE TABLE DimIndicator (

    -- IndicatorKey eshte surrogate key per dimensionin e indikatorit.
    -- Gjenerohet automatikisht nga SQL Server.
    IndicatorKey INT IDENTITY(1,1) PRIMARY KEY,

    -- Kodi i indikatorit duhet te jete unik,
    -- ne menyre qe nje indikator te mos ruhet dy here.
    Indicator_Code NVARCHAR(100) UNIQUE,

    -- Emri i indikatorit, p.sh. GDP growth, population total etj.
    Indicator_Name NVARCHAR(255)
);


-- Krijon dimensionin kohor.
-- Ne kete projekt, dimensioni kohor eshte i thjeshtuar ne nivel viti.
-- Pra nuk kemi muaj, dite, quarter etj., vetem Year.
CREATE TABLE DimTime (

    -- TimeKey eshte primary key e dimensionit kohor.
    -- Ne projektin tuaj kjo zakonisht eshte e barabarte me vete vitin.
    TimeKey INT PRIMARY KEY,

    -- Kolona e vitit.
    -- UNIQUE garanton qe i njejti vit te mos futet dy here.
    [Year] SMALLINT UNIQUE
);


-- =============================================
-- FACT TABLES
-- =============================================

-- Krijon tabelen kryesore faktike te DWH.
-- Kjo tabele ruan vleren e indikatorit per nje shtet dhe nje vit.
-- Pra eshte qendra e Star Schema.
CREATE TABLE FactEconomicData (

    -- FactID eshte identifikues teknik unik per cdo rresht.
    -- Edhe pse logjikisht rreshti identifikohet nga Country+Indicator+Time,
    -- ky ID eshte praktik per administrim dhe reference.
    FactID INT IDENTITY(1,1) PRIMARY KEY,

    -- Foreign key qe lidhet me dimensionin e shtetit.
    CountryKey INT,

    -- Foreign key qe lidhet me dimensionin e indikatorit.
    IndicatorKey INT,

    -- Foreign key qe lidhet me dimensionin e kohes.
    TimeKey INT,

    -- Vlera numerike reale e indikatorit ekonomik.
    Value FLOAT,

    -- Kjo foreign key siguron qe CountryKey ne fact
    -- duhet te ekzistoje paraprakisht ne DimCountry.
    FOREIGN KEY (CountryKey) REFERENCES DimCountry(CountryKey),

    -- Kjo foreign key siguron integritet per indikatorin.
    FOREIGN KEY (IndicatorKey) REFERENCES DimIndicator(IndicatorKey),

    -- Kjo foreign key siguron integritet per kohen/vitin.
    FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey)
);


-- Krijon nje tabele te dyte faktike per analiza trendeve.
-- Kjo ruan mesatare sipas shtetit dhe vitit.
-- Pra eshte nje fakt me i agreguar se FactEconomicData.
CREATE TABLE FactTrendAnalysis (

    -- Identifikues unik teknik i rreshtit.
    FactID INT IDENTITY(1,1) PRIMARY KEY,

    -- Lidhje me shtetin.
    CountryKey INT,

    -- Lidhje me kohen.
    TimeKey INT,

    -- AvgValue ruan mesataren e vlerave per ate shtet dhe ate vit.
    AvgValue FLOAT,

    -- Ruhet integriteti me DimCountry.
    FOREIGN KEY (CountryKey) REFERENCES DimCountry(CountryKey),

    -- Ruhet integriteti me DimTime.
    FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey)
);