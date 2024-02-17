/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--select *
--from dbo.CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at the Total Cases vs Total Deaths, create a calculated column for this
-- Shows the probability of dying if you contract Covid-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


-- Looking at the Total Cases vs. Population
-- Shows what percentage of the population has contracted Covid-19 in your country

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM dbo.CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


-- Looking at countries with the Highest Infection rates compared to the Population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 AS MaxInfectionRate
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY MaxInfectionRate DESC


-- Show Countries with the highest Death Count per Population 
-- Cast total_deaths as int, can tell it's not an int because the order by function doesn't actually order it

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount, population, MAX((total_deaths/population))*100 AS MaxDeathRate
FROM dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeathCount DESC


-- Break things down by continents now
-- Show Continents with the highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 AS MaxDeathRate
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- Breaking down by Global Numbers
-- Show Total Cases vs. Total Deaths for each day on the global scale 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1


-- Show Totals on a global scale

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null


-- Looking at Total Population vs. Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE to create a calculated column for our Total Pop vs Vax table to find New Vaccines per Day 
-- NOTE: if # columns in CTE (temp table) are different than your original table, it will not work

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as NewVaccinesPerDay
FROM PopvsVac


-- USE TEMP TABLE now (example)

DROP Table if exists #PercentPopulationVaccinated -- add drop table to automatically replace any existing tables when making edits
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as NewVaccinesPerDay
FROM #PercentPopulationVaccinated


-- European Union was separated in dataset, create table to join them
	
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- Creating View to store data for later visualizations; creates permanent table for viewing, can write queries off of it too

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths as dea
JOIN dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

CREATE VIEW TotalWorldDeathRates as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null


CREATE VIEW TotalDeathCountPerContinent as
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 AS MaxDeathRate
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent


CREATE VIEW InfectionRateByPopulation as
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM dbo.CovidDeaths
WHERE --location like '%states%'
continent is not null
--ORDER BY 1,2

CREATE VIEW TotalDeathCountCountry as
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


CREATE VIEW HighestInfectionCountperCountry as
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 AS MaxInfectionRate
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
--ORDER BY MaxInfectionRate DESC


--Create a view to include dates

CREATE VIEW HighestInfectionCountperCountryperDay as
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount, population, date, MAX((total_deaths/population))*100 AS MaxDeathRate
FROM dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population, date
--ORDER BY MaxInfectionRate DESC

