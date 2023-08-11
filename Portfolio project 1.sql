select *
FROM portfolioproject..CovidDeaths
ORDER BY 3, 4 
;

select *
FROM portfolioproject..CovidVaccinations
ORDER BY 3, 4 
;

select Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..CovidDeaths
ORDER BY 1, 2 
;

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2 
;

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM portfolioproject..CovidDeaths
Group by location, population
ORDER BY PercentagePopulationInfected DESC
;

Select location, population, MAX(cast(total_deaths as int)) as DeathCount
FROM portfolioproject..CovidDeaths
WHERE continent is not null
Group by location, population
ORDER BY DeathCount DESC
;

Select SUM(new_cases), SUM(cast (new_deaths as int)), SUM (cast(new_deaths as int))/ SUM (new_cases)*100 as Deathpercentage
FROM portfolioproject..CovidDeaths
WHERE continent is not null
--Group by date
ORDER BY 1, 2 
;

-- Total Population vs Vaccinations 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as

Create View PPV as 
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2, 3


SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric, 
)

SELECT * 
from #PercentPopulationVaccinated


