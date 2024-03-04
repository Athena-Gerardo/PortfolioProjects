/*

Denver, CO Crime Data Cleaning

Skills: PARSENAME(), SUBSTRING(), STRING_AGG(), STRING_SPLIT(), DATEPART(), COUNT(), DISTINCT(), UPDATE(), REPLACE, CONVERT(), UPPER(), LOWER(), LEN()

*/

SELECT *
FROM dbo.DenverCrime;


-- Count how many NULL values exist to ensure usability.
SELECT COUNT(incident_id) AS NULLCount
FROM dbo.DenverCrime
WHERE last_occurrence_date is NULL
--incident_address is NULL
--geo_x is NULL
--geo_y is NULL
-- geo_lon is NULL
-- geo_lat is NULL;
-- NOTE: About 4% of the incident_address and geo tags are NULLS, which is really good.
-- NOTE: About 45% of the last_occurrence_date observations are NULL. It would be best to leave that out of the analysis process, but we will NOT delete it.


SELECT COUNT(DISTINCT(incident_id))
FROM dbo.DenverCrime;
-- It is okay to have duplicate data, that just means people are offending multiple times.


-- Explore different columns to ensure consistency.
SELECT offense_category_id
FROM dbo.DenverCrime
GROUP BY offense_category_id;

SELECT COUNT(is_crime)
FROM dbo.DenverCrime
WHERE is_crime = 1;

SELECT COUNT(victim_count)
FROM dbo.DenverCrime
WHERE victim_count > 1;


-- Separate the date columns from the time in the first_occurrence_date column, the last_occurrence_date column, and the reported_date column.
SELECT *
FROM dbo.DenverCrime;

SELECT CONVERT(DATE, first_occurrence_date) AS first_occurence_date_converted, CONVERT(TIME(0), first_occurrence_date) AS first_occurrence_time, 
	CONVERT(DATE, last_occurrence_date) AS last_occurence_date_converted, CONVERT(TIME(0), last_occurrence_date) AS last_occurrence_time,
	CONVERT(DATE, reported_date) AS reported_date_converted, CONVERT(TIME(0), reported_date) AS reported_time
FROM dbo.DenverCrime;

ALTER TABLE dbo.DenverCrime
ADD first_occurence_date_converted DATE, first_occurrence_time TIME, last_occurence_date_converted DATE, last_occurrence_time TIME, reported_date_converted DATE, reported_time TIME;

UPDATE dbo.DenverCrime
--SET first_occurence_date_converted = CONVERT(DATE, first_occurrence_date)
--SET first_occurrence_time = CONVERT(TIME(0), first_occurrence_date)
--SET last_occurence_date_converted = CONVERT(DATE, last_occurrence_date)
--SET last_occurrence_time = CONVERT(TIME(0), last_occurrence_date)
--SET reported_date_converted = CONVERT(DATE, reported_date)
--SET reported_time = CONVERT(TIME(0), reported_date);


-- Take out the hyphen in neighborhood id's.
SELECT *
FROM dbo.DenverCrime;

SELECT REPLACE(neighborhood_id, '-', ' ') AS neighborhood
FROM dbo.DenverCrime;

SELECT REPLACE(UPPER(LEFT(neighborhood_id, 1)) + LOWER(SUBSTRING(neighborhood_id, 2, LEN(neighborhood_id))), '-', ' ') AS neighborhood 
FROM dbo.DenverCrime;

-- For cleaner data, change the neighborhood id's to sentence case. Since I know the max amount of words in the neighborhood_id string is 4, I can use the PARSENAME() function to clean the data.
WITH neighborhoods
AS
(
SELECT 
    neighborhood_id, 
    UPPER(LEFT(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 4),1)) + LOWER(SUBSTRING(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 4), 2, LEN(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 4)) - 1)) AS neighborhood_1,
	UPPER(LEFT(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 3),1)) + LOWER(SUBSTRING(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 3), 2, LEN(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 3)) - 1)) AS neighborhood_2,
    UPPER(LEFT(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 2),1)) + LOWER(SUBSTRING(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 2), 2, LEN(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 2)) - 1)) AS neighborhood_3,
	UPPER(LEFT(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 1),1)) + LOWER(SUBSTRING(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 1), 2, LEN(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 1)) - 1)) AS neighborhood_4
FROM dbo.DenverCrime
WHERE neighborhood_id is not null
GROUP BY neighborhood_id;
)
SELECT CONCAT_WS(' ', neighborhood_1, neighborhood_2, neighborhood_3, neighborhood_4) AS Neighborhoods
FROM neighborhoods;

