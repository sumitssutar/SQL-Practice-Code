
-- SQL PortfolioProject - Data Exploration on Covid Dataset

-- Link to Dataset - https://ourworldindata.org/covid-deaths
-- From above downloaded dataset, We make two datasets named as 'CovidDeaths' and 'CovidVaccinations' to explore them.

-- Skills used : SQL FUNCTIONS, JOINS, CTE's, Temp Tables, Windows Functions, Aggregate Functions, CREATE VIEWS, Converting Data Types

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Showing CovidDeaths Dataset

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Showing CovidVaccinations Dataset

SELECT *
FROM PortfolioProject..CovidVaccinations
Where continent IS NOT NULL
ORDER BY 3,4

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Now we work on CovidDeaths data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at total_cases vs total_deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Above code gave error as 'Operand data type nvarchar is invalid for divide operator'
-- so we will convert datatype to float and check for NULL values

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------------------------------

-- We can look for perticular Location like Afghanistan

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location ='Afghanistan' AND continent IS NOT NULL
ORDER BY 1,2

-- Result : Recent DeathPercentage Rate in Afghanistanis is 3.4%

--------------------------------------------------------------------------------------------------------------------------------------------------

-- For United States
-- Shows likelihood of dying in your country by COVID

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%States%' AND continent IS NOT NULL
ORDER BY 1,2

-- Result : Recent DeathPercentage Rate in United States is 10%

--------------------------------------------------------------------------------------------------------------------------------------------------

-- * Looking at total_cases vs population
-- shows what percentage of population got COVID in INDIA

SELECT Location, date, population, total_cases, (total_cases/population)*100 as Population_Percentage_got_COVID
FROM PortfolioProject..CovidDeaths
WHERE Location = 'India' AND continent IS NOT NULL
ORDER BY 1,2

-- Result : Max 3% Population got Covid in India

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY InfectedPopulationPercentage DESC

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Countries with Highest Death Count

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Looking at Continents

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------------------------------

-- GLOBAL NUMBERS

-- Looking at Total Cases and Total Deaths in the WORLD

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases) *100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Population VS Vaccinations
-- Shows Percentage of Pupulation that has received at least one Covid Vaccine
-- Here, we JOIN CoviedDeaths Dataset to CovidVaccinations Dataset

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND 
	   dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Gives Rolling Count which adds new_vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND 
	   dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-------------------------------------------------------------------------------------------------------------------------------------------------- 

-- Using CTE(Common Table Expression) to perform Calculation on PARTITION BY in previous query
-- Looking at Percentage of Population Vaccinated as per above columns

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND 
	   dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopvsVac

-- Observation from Results: 49% of Population in Alabania Vaccinated.	

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Temp Tables
-- Now we are going to do same thing by using Temp Tables

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND 
	   dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated

FROM #PercentPopulationVaccinated

--------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATE VIEW to store data for later Visualizations

GO
CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location AND 
	   dea.date = vac.date
WHERE dea.continent IS NOT NULL
GO

SELECT *
FROM PercentPopulationVaccinated 

--------------------------------------------------------------------------------------------------------------------------------------------------

