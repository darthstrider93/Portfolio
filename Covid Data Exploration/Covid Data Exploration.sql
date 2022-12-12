Select * from PortfolioProject..coviddeaths
where continent is not null
order by 3,4;

--Select * from PortfolioProject..covidvaccinations
--order by 3,4;

--The data we are going to be using 

Select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2;

--Total cases vs total death
--Gives a likelihood of death percentage per country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent 
from PortfolioProject..coviddeaths
where location like '%germany'
order by 1,2;


--Total Cases vs Population
--Gives insight into percentage that had covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfect 
from PortfolioProject..coviddeaths
where location like '%germany'
order by 1,2;


--Countries with highest infection rates wrp population
Select Location, Population, max(total_cases) as HighestinfectionCount,  max((total_cases/population))*100 as PercentPopulationInfect
from PortfolioProject..coviddeaths
group by location,population
order by PercentPopulationInfect desc;
	
--Countries with highest death count with respect to population
Select Location, Population, max(cast(total_deaths as int)) as HighestdeathCount
from PortfolioProject..coviddeaths
where continent is not null
group by location,population
order by HighestdeathCount desc;

--Taking a look at continent level 
--(Highest Death Count)
Select Location, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..coviddeaths
where continent is null
group by location
order by TotaldeathCount desc;


-- Global Level 
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as PecentDeath 
from PortfolioProject..coviddeaths
where continent is not null
--group by date
order by 1,2;

--Covid Vaccine Details
Select * from 
PortfolioProject..covidvaccinations
 

 --Total Population vs Vaccinations
 --Join
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths Dea
join PortfolioProject..covidvaccinations Vac
on Dea.location = vac.location 
and Dea.date= vac.date
where dea.continent is not null
order by 2,3


-- Using CTE

with PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths Dea
join PortfolioProject..covidvaccinations Vac
on Dea.location = vac.location 
and Dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac


--With Temp Table

Drop table if exists #percentPopulationVaccinate
Create table #percentPopulationVaccinate
( Continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccincations numeric,
RollingPeopleVaccinated numeric)


insert into #percentPopulationVaccinate
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths Dea
join PortfolioProject..covidvaccinations Vac
on Dea.location = vac.location 
and Dea.date= vac.date
where dea.continent is not null
--order by 2,3
select * , (RollingPeopleVaccinated/Population)*100
from #percentPopulationVaccinate



-- Create View for storage, to be used in data visualisation

 CREATE VIEW
 PercentVaccine as 
 Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths Dea
join PortfolioProject..covidvaccinations Vac
on Dea.location = vac.location 
and Dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentVaccine

