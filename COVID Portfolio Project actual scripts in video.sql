Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking as Total Death vs Total Case
--Shows likelihood dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentsge
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentsge
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

--Looking at total_cases vs Population
-- Show what percentage of population got Covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- looking at Country with Highest Infection rate compared to Population
Select Location, Population, Max(total_cases) as HighInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by 1,2

Select Location, Population, Max(total_cases) as HighInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%india%'
Group by Location, Population
--order by PercentPopulationInfected desc
Select Location, Population, Max(total_deaths) as HighDeath,  Max((total_deaths/population))*100 as PercentPopulationDied
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by Location, Population

--Showing Countries with Highest Death Count per Population
Select Location, Max(total_deaths) as TotalDeathRate
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by Location
order by TotalDeathRate desc


Select Location, Max(cast(total_deaths as int)) as TotalDeathRate
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by Location
order by TotalDeathRate desc

Select *
From PortfolioProject.. CovidDeaths
where continent is not null
order by 3,4


--Lets Break things down by Continent
Select Location, Max(cast(total_deaths as int)) as TotalDeathRate
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not	null
Group by Location
order by TotalDeathRate desc

Select continent, Max(cast(total_deaths as int)) as TotalDeathRate
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is	not null
Group by continent
order by TotalDeathRate desc

--Showing continent with the highest death count per population







--Global Death
Select SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
Where continent is not null
--group by date
order by 1,2


-- Looking total Population VS vassination

--Select *
--From PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--From PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
-------------------------------------------------------------------------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) 
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 
------------------------------------------------------------------------------------
-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE
--Drop Table if exists #PercenPopulationVaccinated 
Create Table #PercenPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercenPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercenPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercenPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercenPopulationVaccinated 


































