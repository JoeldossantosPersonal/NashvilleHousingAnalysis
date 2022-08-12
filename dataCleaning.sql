use PortfolioProject

select *
from NashvilleHousing
order by 1,2

--------------------------------------------------------------------------------
--1
--Standarize Date format 

select salesDateConverted, CONVERT(date, saleDate)
from NashvilleHousing

alter table NashvilleHousing
add salesDateConverted date;

update NashvilleHousing
set salesDateConverted = CONVERT(date, saleDate)

--------------------------------------------------------------------------------
--2
--Populate property address data

select *
from NashvilleHousing
order by ParcelID

--------------------------------------------------------------------------------
--3
--Joining exact same table to itself, where is the same parcelId, but not the same uniqueID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress) --when PropertyAddress is null, it takes its address and put it in a diff column
from NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------
--4
--Breaking down address into individual columns (address, city, state). Set deliminars. Using substrings and characters index

select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', propertyAddress)-1) as Address,  --specify column, position 1, character index is going to be searching for a specific value
SUBSTRING(PropertyAddress,CHARINDEX(',', propertyAddress)+ 1, LEN(PropertyAddress)) as Address --separating city. +1 helps to get rid of commas
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', propertyAddress)-1) 

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', propertyAddress)+ 1, LEN(PropertyAddress)) 

select *   
from NashvilleHousing --Just checking if new columns were added 

--found out easier way to split the address, city, and state
select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),  --specify char we want to find, then specify char being replaced
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing
where OwnerAddress is not null
order by 1,2

alter table NashvilleHousing
add OwnerAddress nvarchar(255);

update NashvilleHousing
set OwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerCity nvarchar(255);

update NashvilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

alter table NashvilleHousing
add OwnerState nvarchar(255);

update NashvilleHousing
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------
--5
--Change Yes and No to Y and N in "SoldAsVacant"
select distinct (SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
		case when SoldAsVacant = 'Y' then 'Yes'
			 when SoldAsVacant = 'N' then 'No'
			 else SoldAsVacant
			 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

--------------------------------------------------------------------------------
--6
--Remove duplicates. Using CTE to show duplicate rows, and then delete them
with RowNumCTE as(
select *, 
	ROW_NUMBER() over (
	partition by parcelID, 
				 propertyAddress,
				 salePrice,
				 saleDate,
				 legalReference
				 order by uniqueID
				 )row_num
from NashvilleHousing
)
--delete
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

--------------------------------------------------------------------------------
--7
--Delete unused columns. We would like to delete pointless columns such as the taxDistrict, propertyAddress, ownerAddress and saleDate
select *   
from NashvilleHousing

alter table NashvilleHousing
drop column ownerAddress, TaxDistrict, propertyAddress

alter table NashvilleHousing
drop column saleDate