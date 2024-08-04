
select * from CovidDeaths
where continent is not null
order by 3,4

--select * from CovidVaccinations
--order by 3,4

--select data that ww're going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Nigeria%' or location like '%States%'
and continent is not null
order by 1,2

--Looking at the total cases vs the population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from CovidDeaths
--where location like '%Nigeria%' or location like '%States%'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%Nigeria%'
where continent is not null 
group by population, location
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

select location, max(total_deaths) as TotalDeaths
from CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location
order by TotalDeaths desc


--select * from CovidDeaths
----where continent is not null
--order by 3,4

--update CovidDeaths
--set 
--new_cases = nullif(new_cases, 0),
--new_deaths = nullif(new_deaths, 0)

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(total_deaths) as TotalDeaths
from CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeaths desc

--The continents with the highest death count

select continent, max(total_deaths) as TotalDeaths
from CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeaths desc

--GLOBAL NUMBERS

select sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2 

--Total Cases and Deaths across the world

select sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2 

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USING CTE

with PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentPolulationVaced
from #PercentPopulationVaccinated

--Creating views to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert (float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated