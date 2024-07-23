select * from CovidDeaths
select * from CovidVaccinations
select distinct location from CovidDeaths


--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Arg%'
order by 1,2


--Looking at Total cases vs Population

select location, date, population,total_cases,(total_cases/population)*100 as PopulationAffectedPercentage
from CovidDeaths
where location like '%Arg%'
order by 1,2


--Looking at countrys with highest infection rates compared to population
select location, population,max(total_cases) as HighestInfectionRate,max((total_cases/population))*100 as PopulationAffectedPercentage
from CovidDeaths
group by location,population
order by PopulationAffectedPercentage desc


--Showing countries whith highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Showing continents with the highest death count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

---Ver que decia alex sobre este query, habia que cambiar cosas de los anteriores



--Global Numbers

select sum(new_cases) as TotalCases,sum(cast (new_deaths as int)) as TotalDeaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as PercentageOfDeaths
from CovidDeaths
where continent is not null
order by 1,2




--Looking at total population vs Vaccinations

select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from CovidDeaths death
join CovidVaccinations vac
	on death.location=vac.location
	and death.date=vac.date
where death.continent is not null
order by 2,3


--CTE

with PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths death
join CovidVaccinations vac
	on death.location=vac.location
	and death.date=vac.date
where death.continent is not null
)

--Problema con ´)´ en la linea 89 buscar en chat gpt
select * from PopVsVac


--Creating view to store data for later visualizations

create view GlobalNumbers as
select sum(new_cases) as TotalCases,sum(cast (new_deaths as int)) as TotalDeaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as PercentageOfDeaths
from CovidDeaths
where continent is not null
--order by 1,2