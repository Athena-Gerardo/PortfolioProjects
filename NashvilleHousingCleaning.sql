/*
Nashville Housing Data Cleaning

Skills: Convert data type, Update & Alter tables with DROP, Join tables, Substring & CharIndex functions, Parse functions, and CTEs
NOTE: It is not standard  practice to delete data from your database. I only drop the columns from my uploaded table
	because I still have the original raw data stored on the computer, and I am not currently accessing a company database. 
	The practice is most commonly used for views for later vizzes.
*/


-- View the data

SELECT *
FROM dbo.NashvilleHousing


-- Change the Date format (convert from date time format to date format only)

SELECT SaleDate, CONVERT(Date,SaleDate) --convert to Date format using "Date" then the column you need to convert to view before updating the table
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing --alter the table first, then update the table by insterting the new data type into the newly created column SaleDateConverted
ADD SaleDateConverted Date

UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM dbo.NashvilleHousing --Check to ensure it worked, it did!

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate --Drop the now redundant SaleDate column


-- Populate the Property Address data and use a self join 
-- ParcelID's that are the same value have the same address, we will use this knowledge to fix the NULL address issue

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --ISNULL means if it's null, take what is null and replace with what you want
FROM dbo.NashvilleHousing AS a
JOIN dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL

UPDATE a --use alias for table when using JOIN in an UPDATE query
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing AS a
JOIN dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]


-- Break now updated Property Address into individual columns (Street Address, City, State)

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS StreetAddress,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing 
ADD PropertySplitStreetAddress Nvarchar(255)

UPDATE dbo.NashvilleHousing
SET PropertySplitStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE dbo.NashvilleHousing 
ADD PropertySplitCity Nvarchar(255)

UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing --drop now redundant column Property Address
DROP COLUMN PropertyAddress


-- Now change the Owner Address column to a more useful format, too, using PARSENAME method

SELECT *
FROM dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress


-- Alter Sold as Vacant column for more consistent data

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)
-- "Yes" and "No" are more common that "Y" and "N" fields, so let's change the Y and N to Yes and No for consistency

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM dbo.NashvilleHousing
ORDER BY SoldAsVacant

UPDATE NashvilleHousing
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


--Remove duplicates (not standard practice when accessing databases)
-- Find the duplicate values

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitStreetAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueId
					) AS row_num


FROM dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1



-- Drop other unused columns

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN TaxDistrict

SELECT *
FROM dbo.NashvilleHousing