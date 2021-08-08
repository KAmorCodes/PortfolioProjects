SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaxx
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2


-- Looking at total cases vs total deaths in Canada and Nigeria

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Nigeria%' OR location like '%Canada%'
ORDER BY 1,2

-- looking at the total cases vs population in Canada and Nigeria to show what percentage of population has got COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Nigeria%' OR location like '%Canada%'
ORDER BY 1,2


-- looking at countries with highest infection rate compared with population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY 4 

--Looking at countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths as INT)) as MaxDeaths, population, MAX((total_deaths/population)*100) as DeathPercentagepopulation
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT Null
GROUP BY location, population
ORDER BY 2 DESC


-- Looking at continents with highest death count per population

SELECT location, MAX(CAST(total_deaths as INT)) as MaxDeaths, population, MAX((total_deaths/population)*100) as DeathPercentagepopulation
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS Null
GROUP BY population, location
ORDER BY 4 DESC

-- Global Numbers on my birthday

SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, (SUM(cast(new_deaths as INT))/SUM(new_cases))*100 as DeathPercentage --(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Nigeria%' OR location like '%Canada%'
WHERE continent IS NOT null
AND date = '2020-09-22 00:00:00.000'
GROUP BY date
ORDER BY 1


--join table

SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaxx vac
	On dea.location = vac.location
	AND dea.date = vac.date
	ORDER BY dea.date

-- total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaxx vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaxx vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaxx vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Create View to store data fro later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaxx vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated