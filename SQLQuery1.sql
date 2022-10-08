--DEATHS TABLE

--Highest infected percentage

SELECT location, population, MAX(total_cases) as highinfcnt, MAX((total_cases/population))*100 as infectperc
FROM CovidAnalysis..coviddeaths
GROUP BY location, population
ORDER BY 4 DESC

--Highest death percentage

SELECT location, population, MAX(cast(Total_deaths as bigint)) as highdeathcnt, MAX((Total_deaths/population))*100 as deathperc
FROM CovidAnalysis..coviddeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 DESC

--Which continent did the countries with hgihest death count belong to

SELECT continent, MAX(cast(Total_deaths as int)) as highdeathcnt
FROM CovidAnalysis..coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC


--Continents with highest deaths

SELECT continent, SUM(total_cases) as Totcaspercont
FROM CovidAnalysis..coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--Global numbers

SELECT SUM(new_cases) as GlobCases, SUM(cast(new_deaths as bigint)) as GlobDeaths, (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as GDP
FROM CovidAnalysis..coviddeaths

--VACCINATIONS TABLE

SELECT *
FROM CovidAnalysis..covidvaccines


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollPplVac
FROM CovidAnalysis..coviddeaths dea
JOIN CovidAnalysis..covidvaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Creating a CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollPplVac)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollPplVac
FROM CovidAnalysis..coviddeaths dea
JOIN CovidAnalysis..covidvaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollPplVac/Population)*100
FROM PopvsVac

--TEMP Table

Drop table if exists #VaccinationPercentage
--Should be used if you intend on making alterations to the table later on
--Because table already exists and cannot create another one with same name
Create table #VaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollPplVac numeric
)
Insert into #VaccinationPercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollPplVac
FROM CovidAnalysis..coviddeaths dea
JOIN CovidAnalysis..covidvaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *,(RollPplVac/Population)*100
FROM #VaccinationPercentage


--Creatong view for data visualization use later

Create View VaccinationPercentage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollPplVac
FROM CovidAnalysis..coviddeaths dea
JOIN CovidAnalysis..covidvaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT * 
FROM VaccinationPercentage

