SELECT *
FROM PoertfolioProject..[covid-Deaths]
Where Continent is not NULL
ORDER BY 3,4


--SELECT *
--FROM PoertfolioProject..CovidVaccination$
--ORDER BY 3,4

SELECT Location,date,total_cases,new_cases,total_deaths, population
From PoertfolioProject..[covid-Deaths]
Where Continent is not NULL
order by 1,2

-- Looking at total cases vs total deaths 
-- Shows likelihood of dying if you contract covid in your country

SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PoertfolioProject..[covid-Deaths]
Where location like '%states%' 
AND Continent is not NULL
order by 1,2


--Loking at the Total cases vs Population 
-- Shows what percentage of population got covid

SELECT Location,date,population,total_cases, (total_cases/Population)*100 as DeathPercentage
From PoertfolioProject..[covid-Deaths]
Where location like '%states%' 
And Continent is not NULL
order by 1,2

-- Looking at Countries with hightest infection rate compared to Population

SELECT Location,population, Max(total_cases) as HighestInfectioncount, Max((total_cases/Population))*100 as PercentPopulationInfected
From PoertfolioProject..[covid-Deaths]
--Where location like '%states%' 
Where Continent is not NULL
Group by Location, Population
order by PercentPopulationInfected desc

--Showing coountries with highest  Death Count per Population

SELECT Location, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
From PoertfolioProject..[covid-Deaths]
--Where location like '%states%' 
Where Continent is not NULL
Group by Location
order by TotalDeathCount desc

--lET'S BREAK THINGS DOWN BY Location

SELECT location, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
From PoertfolioProject..[covid-Deaths]
--Where location like '%states%' 
Where Continent is NULL
Group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population
-- --lET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
From PoertfolioProject..[covid-Deaths]
--Where location like '%states%' 
Where Continent is not NULL
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date,SUM(new_cases)as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage   
From PoertfolioProject..[covid-Deaths]
--Where location like '%states%' 
WHERE Continent is not NULL
GROUP BY date
order by 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
FROM PoertfolioProject..[covid-Deaths] dea
join PoertfolioProject..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date 
Where dea.continent is not null
Order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population,New_vaccinations, Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
FROM PoertfolioProject..[covid-Deaths] dea
join PoertfolioProject..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3
)
SELECT *, (Rollingpeoplevaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
DROP table if exists #PercentPopulationvaccinated
Create table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationvaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
FROM PoertfolioProject..[covid-Deaths] dea
join PoertfolioProject..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date 
--Where dea.continent is not null
--Order by 2,3
SELECT *, (Rollingpeoplevaccinated/Population)*100
From #PercentPopulationvaccinated 

-- Creating View to store  data for later visualizations

CREATE View PercentPopulationvaccinated2 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location,
dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
FROM PoertfolioProject..[covid-Deaths] dea
join PoertfolioProject..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3