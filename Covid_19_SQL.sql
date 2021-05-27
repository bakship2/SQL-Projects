Select *
From COVID_SQL_PROJECT..covid_deaths
order by 3,4

--Select *
--From Covid_vaccine
--order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
From COVID_SQL_PROJECT..covid_deaths
order by 1,2

-- Checking for fatality rate

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS fatalityrate
From COVID_SQL_PROJECT..covid_deaths
order by 1,2

-- Checking for fatality rate in Canada

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercent
From COVID_SQL_PROJECT..covid_deaths
Where Location = 'Canada'
order by 1,2

-- Looking at total Covid positive rate % in Canada by population

Select Location,date,total_cases,population,(total_cases/population)*100 AS covid_positive_rate
From COVID_SQL_PROJECT..covid_deaths
Where Location = 'Canada'
order by 1,2

-- -- Looking at daily Covid positive rate % x 1000, in Canada by population

Select Location,date,new_cases,population,((new_cases/population)*100)*1000 AS covid_positive_rate_daily
From COVID_SQL_PROJECT..covid_deaths
Where Location = 'Canada'
order by 1,2

-- Looking at countries with Highest infection rate compared to population

Select Location,population,MAX(total_cases) as Highest_infection_count,MAX((total_cases/population)*100) AS Highest_infection_rate
From COVID_SQL_PROJECT..covid_deaths
where total_cases is not Null
Group by Location,population
order by 4 desc

-- Looking at countries with Highest death

Select Location,MAX(cast(total_cases as int)) AS Total_deaths
From COVID_SQL_PROJECT..covid_deaths
where total_cases is not Null 
Group by Location
order by Total_deaths desc

-- Removing locations which are not countries

Select Location,MAX(cast(total_cases as int)) AS Total_deaths
From COVID_SQL_PROJECT..covid_deaths
where continent is not null 
and total_cases is not Null 
Group by Location
order by Total_deaths desc

-- Seeing the data by continents

Select continent,MAX(cast(total_cases as int)) AS Total_deaths
From COVID_SQL_PROJECT..covid_deaths
where continent is not null 
and total_cases is not Null 
Group by continent
order by Total_deaths desc

-- Looking at death percentage throughout the world

Select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
From COVID_SQL_PROJECT..covid_deaths
where continent is not null
group by date
order by 1,2

--Looking at total population vs vaccinations in Canada

Select cd.continent, cd.location, cd.date, cd.population, new_vaccinations
From COVID_SQL_PROJECT..covid_deaths cd
Join COVID_SQL_PROJECT..covid_vaccine cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
and cd.location='Canada'
order by 2,3

-- Looking at rolling count of vaccinations on a window of countries 

Select cd.continent, cd.location, cd.date, cd.population, new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER 
(Partition by cd.location order by cd.location,cd.date) AS Rolling_Vac_Count
From COVID_SQL_PROJECT..covid_deaths cd
Join COVID_SQL_PROJECT..covid_vaccine cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3

-- Creating a CTE ( Common table expression )
-- Checking the percentage of population vaccinated per day on a rolling basis.

With popvsvac ( continent,location,date,population,vaccination_per_day, Rolling_vac_count )
as 
(
Select cd.continent, cd.location, cd.date, cd.population, new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER 
(Partition by cd.location order by cd.location,cd.date) AS Rolling_Vac_Count
From COVID_SQL_PROJECT..covid_deaths cd
Join COVID_SQL_PROJECT..covid_vaccine cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
)
Select *, (Rolling_vac_Count/population)*100 as Perc_of_people_vaccinated
From popvsvac

-- Create a temp table to achieve the same


drop table if exists #Percpopvac
Create table #Percpopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vac_count numeric,
)
Insert into #Percpopvac
Select cd.continent, cd.location, cd.date, cd.population, new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER 
(Partition by cd.location order by cd.location,cd.date) AS Rolling_Vac_Count
From COVID_SQL_PROJECT..covid_deaths cd
Join COVID_SQL_PROJECT..covid_vaccine cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null

Select *, (rolling_people_vac_count/population)*100 as Perc_of_people_vaccinated
From #Percpopvac ;

-- Creating view to store data for visualizations
Drop view if exists PercentPopVaccinated
Create view
PercentPopVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER 
(Partition by cd.location order by cd.location,cd.date) AS Rolling_Vac_Count
From COVID_SQL_PROJECT..covid_deaths cd
Join COVID_SQL_PROJECT..covid_vaccine cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
