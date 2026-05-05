-- =============================================
-- FILE: create_database_and_tables.sql
-- =============================================
-- KY FILE PERMBUSH KETO KERKESA TE PROJEKTIT:
-- 1. Pjesa 1 - Importimi dhe analiza fillestare
--    -> sepse krijon STAGING TABLES ku futen te dhenat raw/fillestare
-- 2. Pjesa 2 - Data Warehouse
--    -> sepse krijon databazen baze ku do ndertohet projekti
-- 3. Kerkesat teknike
--    -> perdor SQL Server dhe organizim te strukturuar te te dhenave
--
-- IDEJA KRYESORE:
-- Fillimisht krijohet databaza e projektit.
-- Pastaj krijohen tabelat STAGING, te cilat sherbejne si zone e perkohshme
-- ku ruhen te dhenat raw para se te kalojne ne Data Warehouse.
-- =============================================


-- Krijon databazen kryesore te projektit me emrin BigDataProject.
-- Kjo eshte "container" kryesor ku do ruhen tabelat, procedurat,
-- fact tables, dimension tables dhe objektet e tjera te projektit.
CREATE DATABASE BigDataProject;
GO


-- I tregon SQL Server-it qe nga ky moment komandat e metejshme
-- duhet te ekzekutohen pikerisht ne databazen BigDataProject.
-- Pa kete komande, tabelat mund te krijoheshin gabimisht ne databaze tjeter.
USE BigDataProject;
GO


-- Krijon tabelen Staging_WorldBank.
-- Kjo nuk eshte ende pjese e Data Warehouse final,
-- por nje tabele e perkohshme / ndermjetese ku futen te dhenat raw nga World Bank.
-- Ne ETL, kjo tabele sherben si pika fillestare para transformimit.
CREATE TABLE Staging_WorldBank (

    -- Emri i shtetit, p.sh. Kosovo, Albania, Germany.
    -- NVARCHAR perdoret sepse kemi tekst dhe mund te kete karaktere te ndryshme.
    Country_Name NVARCHAR(255),

    -- Kodi i shtetit, p.sh. ALB, USA, XKX.
    -- Ky kod eshte me i qendrueshem se emri dhe perdoret per identifikim.
    Country_Code NVARCHAR(50),

    -- Emri i indikatorit ekonomik, p.sh. GDP, Inflation, Population.
    -- Ky eshte pershkrim tekstual i indikatorit.
    Indicator_Name NVARCHAR(255),

    -- Kodi unik i indikatorit.
    -- Ky perdoret me shpesh ne ETL sepse eshte me i sigurt per identifikim se sa emri.
    Indicator_Code NVARCHAR(100),

    -- Viti per te cilin vlen indikatori.
    -- SMALLINT mjafton sepse viti eshte numer i vogel si 2020, 2021, 2023.
    -- [Year] eshte shkruar me kllapa per ta bere emrin te sigurt ne SQL.
    [Year] SMALLINT,

    -- Vlera numerike e indikatorit.
    -- Perdoret FLOAT sepse disa vlera mund te jene me presje dhjetore.
    Value FLOAT
);
GO


-- Krijon tabelen Staging_Kaggle.
-- Kjo eshte tabela staging per dataset-in shtese nga Kaggle.
-- Kerkesa e projektit kerkon perdorimin e nje dataset-i shtese ne CSV,
-- dhe kjo tabele sherben pikerisht per ruajtjen e atyre te dhenave.
CREATE TABLE Staging_Kaggle (

    -- Emri i shtetit nga dataset-i Kaggle.
    -- Kjo do perdoret me vone per lidhje me DimCountry ose me query krahasuese.
    Country_Name NVARCHAR(255),

    -- Viti i te dhenave ne Kaggle.
    -- Ne projektin tuaj zakonisht eshte perdorur 2023.
    [Year] SMALLINT,

    -- Category ruan llojin e treguesit nga Kaggle,
    -- p.sh. GDP per capita, Population, Share of World GDP.
    -- Kjo strukture e ben dataset-in me fleksibel dhe me te lehte per analiza.
    Category NVARCHAR(255),

    -- Value ruan vleren per kategorine perkatese.
    -- P.sh. nese Category = Population, ketu ruhet numri i popullsise.
    Value FLOAT
);
GO