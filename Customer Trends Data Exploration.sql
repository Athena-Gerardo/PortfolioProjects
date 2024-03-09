/*

Customer Trends Data Exploration

How does this help a business?

First, I used SQL to explore customer metrics such as total customer spending, customer purchasing frequency, and the average order value 
of our cusomters. I am setting up the metrics of who are high-value customers that make large purchases, which contributes greatly
to the company's revenue, and who are casual shoppers.

Next, I utilized SQL to implement clustering algorithms that show customer groups based on their purchasing habits. I used factors like
the highest-revenued season, the most common item purchased, location-based purchases, and subscription-based purchases. By applying these 
clustering techniques, I categorized customers into distinct groups, such as loyal customers and casual shoppers.

The SQL queries are used to generate visualizations in Tableau that help illustrate the distribution of these customer groups and their 
corresponding contributions to the company's revenue. The Tableau dashboard is used to present my findings to highlight the customer groups and 
provide actionable insights for targeted consumer marketing strategies. By leveraging SQL to perform customer segmentation, the company 
gained valuable insights into its customer base, enabling them to tailor marketing campaigns, improve customer retention, and optimize their revenue generation.

*/

SELECT TOP (10) *
FROM dbo.CustomerTrends

-- Check for NULLS, duplicate data
SELECT *
FROM dbo.CustomerTrends
ORDER BY Age DESC

SELECT COUNT(DISTINCT([Customer ID])), COUNT([Customer ID])
FROM dbo.CustomerTrends
-- there are no duplicates or NULLS


-- What gender buys more products?
SELECT Gender, COUNT([Customer ID]) AS NumberOfSoldItems, SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue
FROM dbo.CustomerTrends
GROUP BY Gender
ORDER BY TotalRevenue DESC


-- What age group buys more products?
SELECT Age, COUNT([Customer ID]) AS NumberOfSoldItems, SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue
FROM dbo.CustomerTrends
GROUP BY Age
ORDER BY TotalRevenue DESC


-- What season does the company make the most revenue?
SELECT Season, COUNT([Customer ID]) AS NumberOfSoldItems, SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue
FROM dbo.CustomerTrends
GROUP BY Season
ORDER BY TotalRevenue DESC


-- What is the total revenue for each item sold?
SELECT [Item Purchased], COUNT([Customer ID]) AS NumberOfSoldItems, SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue
FROM dbo.CustomerTrends
GROUP BY [Item Purchased]
ORDER BY TotalRevenue DESC


-- What is the customer purchase frequency?
SELECT [Frequency of Purchases], COUNT([Customer ID]) AS NumberOfSoldItems, SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue, [Subscription Status]
FROM dbo.CustomerTrends
GROUP BY [Frequency of Purchases], [Subscription Status]
ORDER BY TotalRevenue DESC


-- What is the average order value of each customer?
SELECT [Customer ID], AVG(CAST([Purchase Amount (USD)] AS INT)) AS AverageRevenue
FROM dbo.CustomerTrends
GROUP BY [Customer ID]
ORDER BY 2 DESC


-- Do subcribers spend more money?
SELECT [Subscription Status], SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue, CAST([Previous Purchases] AS int) AS PreviousPurchases
FROM dbo.CustomerTrends
WHERE [Previous Purchases] > 20
GROUP BY  [Subscription Status], [Previous Purchases]
ORDER BY PreviousPurchases DESC

SELECT [Subscription Status], COUNT([Subscription Status]) AS Customers, CAST([Previous Purchases] AS int) AS PreviousPurchases
FROM dbo.CustomerTrends
WHERE [Previous Purchases] > 20
GROUP BY  [Subscription Status], [Previous Purchases]
ORDER BY PreviousPurchases DESC
-- it looks like the top consumers are not subscribers, but it alternates between loyal customers and casual shoppers


-- Are there more sales when a discount or promo is applied?
SELECT [Discount Applied], [Promo Code Used], [Subscription Status], COUNT([Customer ID]) AS NumberOfSoldItems, SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue
FROM dbo.CustomerTrends
GROUP BY [Discount Applied], [Promo Code Used], [Subscription Status]
ORDER BY TotalRevenue DESC


-- What location generates the most revenue?
SELECT Location, SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue, CAST(COUNT([Subscription Status]) AS int) AS TotalSubs
FROM dbo.CustomerTrends
WHERE [Subscription Status] = 'Yes'
GROUP BY Location
ORDER BY 2 DESC


-- ... And what location has the highest amount of subscribers?
SELECT Location, SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue, CAST(COUNT([Subscription Status]) AS int) AS TotalSubs
FROM dbo.CustomerTrends
WHERE [Subscription Status] = 'Yes'
GROUP BY Location
ORDER BY 3 DESC


-- What is the most common method of payment?
SELECT [Payment Method], SUM(CAST([Purchase Amount (USD)] AS INT)) AS TotalRevenue
FROM dbo.CustomerTrends
GROUP BY [Payment Method]
ORDER BY 2 DESC

