-- DATA CLEANING IN SQL
SELECT TOP 100 *
FROM AnomaProject..Nash

-- STANDARDIZE THE SALEDATE COLUMN; REMOVE THE TIME
UPDATE Nash
SET SaleDate = CONVERT(Date,SaleDate)

SELECT CAST(SaleDate AS date) AS SaleDate
FROM AnomaProject..Nash

UPDATE Nash
SET SaleDate = CAST(SaleDate AS date)

ALTER TABLE Nash
ADD SaleDatee Date;

UPDATE Nash
SET SaleDatee = CONVERT(date, SaleDate)

ALTER TABLE Nash
DROP COLUMN SaleDate

-- POPULATE THE PROPERTY ADDRESS COLUMN - REPLACE NULLS
SELECT *
FROM AnomaProject..Nash
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM AnomaProject..Nash a
JOIN AnomaProject..Nash b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM AnomaProject..Nash a
JOIN AnomaProject..Nash b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

SELECT *
FROM AnomaProject..Nash
WHERE PropertyAddress IS NULL

-- BREAK OUT THE PROPERTY ADDRESS COLUMN INTO INDIVIDUAL COLUMNS (ADDRESS, CITY)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertyAdd,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))AS PropertyCity
FROM AnomaProject..Nash

ALTER TABLE Nash
ADD PropertyAdd NVARCHAR(255)

UPDATE Nash
SET PropertyAdd = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nash
ADD PropertyCity NVARCHAR(255)

UPDATE Nash
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))

--ALTER TABLE Nash
--DROP COLUMN PropertyAddress

-- BREAK OUT THE OWNER ADDRESS COLUMN INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT
SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) -1) AS OwnerAdd
,SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) +1,LEN(OwnerAddress))AS OwnerCityState
FROM AnomaProject..Nash

ALTER TABLE Nash
ADD OwnerAdd NVARCHAR(255)

UPDATE Nash
SET OwnerAdd = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) -1)

ALTER TABLE Nash
ADD OwnerCityState NVARCHAR(255)

UPDATE Nash
SET OwnerCityState = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) +1,LEN(OwnerAddress))

SELECT
SUBSTRING(OwnerCityState, 1, CHARINDEX(',', OwnerCityState) -1) AS OwnerAddCity
,SUBSTRING(OwnerCityState, CHARINDEX(',', OwnerCityState) +1,LEN(OwnerCityState))AS OwnerAddState
FROM AnomaProject..Nash

ALTER TABLE Nash
ADD OwnerAddCity NVARCHAR(255)

UPDATE Nash
SET OwnerAddCity = SUBSTRING(OwnerCityState, 1, CHARINDEX(',', OwnerCityState) -1)

ALTER TABLE Nash
ADD OwnerAddState NVARCHAR(255)

UPDATE Nash
SET OwnerAddState = SUBSTRING(OwnerCityState, CHARINDEX(',', OwnerCityState) +1,LEN(OwnerCityState))

ALTER TABLE Nash
DROP COLUMN OwnerCityState

-- ALTER TABLE Nash
-- DROP COLUMN OwnerAddress
/*	
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAdd,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerAddCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerAddState
FROM AnomaProject..Nash

ALTER TABLE Nash
ADD OwnerAdd NVARCHAR(255)

ALTER TABLE Nash
ADD OwnerAddCity NVARCHAR(255)

ALTER TABLE Nash
ADD OwnerAddState NVARCHAR(255)

UPDATE Nash
SET OwnerAdd = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE Nash
SET OwnerAddCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Nash
SET OwnerAddState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
*/

-- CHANGING 'Y TO YES' AND 'N TO NO' IN THE SOLDASVACANT COLUMN
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 
FROM AnomaProject..Nash 

UPDATE NASH
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM AnomaProject..Nash
GROUP BY SoldAsVacant
ORDER BY 2

-- REMOVE DUPLICATES
WITH duplicates AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDatee,
			 LegalReference
			 ORDER BY UniqueID) AS RowNum
FROM AnomaProject..Nash)
-- ORDER BY ParcelID

DELETE
FROM duplicates
WHERE RowNum > 1

/* 
DELETE
FROM duplicates
WHERE RowNum > 1
*/

-- DELETE UNUSED COLUMNS
ALTER TABLE Nash
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

SELECT *
FROM AnomaProject..Nash 