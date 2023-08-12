select *
FROM portfolioproject..CovidDeaths
ORDER BY 3, 4 

select *
FROM portfolioproject..CovidVaccinations
ORDER BY 3, 4 

select Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..CovidDeaths
ORDER BY 1, 2 

-- Looking at Total cases vs Total Deaths 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
ORDER BY 1, 2 

-- Total cases vs Total Deaths in United States 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2 

-- Looking at Total cases vs Population in United States 
Select location, date, total_cases, population, (total_cases/population) *100 as CasesPopulation 
FROM portfolioproject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2 

-- What countries have the highest infection rate?
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM portfolioproject..CovidDeaths
Group by location, population
ORDER BY PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count per Population 
Select location, population, MAX(cast(total_deaths as int)) as DeathCount
FROM portfolioproject..CovidDeaths
WHERE continent is not null
Group by location, population
ORDER BY DeathCount DESC

-- Continents with Highest Death Count 
Select continent, MAX(cast(total_deaths as int)) as DeathCount
FROM portfolioproject..CovidDeaths
WHERE continent is not null
Group by continent
ORDER BY DeathCount DESC

-- GLOBAL death percentage
Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int))/ SUM (new_cases)*100 as Deathpercentage
FROM portfolioproject..CovidDeaths
WHERE continent is not null
Group by date
ORDER BY 1, 2 

-- Total Population vs Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
ORDER by 2,3 

-- CTE for Percent of population vaccinated 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp table forpercent of vaccination vaccinated 
DROP TABLE if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric, 
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2, 3


SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

-- Creating View to store data for later visualizations
Create View PercentpopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2, 3


