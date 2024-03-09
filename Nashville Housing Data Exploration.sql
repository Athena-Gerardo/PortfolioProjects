/*

Nashville Housing Data Exploration

Skills used: Date extraction, UPDATE & ALTER tables, CAST with aggregate function, 

*/

-- Things to explore: What are the avg prices of houses in each city? How are the prices going up by year? Most common landuse type of house sold? Average price of houses per bedrooms/baths? Actual value vs sale price (and the % difference)?
-- Are older built houses worth more or less than newer built houses?


-- View the Data

SELECT *
FROM dbo.NashvilleHousing
ORDER BY SaleYear DESC


-- Find the average prices of houses in each city

SELECT PropertySplitCity, COUNT(PropertySplitCity)
FROM dbo.NashvilleHousing
GROUP BY PropertySplitCity

--"unknown" city was found listed, exclude that as there is only 1

SELECT PropertySplitCity, CAST(AVG(SalePrice) AS int) AS AvgSalePrice, COUNT(UniqueId), SaleYear
FROM dbo.NashvilleHousing
WHERE PropertySplitCity != '1uunknown'
AND SaleYear <> 2019
GROUP BY PropertySplitCity, SaleYear
ORDER BY SaleYear 


-- Prices of houses per year

SELECT COUNT(SalePrice) --Make sure there are no NULLs for our calculations
FROM dbo.NashvilleHousing
WHERE SalePrice is NULL

SELECT SaleYear, COUNT(DISTINCT(UniqueID)) AS HousesSold 
FROM dbo.NashvilleHousing
GROUP BY SaleYear
ORDER BY SaleYear -- Found an issue here, only two houses are listed in this dataset from 2019, so this data is not accurate nor encapsulates all of 2019. We should exclude it from our analysis

SELECT SaleYear, CAST(AVG(SalePrice) AS int) AS AvgSalePrice, CAST(AVG(TotalValue) AS int) AS AvgMarketValue, (AVG(SalePrice)/AVG(TotalValue)) AS PriceIncreasePercentage
FROM dbo.NashvilleHousing
WHERE TotalValue is not NULL
AND SaleYear <> 2019
GROUP BY SaleYear
ORDER BY SaleYear

-- What houses are the most commonly sold, and what are their average prices?

SELECT TOP (5) LandUse, COUNT(DISTINCT(UniqueID)) AS BldngsSoldCount, CAST(AVG(SalePrice) AS int) AS AvgSalePrice, CAST(AVG(TotalValue) AS int) AS AvgMarketValue, (AVG(SalePrice)/AVG(TotalValue)) AS PriceIncreasePercentage
FROM dbo.NashvilleHousing
WHERE TotalValue is not NULL
AND SalePrice is not NULL
AND SaleYear <>2019
GROUP BY LandUse
ORDER BY 2 DESC

-- Found duplicate LandUse names that were slightly different, altered them in the cleaning code. Shown here for your viewing:
--SELECT LandUse,
--	CASE WHEN LandUse = 'VACANT RES LAND' THEN 'VACANT RESIDENTIAL LAND'
--		 ELSE LandUse
--		 END
--FROM dbo.NashvilleHousing

--UPDATE NashvilleHousing
--SET LandUse = CASE WHEN LandUse = 'VACANT RES LAND' THEN 'VACANT RESIDENTIAL LAND'
--		 ELSE LandUse
--		 END


-- How much do older built houses sell for vs newer built houses? Additionally, how does the market value compare to the sale price?

SELECT MIN(YearBuilt), MAX(YearBuilt), AVG(YearBuilt), COUNT(YearBuilt)
FROM dbo.NashvilleHousing
WHERE YearBuilt = 2017

WITH YBValue (SalePrice, TotalValue, YearBuilt, UniqueId)
as 
(SELECT SalePrice, TotalValue, CAST(YearBuilt AS nvarchar(255)), COUNT(UniqueId)
FROM dbo.NashvilleHousing
WHERE YearBuilt <> 2017 -- there are houses listed at being built in 2017, yet our sale data only goes up to 2016, skips two years, then includes 2 data entries from 2019. 
GROUP BY SalePrice, TotalValue, YearBuilt
)
SELECT SalePrice, TotalValue, UniqueId,
	CASE WHEN YearBuilt <= '1800' THEN '1800'
		WHEN YearBuilt >= '1800' AND YearBuilt < '1900' THEN '1800-1899'
		WHEN YearBuilt >= '1900' AND YearBuilt < '1950' THEN '1900-1949'
		WHEN YearBuilt >= '1950' AND YearBuilt < '2000' THEN '1950-1999'
		WHEN YearBuilt >= '2000' THEN '2000-2020'
		ELSE YearBuilt
		END AS YearBuilt
FROM YBValue
WHERE YearBuilt is not NULL
AND UniqueId <> 2
AND YearBuilt <> 2017
GROUP BY YearBuilt, SalePrice, TotalValue, UniqueId
ORDER BY YearBuilt 

--What's the total net profit of the housing market in TN?

SELECT SUM(SalePrice) AS TotalSales, SUM(TotalValue) AS TotalMarketValue, SUM(SalePrice)-SUM(TotalValue) AS NetProfit, (SUM(SalePrice)/SUM(TotalValue))*100 AS NetProfitPercentage
FROM dbo.NashvilleHousing
WHERE SaleYear <> 2019
AND TotalValue is not NULL

/*
How does this help a business?

First, I used SQL to delve into metrics encompassing city data, sale years, building types, and construction years of the houses. 
My aim was to uncover profit margin patterns tied to these metrics, which help a businesses adjust their pricing strategies to 
remain competitive and attract more customers. These analyses offer insights into the overall health and dynamics
of the real estate market.

Additionally, clustering algorithms were applied to compare average sale prices with market values, revealing fluctuations based 
on various metrics. These insights not only aid in identifying lucrative investment opportunities but also help assess the risks 
associated with property investments.

The SQL queries are used to generate visualizations in Tableau that help illustrate the trends within the real estate market and the 
corresponding contributions to the housing market's revenue generation. The Tableau dashboard is used to present my findings and provide 
actionable insights for pricing strategies. By leveraging SQL to perform market analysis, the company gained valuable insights into the 
overall health of the current real estate market, enabling them to make possible investment opportunities, assess associated risk, and 
optimize their revenue generation.
