SELECT * 
FROM portfolioprojects..NathvilleHousing


-- standarzing the dates
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM portfolioprojects..NathvilleHousing

ALTER TABLE portfolioprojects..NathvilleHousing
ADD SaleDateConverted Date;

UPDATE portfolioprojects..NathvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Property address data cleaning
SELECT *
FROM portfolioprojects..NathvilleHousing
WHERE PropertyAddress IS NULL


SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM portfolioprojects..NathvilleHousing A
JOIN portfolioprojects..NathvilleHousing B
ON A.ParcelID = B.ParcelID 
AND A.[UniqueID ] != B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress=ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM portfolioprojects..NathvilleHousing A
JOIN portfolioprojects..NathvilleHousing B
ON A.ParcelID = B.ParcelID 
AND A.[UniqueID ] != B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--Spliting address into different coloumns

SELECT PropertyAddress
FROM portfolioprojects..NathvilleHousing
ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM portfolioprojects..NathvilleHousing
ORDER BY ParcelID

ALTER TABLE portfolioprojects..NathvilleHousing
ADD PropertySplitAddress NVARCHAR(250);

UPDATE portfolioprojects..NathvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE portfolioprojects..NathvilleHousing
ADD PropertySplitCity NVARCHAR(250);

UPDATE portfolioprojects..NathvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT * 
FROM portfolioprojects..NathvilleHousing

--spliting owner address
SELECT OwnerAddress
FROM portfolioprojects..NathvilleHousing
ORDER BY ParcelID

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM portfolioprojects..NathvilleHousing
ORDER BY ParcelID

ALTER TABLE portfolioprojects..NathvilleHousing
ADD OwnerSplitAddress NVARCHAR(250);

UPDATE portfolioprojects..NathvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE portfolioprojects..NathvilleHousing
ADD OwnerSplitCity NVARCHAR(250);

UPDATE portfolioprojects..NathvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE portfolioprojects..NathvilleHousing
ADD OwnerSplitState NVARCHAR(250);

UPDATE portfolioprojects..NathvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Changing Y and N to Yes and No

SELECT SoldAsVacant,COUNT(SoldAsVacant)
FROM portfolioprojects..NathvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM portfolioprojects..NathvilleHousing

UPDATE portfolioprojects..NathvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

--Remove duplicates
WITH RowNum_CTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY  ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID ) AS Row_Num
FROM portfolioprojects..NathvilleHousing
)
SELECT *
FROM RowNum_CTE
WHERE Row_Num >1
ORDER BY PropertyAddress

--Delete unneccessary columns

ALTER TABLE portfolioprojects..NathvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

SELECT * 
FROM portfolioprojects..NathvilleHousing
Order by ParcelID
Footer