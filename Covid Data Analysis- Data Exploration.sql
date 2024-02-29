Select *
From CovidDataAnalysis..CovidDeaths
Where continent is not Null
Order by 3,4

--Select *
--From CovidDataAnalysis..CovidVaccinations
--Order by 4,5

Select Location, date, new_cases, total_cases,total_deaths,population
From CovidDataAnalysis..CovidDeaths
Order by 1,2

--looking at Toatal Cases Vs Total Death 

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage,population
From CovidDataAnalysis..CovidDeaths
where location like 'Ind%' and continent is not Null
Order by 1,2

-- Looking at Total cases Vs Populations
--Shows what percentage of population got covid
Select Location, date, total_cases,total_deaths, (total_cases/population)*100 AS GotCovid,population
From CovidDataAnalysis..CovidDeaths
where location = 'Canada'
Order by 1,2

--Looking at countries with Highest Infection rates compare to populations;
Select location, Max(total_cases) as HighestInfectionCount,population,Max((total_cases/population)*100) AS GotCovid
From CovidDataAnalysis..CovidDeaths
Group by location,population
order by GotCovid desc

-- Let's beak  things down by Continent

-- Showing Countries with Highest death count per populations
Select location, Max(cast(total_deaths as Int)) as TotalDeathcount
From CovidDataAnalysis..CovidDeaths
Where continent is  Null
Group by location
order by TotalDeathcount desc


--Showing continents with highest death per populations

Select continent, Max(cast(total_deaths as Int)) as TotalDeathcount
From CovidDataAnalysis..CovidDeaths
Where continent is not Null
Group by continent
order by TotalDeathcount desc

--Global Numbers 
--Total Cases globally by Dates
Select date, Sum(new_cases), Sum(cast(new_deaths as int)) , Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
From CovidDataAnalysis..CovidDeaths
where continent is not null 
group by date
order by 1,2

-- Total Cases Golbally
Select Sum(new_cases)As Total_cases, Sum(cast(new_deaths as int)) As Total_deaths , Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
From CovidDataAnalysis..CovidDeaths
where continent is not null 
order by 1,2

--Total Vaccination golbally
Select Location,Sum(cast(New_vaccinations as Int)) as Total_vaccinations
from CovidDataAnalysis..CovidVaccinations
Where Location is Not null
group by location
order by Total_vaccinations desc

--Looking total vaccination Vs popluations 

Select dea.continent,dea.location,dea.date,dea.population,Vac.new_vaccinations
,Sum(Convert(Int,Vac.new_vaccinations)) 
Over (Partition by dea.location Order by dea.location,dea.Date) as Rollingpeoplevaccinations 
From CovidDataAnalysis..CovidDeaths Dea
join CovidDataAnalysis..CovidVaccinations Vac
On dea.location = Vac.location
and dea.date = Vac.date
Where dea.continent is not Null
order by 2,3

--USE CTE
with CTE_PopvsVac(continent,Location,Population,Date,new_vaccinations,Rollingpeoplevaccinations) 
as
(
Select dea.continent,dea.location,dea.date,dea.population,Vac.new_vaccinations
,Sum(Convert(Int,Vac.new_vaccinations)) 
Over (Partition by dea.location Order by dea.location,dea.Date) as Rollingpeoplevaccinations 
From CovidDataAnalysis..CovidDeaths Dea
join CovidDataAnalysis..CovidVaccinations Vac
On dea.location = Vac.location
and dea.date = Vac.date
Where dea.continent is not Null
)

Select*,(Rollingpeoplevaccinations/Convert(decimal(8,2),Population)*100)  as VaccinationRate
From CTE_PopvsVac


--Temp Table 


Create Table #populationvaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population Numeric,
New_Vaccinations Numeric,
Rollingpeoplevaccinations numeric
)
Insert Into #populationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,Vac.new_vaccinations
,Sum(Convert(Int,Vac.new_vaccinations)) 
Over (Partition by dea.location Order by dea.location,dea.Date) as Rollingpeoplevaccinations 
From CovidDataAnalysis..CovidDeaths Dea
join CovidDataAnalysis..CovidVaccinations Vac
On dea.location = Vac.location
and dea.date = Vac.date
Where dea.continent is not Null

Select *
From #populationvaccinated


--Creating a view to store data for Later Visualizations
Create View Coviddata As
Select dea.continent,dea.location,dea.date,dea.population,Vac.new_vaccinations
,Sum(Convert(Int,Vac.new_vaccinations)) 
Over (Partition by dea.location Order by dea.location,dea.Date) as Rollingpeoplevaccinations 
From CovidDataAnalysis..CovidDeaths Dea
join CovidDataAnalysis..CovidVaccinations Vac
On dea.location = Vac.location
and dea.date = Vac.date
Where dea.continent is not Null

Select Location, population 
From Coviddata;
