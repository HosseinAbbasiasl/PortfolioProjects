Select *
from PortfolioProject..CovidDeaths
where continent is not Null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not Null
order by 1,2

-- Looking at total cases versus total deaths 

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like  '%States%'
and continent is not Null
order by 1,2

-- Looking at total cases vs population
-- shows what percentage of population got covid

Select Location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--where location like  '%States%'
order by 1,2

-- Looking at countries with the highest infection rate compared to population 

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--where location like  '%States%'
Group By location, population
order by PercentPopulationInfected DESC


-- Showing the Countries With the Highest Death Count per Population

Select Location, MAX(cast(total_deaths AS INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like  '%States%'
where continent is not Null
Group By location
order by TotalDeathCount DESC

--Let's Break Things Down by Continent

Select continent, MAX(cast(total_deaths AS INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like  '%States%'
where continent is not Null
Group By continent
order by TotalDeathCount DESC


--Showing Continents with the Hihest Death Count

Select continent, MAX(cast(total_deaths AS INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like  '%States%'
where continent is not Null
Group By continent
order by TotalDeathCount DESC



-- Global Numbers 


Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like  '%States%'
where continent is not Null
--Group by date
order by 1,2


-- looking at total population versus vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as INT)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not Null
order by 2, 3


--USE OF CTE


WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as INT)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not Null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as INT)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not Null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





--Creating View to Store Data for later Visualisations

Use PortfolioProject
go
Create View PercentPopulationWhichVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as INT)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not Null
--order by 2, 3


Select *
From PercentPopulationWhichVaccinated