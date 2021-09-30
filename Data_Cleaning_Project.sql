

-- Cleaning Data in SQL Queries

SELECT *
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing;
--=======================================================================================================

-- Standard Date Format (Covnvert the SaleDate column with a datetime format into date format only)
SELECT 
	SalesDate_Converted,
	CONVERT(Date,SaleDate) 
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SalesDate_Converted DATE;

UPDATE NashvilleHousing
SET SalesDate_Converted = CONVERT(Date,SaleDate);
--=========================================================================================================

-- Populate PropertyAddress that are NULL (empty)
-- Step 1: query PropertyAddress that are NULL

SELECT *
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
	WHERE PropertyAddress IS NULL;

-- Step 2: query PropertyAddress ORDER BY ParcelID	
SELECT *
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
	ORDER BY 
		ParcelID

-- Step 3: create self join to identify those same ParcelID but one of the propertyaddress is NULL and the other is NOT NULL 
SELECT 
	table_a.ParcelID,
	table_a.PropertyAddress,
	Table_b.ParcelID,
	Table_b.PropertyAddress
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing table_a
	JOIN PortfollioProject_Data_Cleaning.dbo.NashvilleHousing table_b
		ON table_a.ParcelID = table_b.ParcelID
			AND table_a.[UniqueID ] <> table_b.[UniqueID ]
	WHERE table_a.PropertyAddress IS NULL

-- Step 4: same as the above join query:  add and ISNULL to the SELECT to generate a column of PropertyAddress that is NOT NULL
SELECT 
	table_a.ParcelID,
	table_a.PropertyAddress,
	Table_b.ParcelID,
	Table_b.PropertyAddress,
	ISNULL(table_a.PropertyAddress, table_b.PropertyAddress) -- PropertyAddress for update
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing table_a
	JOIN PortfollioProject_Data_Cleaning.dbo.NashvilleHousing table_b
		ON table_a.ParcelID = table_b.ParcelID
			AND table_a.[UniqueID ]<> table_b.[UniqueID ]
	WHERE table_a.PropertyAddress IS NULL

-- Step 5 to upadate the NULL PropertyAdress
UPDATE table_a
SET PropertyAddress = ISNULL(table_a.PropertyAddress, table_b.PropertyAddress)
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing table_a
	JOIN PortfollioProject_Data_Cleaning.dbo.NashvilleHousing table_b
		ON table_a.ParcelID = table_b.ParcelID
			AND table_a.[UniqueID ] <> table_b.[UniqueID ]
--====================================================================================================================

-- extracting PropertyAddress and segregating into separate columns like(Address, City, State) using SUBSTRING and CHARINDEX

-- step 1:
SELECT PropertyAddress
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing; -- validating delimitter of PropertyAdress

-- step 2:
SELECT  -- check and validate the charaters to be extracted before and after delimitter
	PropertyAddress AS complete_address, -- validate the complete address before and after delimitter
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address__before_delimitter, -- validate characters before delimmitter
	-- CHARINDEX(',', PropertyAddress),
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS address_after_Delimitter -- validate characters after delimitter
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing

--step 3a
ALTER TABLE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
ADD Address_1 NVARCHAR(255); -- add column for the characters extracted before delimitter

-- step 4a
UPDATE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
SET Address_1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) -- update added column for the characters extracted before delimitter

-- step 3b
ALTER TABLE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
ADD Address_2 NVARCHAR(255); -- add column for the characters extracted after delimitter

-- step 4b
UPDATE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
SET Address_2 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) -- update added column for the characters extracted after delimitter
--=========================================================================================================================================================================

-- extracting PropertyAddress and segregating into separate columns like(Address, City, State) using PARSENAME.  
-- REPLACE function was also use to change other delimitter to '.' to be recognized by PARSENAME
-- this is another apporach of spliting 

-- step 1: Querry the data set to check the columns that needs correction
SELECT * 
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing; 

-- step 2: identify the delimitter use in the column that need to be corrected
SELECT OwnerAddress
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing 

-- step 3: make a query to identify the splits of characters before and after delimitter 
--         use PARSENAME with REPLACE function to change ',' comma delimitter to '.' period to be recognized by PARSENMAE
SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'), 3) AS OwnerAdress,   -- PASENAME will only look for period '.' and will not recognize comma which is the delimitter of OwnerAddres
	PARSENAME(REPLACE(OwnerAddress,',','.'), 2) AS City,		  -- use REPLACE function to replace the comma delimitter of OwnerAddress so that it will be recognized by PARSENAME
	PARSENAME(REPLACE(OwnerAddress,',','.'), 1) AS State
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing

-- step 4: ALTER and ADD table.
--		   update the ADDed table for the split character
ALTER TABLE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
ADD OwnersAddress NVARCHAR(255); -- add column Address for the characters extracted before delimitter

UPDATE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
SET OwnersAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3) -- update added column ownersAddress 


ALTER TABLE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
ADD City NVARCHAR(255); -- add column City for characters extracted after delimitter

UPDATE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
SET City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2) -- update added column City

ALTER TABLE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
ADD State NVARCHAR(255); -- add column State for the characters extracted after delimitter

UPDATE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
SET State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)-- update added column state
--==========================================================================================================================================================================

-- Change Y and N to Yes and No in "Sold as Vacant"
-- in this column "Sold as Vacant" it has different classification (Y,YES,N,NO) which need to be corrected to only YES and NO

--step 1: check the distinct count of each classification (Y,N,Yes,No)
SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY 2

-- step 2: validate the (Y,N,Yes,No) in two columns
SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing

-- step 3: use update to replace the 'Y' with 'Yes' and 'N' with 'No'
UPDATE PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
	SET 
		SoldAsVacant =
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
--=====================================================================================================================================================================================

-- Remove Duplicates

SELECT *
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing

-- step 1: create a query that will be use for CTE
-- step 2 create a PARTITON BY query to partition on things that are unique in each row

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER()
		OVER(
				PARTITION BY ParcelID,
							 PropertyAddress,
							 SalePrice,
							 SaleDate,
							 LegalReference
								ORDER BY
									UniqueID
			) row_num			
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
	)
DELETE    -- before DELETE use  SELECT * with ORDER BY to make a query of duplicate rows to be deleted and then replace "SELECT *" with DELETE (no "*" and ORDER BY)
FROM RowNumCTE
	WHERE row_num >1
	-- ORDER BY PropertyAddress
--==============================================================================================================================================================================

-- Delete Unused Columns

SELECT *
FROM PortfollioProject_Data_Cleaning.dbo.NashvilleHousing

ALTER TABLE  PortfollioProject_Data_Cleaning.dbo.NashvilleHousing
DROP COLUMN
	OwnerAddress,
	TaxDistrict,
	PropertyAddress
