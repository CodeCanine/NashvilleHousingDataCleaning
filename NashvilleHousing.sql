-- Data Cleaning practice project
-- Data provided: https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

-- Checking Data

SELECT * 
FROM NashvilleHousingProject.dbo.NashvilleHousing

-- Removing Time of Day by Converting to Date format

UPDATE  NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE  NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

-- Populating Property Address data

-- Self Join, to populate Property Address with the use of ParcelID
-- Same ParcelID but NOT the same row, to avoid repetition

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousingProject.dbo.NashvilleHousing a
JOIN NashvilleHousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Address, City, State
-- Splitting the long address to a more usable form

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE  NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE  NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

-- Splitting Owner Address to a more usable form with PARSENAME instead of SUBSTRING

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE  NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE  NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE  NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousingProject.dbo.NashvilleHousing

-- Deleting Duplicates where row_num > 1, meaning it has duplicates based on unique records

With RowNumCTE AS (
SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		)row_num
FROM NashvilleHousingProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


SELECT *
FROM NashvilleHousingProject.dbo.NashvilleHousing

--

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- Checking end table

SELECT *
FROM NashvilleHousingProject.dbo.NashvilleHousing