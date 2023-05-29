Select * 
from PortfolioProject..CovidDeaths
Where Continent is not null
order by 3,4

--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4


--Select DAta tata  we are going to be using

Select location,date,total_deaths,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

Select location,date,total_deaths,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2



-- Looking at Total Cases vs Population
--shows what percentage of population got covid


Select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulatiionInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2



--Looking at Countries with highest infection rate Compared to Population

Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulatiionInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group BY Location,Population
order by PercentPopulatiionInfected desc


--Showing Countries highest Death Counts per population
Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where Continent is not null
Group BY Location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT


Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where Continent is  not null
Group BY continent
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY Location
Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where Continent is null
Group BY location
order by TotalDeathCount desc


-- Showing Continent with the highest death counts



Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where Continent is  not null
Group BY continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by date
order by 1,2



Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location order By dea.location,dea.Date) as RollingPeopleVAccinated
--(RollingPeopleVAccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


-- USE CTE

With PopVsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVAccinated)
as 

( select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location order By dea.location,dea.Date) as RollingPeopleVAccinated
--(RollingPeopleVAccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)

Select * ,(RollingPeopleVAccinated/Population)*100
From PopVsVac


-- TEMP TABLE

Drop Table If Exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVAccinated numeric
)


Insert into #PercentPopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location order By dea.location,dea.Date) as RollingPeopleVAccinated
--(RollingPeopleVAccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
--order by 2,3

Select * ,(RollingPeopleVAccinated/Population)*100
From #PercentPopulationVaccinated



-- Create View to store data for Vizualisation


DROP Table if exists PercentPopulationVaccinated
create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location order By dea.location,dea.Date) as RollingPeopleVAccinated
--(RollingPeopleVAccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated