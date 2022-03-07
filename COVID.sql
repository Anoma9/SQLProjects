-- Showing Tables
SELECT *
FROM AnomaProject..CovidDeaths

SELECT *
FROM AnomaProject..CovidVaccinations

-- I used the first 5 codes to create visualizations in Tableau.

-- 1. Showing the total_cases, total_deaths and DeathPercentage in Nigeria
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From AnomaProject..CovidDeaths
Where location like '%Nigeria%' AND continent is not null 
--Group By date
order by 1,2

--2. Showing the location and TotalDeathCount for each location
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From AnomaProject..CovidDeaths
--Where location like '%nigeria%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3. Showing the location, population, highestinfectionCount and PercentPopulationInfected
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From AnomaProject..CovidDeaths
--Where location like '%nigeria%'
Group by Location, Population
order by PercentPopulationInfected desc

-- 4. Showing the Location, Population, date, HighestInfectionCount and PercentPopulationInfected
 Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  
		Max((total_cases/population))*100 as PercentPopulationInfected
From AnomaProject..CovidDeaths
--Where location like '%nigeria%'
Group by Location, Population, date
order by PercentPopulationInfected desc

-- 5. Showing the global total_cases, total_deaths and DeathPercentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From AnomaProject..CovidDeaths
Where /* location like '%Nigeria%' AND */ continent is not null 
--Group By date
order by 1,2

/* Showing the death rate in Nigeria.
   Also, Showing the probability of getting COVID in Nigeria. */
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathrate
FROM AnomaProject..CovidDeaths
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL 
ORDER BY date

/* Showing the Total Cases against the Population. 
   Also shoing the percentage of people that got COVID*/
SELECT location, date, total_cases, population, (total_cases/population)*100 AS populationinfectedrate
FROM AnomaProject..CovidDeaths
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL
ORDER BY date

-- Showing the deathrate against population
SELECT location, date, total_cases, total_deaths, population, (total_deaths/population)*100 AS deathrate
FROM AnomaProject..CovidDeaths
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL
ORDER BY date

-- Showing countries with the highest infection rate compared to population
SELECT TOP 100 location, population, MAX(total_cases) AS highestinfection, MAX((total_cases/population))*100 AS infectionrate
FROM AnomaProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infectionrate DESC;

-- Showing countries with the highest Death Count per Population
SELECT TOP 100 location, population, MAX(total_deaths) AS highestdeaths, MAX((total_deaths/population))*100 AS deathrate
FROM AnomaProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY deathrate DESC;

SELECT TOP 100 location, MAX(CAST(total_deaths as INT)) AS maxdeathrate
FROM AnomaProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY maxdeathrate DESC;

-- Showing Data by continents
SELECT continent, MAX(CAST(total_deaths as INT)) AS maxdeathrate
FROM AnomaProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY maxdeathrate DESC;

SELECT location, MAX(CAST(total_deaths as INT)) AS maxdeathrate
FROM AnomaProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY maxdeathrate DESC;

SELECT continent, MAX(CAST(Total_deaths AS INT)) maxdeathrate
FROM AnomaProject..CovidDeaths
GROUP BY continent
ORDER BY maxdeathrate DESC;

-- SHOWING THE GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	   SUM(CAST(new_deaths AS INT))/SUM(CAST(new_cases AS INT))*100 AS DeathPercentage
FROM AnomaProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2, 3

SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
			 SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM AnomaProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- COMBINING CovidDeaths and CovidVaccinations columns
SELECT *
FROM AnomaProject..CovidDeaths AS Deaths
JOIN AnomaProject..CovidVaccinations AS Vac
ON Deaths.location = Vac.location
AND Deaths.date = Vac.date

-- SHOWING THE TOTAL POPULATION VS VACCINATIONS
SELECT Deaths.continent, Deaths.date, Deaths.population, Vac.new_vaccinations, Vac.total_vaccinations
FROM AnomaProject..CovidDeaths AS Deaths
JOIN AnomaProject..CovidVaccinations AS Vac
ON Deaths.location = Vac.location
AND Deaths.date = Vac.date

SELECT Deaths.continent, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS BIGINT))
	   OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingPpleVac
FROM AnomaProject..CovidDeaths AS Deaths
JOIN AnomaProject..CovidVaccinations AS Vac
ON Deaths.location = Vac.location
AND Deaths.date = Vac.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 2,3

WITH PopVsVac(continent, location, date, population, new_vaccinations, RollingPpleVac)
AS 
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS BIGINT))
	   OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingPpleVac
FROM AnomaProject..CovidDeaths AS Deaths
JOIN AnomaProject..CovidVaccinations AS Vac
ON Deaths.location = Vac.location
AND Deaths.date = Vac.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *
FROM PopVsVac