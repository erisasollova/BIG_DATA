USE BigDataProject;
GO

/*  VERIFY YEAR PARTITIONS */

SELECT 
    $PARTITION.pf_YearRange([Year]) AS PartitionNumber,
    COUNT(*) AS RowsCount
FROM FactEconomicData_Partitioned
GROUP BY $PARTITION.pf_YearRange([Year])
ORDER BY PartitionNumber;
GO

/* VERIFY CATEGORY PARTITIONS */

SELECT 
    Category,
    $PARTITION.pf_Category(CategoryKey) AS PartitionNumber,
    COUNT(*) AS RowsCount
FROM Staging_Kaggle_Partitioned
GROUP BY Category, $PARTITION.pf_Category(CategoryKey)
ORDER BY PartitionNumber;
GO

SELECT 
    Year,
    $PARTITION.pf_Year(Year) AS PartitionNumber,
    COUNT(*) AS RowsCount
FROM Staging_Kaggle_Partitioned
GROUP BY Year, $PARTITION.pf_Year(Year)
ORDER BY Year;
GO

/*  PERFORMANCE TEST */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Pa partition
SELECT *
FROM FactEconomicData f
JOIN DimTime dt ON f.TimeKey = dt.TimeKey
WHERE dt.[Year] = 2023;
GO

-- Me partition (Partition Elimination)
SELECT *
FROM FactEconomicData_Partitioned
WHERE [Year] = 2023;
GO






