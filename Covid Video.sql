--SELECT *
--FROM [Project Portfolio]..CovidDeaths
--WHERE location is not null
--ORDER BY 3,4

--SELECT * 
--FROM [Project Portfolio]..CovidVaccinations
--ORDER BY 3,4

-- Select the Data that we are going to be using --

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM [Project Portfolio]..CovidDeaths
--ORDER BY 1,2

-- Looking at total cases VS total deaths --

--SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM [Project Portfolio]..CovidDeaths
--WHERE location like '%states%'
--ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid

--SELECT Location, date, total_cases, Population, total_deaths, (total_deaths/population)*100 as Percentdied
--FROM [Project Portfolio]..CovidDeaths
--WHERE location like '%states%'
--ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

--SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
--FROM [Project Portfolio]..CovidDeaths
--Group by Location, population
--Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count Per Population --

--SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM [Project Portfolio]..CovidDeaths
--WHERE continent is not null
--Group by Location
--Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT --




-- Showing continents with the Highest Death Count --

--SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM [Project Portfolio]..CovidDeaths
--WHERE continent is not null
--Group by continent
--Order by TotalDeathCount desc

--  Global Numbers for each day --

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/(sum(new_cases)))*100 as DeathPercentage
FROM [Project Portfolio]..CovidDeaths
WHERE continent is not null
Group by date
ORDER BY 1,2


-- Looking at Total Population VS Vaccinations --


SELECT *
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CT --

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



-
DROP Table if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations --


Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated