/* 

Cleaning the data 

*/

-- Select the data 

select * 
from PortfolioProject..NashvilleHousing
--------------------------------------------------------------------------------------------------------------

--Standardize date format 

select SaleDate, CONVERT(Date, SaleDate) 
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
alter column SaleDate Date

--------------------------------------------------------------------------------------------------------------

--Populate Property Address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------

--Breaking out Address into individual Columns(Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select * from PortfolioProject..NashvilleHousing

--Breaking OwnerAddress into individual columns

select OwnerAddress from PortfolioProject..NashvilleHousing

select
PARSENAME(Replace(OwnerAddress,',','.' ),1) as State,
PARSENAME(Replace(OwnerAddress,',','.' ),2) as City,
PARSENAME(Replace(OwnerAddress,',','.' ),3) as Address
from PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.' ),3)

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.' ),2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitState =  PARSENAME(Replace(OwnerAddress,',','.' ),1)

select * from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------
 
--Change Y as Yes and N as No in SoldAsVacant

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Yeses' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Yeses' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-------------------------------------------------------------------------------------------------------

--Remove Duplicates

select * from PortfolioProject..NashvilleHousing

WITH RowNumCTE as (
select *,
ROW_NUMBER() over (
partition by  ParcelID, 
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  order by UniqueID) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
delete from RowNumCTE 
where row_num > 1
--order by PropertyAddress

--------------------------------------------------------------------------------------------------------

-- Delete unused columns

select * from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress, TaxDistrict, OwnerAddress
