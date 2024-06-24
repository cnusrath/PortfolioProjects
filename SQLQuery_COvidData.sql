select * 
from COVIDeaths
order by 3, 4


--select * 
--from CovidVaccines
--order by 3, 4


----Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project1..COVIDeaths
Order by 1, 2


-----Looking at Total Cases vs Total Deaths 
---shows likelihood of dying if you contract covid in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project1..COVIDeaths
where location like '%state%'
Order by 1, 2

--ALTER TABLE Portfolio_Project1..COVIDeaths
--ALTER COLUMN population numeric;


----Looking at the total cases vs population 
----Shows what percentage of population got covid 

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project1..COVIDeaths
where location like '%state%'

----Looking at coutntries with Highets Infection Rate compare to Population 

Select Location, population, MAx(total_cases) as HighestInfectionCount, 
Max((total_cases/population)*100) as PercentPopulationInfected
From Portfolio_Project1..COVIDeaths
Where continent is not null
Group By location, population
Order by PercentPopulationInfected desc


----Showing Countries with the Highest Death Count per Population 

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount 
From Portfolio_Project1..COVIDeaths
Where Continent is not null ---try with null here 
Group By location
Order by TotalDeathCount desc

---LET'S BREAK THINGS DOWN BY CONTINENT

---Showing continents with the highest death count per Population 

Select Continent, Max(cast(Total_deaths as int)) as TotalDeathCount 
From Portfolio_Project1..COVIDeaths
Where Continent is not null
Group By Continent
Order by TotalDeathCount desc


---Global numbers 

/*Select date, Sum(new_cases)as total_cases, sum(new_deaths) as total_deaths, 
sum(cast(new_deaths as float))/Sum(cast(new_cases as float)) * 100 as DeathPercentage 
From Portfolio_Project1..COVIDeaths
Where Continent is not null
Group by date 
Order by 1, 2 */

SELECT  date, SUM(ISNULL(new_cases, 0)) AS total_cases, SUM(ISNULL(new_deaths, 0)) AS total_deaths, 
    CASE 
        WHEN SUM(ISNULL(new_cases, 0)) = 0 THEN 0
        ELSE SUM(ISNULL(new_deaths, 0)) * 100.0 / SUM(ISNULL(new_cases, 0))
    END AS DeathPercentage 
FROM Portfolio_Project1..COVIDeaths
WHERE Continent IS NOT NULL
GROUP BY date 
ORDER BY date, total_cases


---Looking at Total Population Vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated

FROM Portfolio_Project1..COVIDeaths dea 
JOIN Portfolio_Project1..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date

WHERE dea.Continent IS NOT NULL
Order by 2, 3 


---USE CTE
---SHOWS HOW MANY PEOPLE ARE VACCINATED IN EACH COUNTRY 

With PopVsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)

as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated

FROM Portfolio_Project1..COVIDeaths dea 
JOIN Portfolio_Project1..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date

WHERE dea.Continent IS NOT NULL
)

Select *, (rollingPeopleVaccinated/population) *100 as VaccinePercentage
From PopVsVac
--Where location = 'Albania'

---TEMP TABLE:

---if any alteration needs to be made: run with the following drop table query 
--DROP TABLE IF exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
Date nvarchar(255),
population numeric,
New_Vaccinaions numeric,
rollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as rollingPeopleVaccinated

FROM Portfolio_Project1..COVIDeaths dea 
JOIN Portfolio_Project1..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date

WHERE dea.Continent IS NOT NULL

Select *, (rollingPeopleVaccinated/population) *100 as VaccinePercentage
From #PercentPopulationVaccinated


----Creating View to store Data for later visualizations 
USE Portfolio_Project1
GO 
CREATE View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as rollingPeopleVaccinated

FROM Portfolio_Project1..COVIDeaths dea 
JOIN Portfolio_Project1..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date

WHERE dea.Continent IS NOT NULL
GO


SELECT * 
FROM PercentPopulationVaccinated
