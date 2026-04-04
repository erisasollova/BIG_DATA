USE BigDataProject;
GO

-- =============================================
-- DIMENSIONS
-- =============================================
CREATE TABLE DimCountry (
    CountryKey INT IDENTITY(1,1) PRIMARY KEY,
    Country_Code NVARCHAR(50) UNIQUE,
    Country_Name NVARCHAR(255)
);

CREATE TABLE DimIndicator (
    IndicatorKey INT IDENTITY(1,1) PRIMARY KEY,
    Indicator_Code NVARCHAR(100) UNIQUE,
    Indicator_Name NVARCHAR(255)
);

CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY,
    [Year] SMALLINT UNIQUE
);

-- =============================================
-- FACT TABLES
-- =============================================
CREATE TABLE FactEconomicData (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    CountryKey INT,
    IndicatorKey INT,
    TimeKey INT,
    Value FLOAT,
    FOREIGN KEY (CountryKey) REFERENCES DimCountry(CountryKey),
    FOREIGN KEY (IndicatorKey) REFERENCES DimIndicator(IndicatorKey),
    FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey)
);

CREATE TABLE FactTrendAnalysis (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    CountryKey INT,
    TimeKey INT,
    AvgValue FLOAT,
    FOREIGN KEY (CountryKey) REFERENCES DimCountry(CountryKey),
    FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey)
);