ALTER TABLE DenverCrime
ADD Neighborhood nvarchar(255);

UPDATE dbo.DenverCrime
SET Neighborhood = CONCAT_WS(' ', UPPER(LEFT(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 4),1)) + LOWER(SUBSTRING(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 4), 2, LEN(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 4)) - 1)), 
							UPPER(LEFT(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 3),1)) + LOWER(SUBSTRING(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 3), 2, LEN(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 3)) - 1)), 
							UPPER(LEFT(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 2),1)) + LOWER(SUBSTRING(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 2), 2, LEN(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 2)) - 1)), 
							UPPER(LEFT(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 1),1)) + LOWER(SUBSTRING(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 1), 2, LEN(PARSENAME(REPLACE(neighborhood_id, '-', '.'), 1)) - 1)));
-- Make sure it worked:
SELECT Neighborhood
FROM dbo.DenverCrime
GROUP BY Neighborhood
ORDER BY 1;
-- We can now run analysis on a neat neighborhood column!


-- Separate the dates into day, month, and year
SELECT DATEPART(YEAR, first_occurence_date_converted), DATEPART(MONTH, first_occurence_date_converted), DATEPART(DAY, first_occurence_date_converted),
	   DATEPART(YEAR, last_occurence_date_converted), DATEPART(MONTH, last_occurence_date_converted), DATEPART(DAY, last_occurence_date_converted),
	   DATEPART(YEAR, reported_date_converted), DATEPART(MONTH, reported_date_converted), DATEPART(DAY, reported_date_converted)
FROM dbo.DenverCrime;

ALTER TABLE dbo.DenverCrime
ADD first_occurence_year int, first_occurence_month int, first_occurence_day int, last_occurrence_year int, 
	last_occurrence_month int, last_occurrence_day int, reported_year int, reported_month int, reported_day int;

UPDATE dbo.DenverCrime
--SET first_occurence_year = DATEPART(YEAR, first_occurence_date_converted) 
--SET first_occurence_month = DATEPART(MONTH, first_occurence_date_converted)
--SET first_occurence_day = DATEPART(DAY, first_occurence_date_converted)
--SET last_occurrence_year = DATEPART(YEAR, last_occurence_date_converted)
--SET last_occurrence_month = DATEPART(MONTH, last_occurence_date_converted)
--SET last_occurrence_day = DATEPART(DAY, last_occurence_date_converted)
--SET reported_year = DATEPART(YEAR, reported_date_converted)
--SET reported_month = DATEPART(MONTH, reported_date_converted)
--SET reported_day = DATEPART(DAY, reported_date_converted);


-- Remove the hyphens from offense_type_id and capitalize the first word. 
-- Since PARSENAME() is a little messy to use, we will use the STRING_AGG() and the STRING_SPLIT() functions instead.
SELECT offense_type_id,
    (
        SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), ' ')
        FROM STRING_SPLIT(dbo.DenverCrime.offense_type_id, '-')
    ) AS offense_type_id_converted
FROM dbo.DenverCrime
GROUP BY offense_type_id;


-- Remove the hyphens from offense_category_id and capitalize the first word. Use the STRING_AGG() and the STRING_SPLIT() functions again.
SELECT offense_category_id,
    (
        SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), ' ')
        FROM STRING_SPLIT(dbo.DenverCrime.offense_category_id, '-') 
    ) AS offense_category_id_converted
FROM dbo.DenverCrime
GROUP BY offense_category_id;


-- Update the table to insert the offense_type_id_converted and the offense_category_id_converted values. We will NOT delete the old columns.
ALTER TABLE DenverCrime
ADD offense_type_id_converted nvarchar(255), offense_category_id_converted nvarchar(255)

UPDATE dbo.DenverCrime
SET offense_type_id_converted = (
    SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), ' ')
	FROM STRING_SPLIT(offense_type_id, '-') 
)

SET offense_category_id_converted = (
    SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), ' ')
    FROM STRING_SPLIT(dbo.DenverCrime.offense_category_id, '-') 
    )
;

-- Make sure it worked:
SELECT offense_type_id_converted, offense_category_id_converted
FROM dbo.DenverCrime
GROUP BY offense_type_id_converted, offense_category_id_converted
ORDER BY offense_category_id_converted
-- It did!


-- Check entire table for any further necessary cleaning and data consistency.
SELECT *
FROM dbo.DenverCrime