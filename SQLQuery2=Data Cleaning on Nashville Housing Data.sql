
-- SQL Project : Data Cleaning on Nashville Housing Dataset
-- Dataset : Download Nashville Housing Dataset.xlsx from Google or Kaggle

------------------------------------------------------------------------------------------------------------------

-- Looking at Data

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Changing format of SaleDate column from datetime to date or 
-- adding new column named as 'SaleDateConverted' 

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

SELECT FORMAT(SaleDate, 'yyyy-MM-dd') AS SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

-- OR 

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- OR

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------------------------

-- Populate Property Address

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]=b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------------

-- Separate PropertyAddress into individual columns like Address, City, State

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

-- for Address
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM PortfolioProject..NashvilleHousing

-- for City
SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
    
FROM PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Add columns PropertySplitAddress and PropertySplitCity to original data

-- for Address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- for City
ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Looking at whole data with added columns
SELECT *
FROM PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Do the same thing with OwnerAddress with another method
-- Seaparate OwnerAddress into Address, City and State

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
    PARSENAME(REPLACE(OwnerAddress,',',','), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress,',',','), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress,',',','), 1) AS State
FROM PortfolioProject..NashvilleHousing

-- for Address
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',',','), 3)

-- for City
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',',','), 2)

-- for State
ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',',','), 1)

-- Looking at whole data with added columns
SELECT *
FROM PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Change 'Y' to 'Yes' and 'N' to 'No' respectively in SoldAsVacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
	    ELSE SoldAsVacant
    END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
	    ELSE SoldAsVacant
    END

------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- *
WITH RowNumCTE 
AS
(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	    ORDER BY UniqueID
		) row_num

FROM PortfolioProject..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress   

-- Removing
WITH RowNumCTE 
AS
(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	    ORDER BY UniqueID
		) row_num

FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Run above code block again denoted with *
-- It will remove all the duplicates

------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

-- Check
SELECT *
FROM PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------

