CREATE DATABASE BigDataProject;
GO

USE BigDataProject;
GO


CREATE TABLE Staging_WorldBank (
    Country_Name NVARCHAR(255),
    Country_Code NVARCHAR(50),
    Indicator_Name NVARCHAR(255),
    Indicator_Code NVARCHAR(100),
    [Year] SMALLINT,
    Value FLOAT
);
GO


CREATE TABLE Staging_Kaggle (
    Country_Name NVARCHAR(255),
    [Year] SMALLINT,
    Category NVARCHAR(255),
    Value FLOAT
);
GO