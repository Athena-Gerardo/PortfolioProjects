*/* 

OCD Healthcare Data Exploration and Analysis

*/*

-- First, ensure that all data is clean and accurate

SELECT *
FROM dbo.OCD_DS;


SELECT *
FROM dbo.OCD_DS
WHERE Gender is NULL
	OR [OCD Diagnosis Date] is NULL 
	OR [Duration of Symptoms (months)] is NULL
	OR [Y-BOCS Score (Compulsions)] is NULL
	OR [Y-BOCS Score (Obsessions)] is NULL
	OR [Marital Status] is NULL
	OR [Previous Diagnoses] is NULL
	OR [Family History of OCD] is NULL;


-- 1. Count F vs M that have OCD & average the Obsession Score by gender
SELECT Gender, COUNT([Patient ID]) as [Patient Count], AVG(CAST([Y-BOCS Score (Obsessions)] AS int)) as [Average Obsession Score]
FROM dbo.OCD_DS
GROUP BY Gender
ORDER BY [Average Obsession Score] DESC;


-- 2. Count & find the average obsession score by ethnicities that have OCD
SELECT Ethnicity, COUNT([Patient ID]) as [Patient Count], AVG(CAST([Y-BOCS Score (Obsessions)] AS int)) as [Average Obsession Score]
FROM dbo.OCD_DS
GROUP BY Ethnicity
ORDER BY [Average Obsession Score] DESC;
 

-- 3a. Find the number of people diagnosed each month
-- Change the data type of the OCD Diagnosis Date from varchar to date type
--ALTER TABLE dbo.OCD_DS
--ALTER COLUMN [OCD Diagnosis Date] DATE;
SELECT DATEFROMPARTS(YEAR([OCD Diagnosis Date]), MONTH([OCD Diagnosis Date]), 1) AS [First Day of Month],
       COUNT([Patient ID]) AS [Patient Count]
FROM dbo.OCD_DS
GROUP BY DATEFROMPARTS(YEAR([OCD Diagnosis Date]), MONTH([OCD Diagnosis Date]), 1)
ORDER BY DATEFROMPARTS(YEAR([OCD Diagnosis Date]), MONTH([OCD Diagnosis Date]), 1);


-- 3b. Find the most common month for diagnosis
SELECT MONTH([OCD Diagnosis Date]) as [Diagnosis Month], 
	COUNT([Patient ID]) as [Patient Count] 
FROM dbo.OCD_DS
GROUP BY MONTH([OCD Diagnosis Date])
--ORDER BY COUNT([Patient ID]) DESC
ORDER BY MONTH([OCD Diagnosis Date])


-- 4. What is the most common Obsession Type (count) & the respective Average Obsession Score
SELECT [Obsession Type], COUNT([Obsession Type]) as [Type Count], AVG(CAST([Y-BOCS Score (Obsessions)] AS int)) as [Average Obsession Score]
FROM dbo.OCD_DS
GROUP BY [Obsession Type]
ORDER BY COUNT([Obsession Type]) DESC;


-- 5. What is the most common Compulsion Type (count) & the respective Average Obsession Score
SELECT [Compulsion Type], COUNT([Compulsion Type]) as [Type Count], AVG(CAST([Y-BOCS Score (Obsessions)] AS int)) as [Average Obsession Score]
FROM dbo.OCD_DS
GROUP BY [Compulsion Type]
ORDER BY COUNT([Compulsion Type]) DESC;


-- 6. Find the relationship between diagnoses and family medical history of OCD
SELECT COUNT([Patient ID]) as [Patient Count], [Family History of OCD]
FROM dbo.OCD_DS
GROUP BY [Family History of OCD]
ORDER BY COUNT([Patient ID]) DESC;