

Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3, 4

-- Select Data that we are going to using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%australia%'
and continent is not null
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPolutionInfected
From PortfolioProject..CovidDeaths$
--Where location like '%australia%'
Where continent is not null
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfactionCount, Max((total_cases/population))*100 as PercentPolutionInfected
From PortfolioProject..CovidDeaths$
--Where location like '%australia%'
Where continent is not null
Group by location, population
order by PercentPolutionInfected desc



-- Showing Countries with Highest Death Count per Population

Select location, Max(cast(Total_deaths as Int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%australia%'
Where continent is not null
Group by location
order by TotalDeathCount desc



-- Let's break things down by continent

Select location, Max(cast(Total_deaths as Int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%australia%'
Where continent is null
Group by location
order by TotalDeathCount desc



-- Showing continents with the Highest death count per population

Select continent, Max(cast(Total_deaths as Int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%australia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Gloabl numbers

Select date, Sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%australia%'
Where continent is not null
Group by date
order by 1, 2

Select Sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%australia%'
Where continent is not null
-- Group by date
order by 1, 2



-- Looking at total population vs vaccinations

-- use CTE

With PopuvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 1, 2
)
Select *, (RollingPeopleVaccinated/population)*100
From PopuvsVac



-- Temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--order by 1, 2

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating view to store s=data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select*
From PercentPopulationVaccinated
