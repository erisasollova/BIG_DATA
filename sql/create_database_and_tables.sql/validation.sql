-- =============================================
-- FILE: validation.sql
-- =============================================
-- KY FILE PERMBUSH KETO KERKESA TE PROJEKTIT:
-- 1. Verifikimi i te dhenave ne staging
-- 2. Verifikimi i te dhenave ne DWH
-- 3. Kontrolli i strukturave te databazes
--
-- IDEJA KRYESORE:
-- Ky file perdoret per kontroll final.
-- Ai tregon:
-- - sa rreshta ka staging
-- - sa rreshta ka fact table
-- - nese databaza aktive eshte e sakte
-- - cilat tabela ekzistojne ne sistem
-- =============================================


-- Siguron qe po punon ne databazen e projektit.
USE BigDataProject;
GO


-- Numron sa rreshta jane ne Staging_WorldBank.
-- Kjo tregon sa te dhena raw jane futur nga World Bank.
SELECT COUNT(*) AS TotalRows
FROM Staging_WorldBank;


-- Numron sa rreshta jane ne FactEconomicData.
-- Kjo ndihmon me kontrollu nese load-i ne fact table kryesore eshte bere.
SELECT COUNT(*) AS FactRows
FROM FactEconomicData;


-- Numron sa rreshta jane ne FactTrendAnalysis.
-- Kjo tregon nese tabela e trendeve eshte mbushur.
SELECT COUNT(*) AS TrendRows
FROM FactTrendAnalysis;


-- Shfaq 10 rreshtat e pare nga FactTrendAnalysis.
-- Perdoret per kontroll vizual te mesatareve sipas shtetit dhe vitit.
SELECT TOP 10 * FROM FactTrendAnalysis;


-- Kthen emrin e databazes aktuale ku po ekzekutohen komandat.
-- Kjo ndihmon per t'u siguruar qe nuk je ne databaze tjeter gabimisht.
SELECT DB_NAME() AS CurrentDB;


-- Liston emrat e te gjitha tabelave baze ne databaze.
-- INFORMATION_SCHEMA.TABLES eshte pamje sistemore e SQL Server-it.
-- Kjo query ndihmon me pa nese tabelat jane krijuar si duhet.
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';