Select * 
from PortfolioProject..CovidDeaths
order by 3,4

Select location, date,total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeatPercentage
From PortfolioProject..CovidDeaths
where location like '%Canada%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows % of population got covid

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
order by 1,2


-- Looking at Countries with highest Infection Rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 
as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
group by location, population
order by PercentageOfPopulationInfected Desc

-- Showing countries with highest Death count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
where continent is not null
group by location
order by TotalDeathCount Desc

-- Break thigs by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
where continent is not null
group by continent
order by TotalDeathCount Desc

--Showing continent with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
where continent is not null
group by continent
order by TotalDeathCount Desc

-- Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeatPercentage
From PortfolioProject..CovidDeaths
--where location like '%Canada%'
where continent is not null
group by date
order by 1,2

-- Looking at Total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinatied
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

--USE CTE

With PopvsVac (Continent,Location,Date,Population,new_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinatied
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinatied
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 1,2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinatied
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidDeaths vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null