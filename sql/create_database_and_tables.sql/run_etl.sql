USE BigDataProject;
GO

-- =============================================
-- FUTJA E TE DHENAVE NE STAGING (SHUME E RENDESISHME)
-- =============================================
INSERT INTO Staging_WorldBank
(
    Country_Name,
    Country_Code,
    Indicator_Name,
    Indicator_Code,
    [Year],
    Value
)
SELECT
    Country_Name,
    Country_Code,
    Indicator_Name,
    Indicator_Code,
    [Year],
    Value
FROM WorldBankDataBase;

-- =============================================
-- EKZEKUTIMI I ETL
-- =============================================
EXEC sp_LoadDWH;