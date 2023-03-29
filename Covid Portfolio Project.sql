SELECT *
FROM [Portfolio Project]..CovidDeaths$
ORDER BY location, date

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations$
--ORDER BY location, date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths$
ORDER BY location, date 

--Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percent
FROM [Portfolio Project]..CovidDeaths$
WHERE location ='Vietnam'
ORDER BY location, date 

--Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Case_Percent
FROM [Portfolio Project]..CovidDeaths$
WHERE location ='Vietnam'
ORDER BY location, date 

--Countries by Highest Infected Percent
SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population)*100) as HighestInfectedPercent
FROM [Portfolio Project]..CovidDeaths$
GROUP BY location, population
ORDER BY HighestInfectedPercent DESC

--Countries by Total Deaths Count till 30/04/2021
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Countries by Total Deaths Count till 30/04/2021
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

--Total Cases vs Total Deaths accross the World per Date
SELECT date, SUM(new_cases) as WorldTotalCases, SUM(CAST(new_deaths as int)) as WolrdTotalDeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS Death_Percent
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY date

--Total Cases vs Total Deaths accross the World till 30/04/2021
SELECT SUM(new_cases) as WorldTotalCases, SUM(CAST(new_deaths as int)) as WolrdTotalDeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS Death_Percent
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null

--Population vs Vaccinations
SELECT CVD.continent, CVD.location, CVD.date, CVD.population, CVC.new_vaccinations, SUM(CAST(CVC.new_vaccinations as int)) OVER (PARTITION BY CVD.location ORDER BY 
CVD.location, CVD.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ as CVD
JOIN [Portfolio Project]..CovidVaccinations$ as CVC
	ON CVD.location = CVC.location
	AND CVD.date = CVC.date
WHERE CVD.continent is not null
ORDER BY CVD.location, CVD.date




-- CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT CVD.continent, CVD.location, CVD.date, CVD.population, CVC.new_vaccinations, SUM(CAST(CVC.new_vaccinations as int)) OVER (PARTITION BY CVD.location ORDER BY 
CVD.location, CVD.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ as CVD
JOIN [Portfolio Project]..CovidVaccinations$ as CVC
	ON CVD.location = CVC.location
	AND CVD.date = CVC.date
WHERE CVD.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationPercent
FROM PopvsVac




-- TEMP TABLE
DROP TABLE IF EXISTS #PercentVaccinated
CREATE TABLE #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentVaccinated
SELECT CVD.continent, CVD.location, CVD.date, CVD.population, CVC.new_vaccinations, SUM(CAST(CVC.new_vaccinations as int)) OVER (PARTITION BY CVD.location ORDER BY 
CVD.location, CVD.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ as CVD
JOIN [Portfolio Project]..CovidVaccinations$ as CVC
	ON CVD.location = CVC.location
	AND CVD.date = CVC.date
WHERE CVD.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationPercent
FROM #PercentVaccinated




--View for later Visualizations
USE [Portfolio Project]
GO
CREATE View PercentVaccinated AS
SELECT CVD.continent, CVD.location, CVD.date, CVD.population, CVC.new_vaccinations, SUM(CAST(CVC.new_vaccinations as int)) OVER (PARTITION BY CVD.location ORDER BY 
CVD.location, CVD.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ as CVD
JOIN [Portfolio Project]..CovidVaccinations$ as CVC
	ON CVD.location = CVC.location
	AND CVD.date = CVC.date
WHERE CVD.continent is not null

SELECT * 
FROM PopvsVac





