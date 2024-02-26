select * from  broker


---date   format 
select saleDate ,CONVERT(Date,SaleDate) new_date  from 
broker
--add new column
alter table  broker 
add new_date Date;
--update it then
update broker
set new_date=CONVERT(Date,SaleDate)

------------populating the address 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From broker a
JOIN broker b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
--isnull is used to fill the  null  values in the table -- and then we will update the new  address 

update a 
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From broker a
JOIN broker b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
------------------ Splitting the  Property address column (Two important functions of the string and substring)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From broker

ALTER TABLE broker
Add PropertySplitAddress Nvarchar(255);

Update broker
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update broker
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--------- We want to select the the sold vacant status as Y /N '


Select SoldAsVacant
, CASE 
       When SoldAsVacant='Y' then 'Yes' 
	   When SoldAsVacant='N' then 'No'
	   else SoldAsVacant 
	   end 
From broker

Update broker
set SoldAsVacant= CASE 
       When SoldAsVacant='Y' then 'Yes' 
	   When SoldAsVacant='N' then 'No'
	   else SoldAsVacant 
	   end 

------------ to remove   duplicates  we will use the window  function  to apply the   ranking 
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From broker
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---- we will create the  value combination of the all of the   above things  and then  we will let   go each other whenever the values  goes  above the 2 

