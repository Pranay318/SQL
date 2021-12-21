SELECT * FROM [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
order by 3,4

SELECT * FROM [Portfolio Project]..CovidVaccinations
order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER by 1,2

-- Looking at total_cases vs total_deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%India%'
ORDER by 1,2

--Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
 WHERE location like '%India%'
ORDER by 1,2


----looking at countries with Highest Ifection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%India%'
GROUP BY location, Population
order by PercentPopulationInfected desc

--Showing the countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE Location like '%India%'
WHERE continent is not NULL
GROUP BY location, Population
order by TotalDeathCount desc

--Let's BREAK things down by continent
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%India%'
WHERE continent is not NULL
GROUP BY Location
order by TotalDeathCount desc

----Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%India%'
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount desc


--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
order by 1,2

SELECT * FROM [Portfolio Project]..CovidVaccinations

----Join the tables 
SELECT * 
FROM [Portfolio Project]..CovidVaccinations vac
JOIN [Portfolio Project]..CovidDeaths dea
ON dea.location = vac.location
and dea.date = vac.date

--Looking at total population vs vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition BY dea.Location ORDER BY dea.Location,dea.Date) as RollingPeopleVaccinated,
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3

--USE CTE
WITH PopvsVac (Continent,Location,Date,Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition BY dea.Location ORDER BY dea.Location,dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject]..CovidDeaths dea
Join [PortfolioProject]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
----where dea.continent is not null 

SELECT * FROM PercentPopulationVaccinated