
--Data Cleaning using Nashville Housing Dataset
--Skills used: Joins, CTE's, Temp Tables, Conditional statements ( Case ),Altering tables, Adding Columns, Deleting columns and rows, String functions,Windows Functions, Aggregate Functions, Subqueries, 


Select *
From SQL_Projects..NashvilleHousing


--Converting date to standard format using Convert and Alter table



Select SaleDate, CONVERT(DATE,SaleDate) as NewDate
From SQL_Projects..NashvilleHousing


Alter table SQL_Projects..NashvilleHousing
Add SaleDateUpdated Date
Update SQL_Projects..NashvilleHousing
Set SaleDateUpdated= convert(Date,SaleDate)
Select SaleDate, SaleDateUpdated
From SQL_Projects..NashvilleHousing

-----------------------------------------------------------------------------------------------------------



--Checking to see if there are addresses stored for the Null columns by another ID



Select x.[UniqueID ], x.ParcelID, y.ParcelID, x.PropertyAddress, y.PropertyAddress, ISNULL(x.PropertyAddress,y.PropertyAddress) as UpdatedAddress
From SQL_Projects..NashvilleHousing as x
Join SQL_Projects..NashvilleHousing as y
ON x.ParcelID=y.parcelID
WHERE x.PropertyAddress is null and x.[UniqueID ]!= y.[UniqueID ]



-- Updating the addresses for the null values using ISNULL and Joins



Update x
Set PropertyAddress= ISNULL(x.PropertyAddress,y.PropertyAddress)
From SQL_Projects..NashvilleHousing as x
Join SQL_Projects..NashvilleHousing as y
ON x.ParcelID=y.parcelID
WHERE x.PropertyAddress is null and x.[UniqueID ]!= y.[UniqueID ]


-----------------------------------------------------------------------------------------------------------



-- Breaking out Address into individual columns using Substring and Charindex



Select PropertyAddress
From SQL_Projects..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From SQL_Projects..NashvilleHousing

Alter table SQL_Projects..NashvilleHousing
Add Address nvarchar(255), City nvarchar(255)
Update SQL_Projects..NashvilleHousing
Set Address=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From SQL_Projects..NashvilleHousing




-- Splitting up owner Address using PARSENAME



Select OwnerAddress
From SQL_Projects..NashvilleHousing

Select PARSENAME( Replace(OwnerAddress, ',', '.'), 3),
PARSENAME( Replace(OwnerAddress, ',', '.'), 2),
PARSENAME( Replace(OwnerAddress, ',', '.'), 1)
From SQL_Projects..NashvilleHousing

Alter table SQL_Projects..NashvilleHousing
Add ownerAddresssplit nvarchar(255), ownerCity nvarchar(255), ownerState nvarchar(255);
Update SQL_Projects..NashvilleHousing
Set ownerAddresssplit=PARSENAME( Replace(OwnerAddress, ',', '.'), 3),
ownerCity=PARSENAME( Replace(OwnerAddress, ',', '.'), 2),
ownerState=PARSENAME( Replace(OwnerAddress, ',', '.'), 1)

Select *
From SQL_Projects..NashvilleHousing



-----------------------------------------------------------------------------------------------------------



-- Change Y and N to Yes and No in 'Sold as Vacant' field using Case Statement


Select SoldAsVacant ,
Case When SoldAsVacant='Y' then 'Yes'
When SoldAsVacant='N' then 'No'
Else SoldAsVacant
END
From SQL_Projects..NashvilleHousing

Update SQL_Projects..NashvilleHousing
Set SoldAsVacant=Case When SoldAsVacant='Y' then 'Yes'
When SoldAsVacant='N' then 'No'
Else SoldAsVacant
END

Select Distinct(SoldAsVacant)
From SQL_Projects..NashvilleHousing


-----------------------------------------------------------------------------------------------------------



-- Remove Duplicates using window function, CTE and Subqueries


Select *,
ROW_NUMBER() Over ( 
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by
			 ParcelID)
From SQL_Projects..NashvilleHousing
Order by ParcelID



--Using subquery to find out duplicates



Select *
From (Select *,
ROW_NUMBER() Over ( 
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by
			 ParcelID) as rownum
From SQL_Projects..NashvilleHousing ) as s
Where rownum>1 



--Using CTE to remove duplicates



With duplicateCTE
AS
(Select *,
ROW_NUMBER() Over ( 
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by
			 ParcelID) as rownum
From SQL_Projects..NashvilleHousing)

Delete
From duplicateCTE
where rownum>1


-----------------------------------------------------------------------------------------------------------



--Delete unessecary columns

Alter table SQL_Projects..NashvilleHousing
Drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

Select*
From SQL_Projects..NashvilleHousing




