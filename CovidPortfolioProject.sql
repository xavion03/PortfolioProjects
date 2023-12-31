/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's,  Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2



-- Looking at Total Population vs Vaccinations

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by death.location) as rolling_vaccinated
From CovidDeaths as Death
join CovidVaccinations as Vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinated)
as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by death.location) as rolling_vaccinated
From CovidDeaths as Death
join CovidVaccinations as Vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
)
select *, rolling_vaccinated / population * 100
from PopvsVac


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by death.location) as rolling_vaccinated
From CovidDeaths as Death
join CovidVaccinations as Vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
