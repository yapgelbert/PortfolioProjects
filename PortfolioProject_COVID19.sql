use PortfolioProjectCovid19;
SELECT * 
FROM Covid_deaths;

SELECT * 
FROM Covid_vaccinations;
-- -----------------------------------------------------------------------------------

SELECT 
	location, 
	date,
	population,
	total_cases, 
	new_cases, 
	total_deaths	
FROM Covid_Deaths
	ORDER BY 
		location, date;
-- --------------------------------------------------------------------------------------

-- COVID19 Death Rate 
-- Chances of death for COVID infected person by country
SELECT 
	location, 
	date, 
	total_cases,
	total_deaths,
	(total_deaths/total_Cases)*100 AS death_rate
FROM Covid_Deaths
	--	WHERE location = 'Philippines'
	ORDER BY 
		location,
		date;
-- -------------------------------------------------------------------------------------------

-- Percent of Total Cases over Population 
SELECT 
	location, 
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS Percent_Population_Infected
FROM Covid_Deaths
	-- WHERE location = 'Philippines'
	ORDER BY 
		location, date;
-- -----------------------------------------------------------------------------------------------------

-- Countries with highest infection rate over population
SELECT 
	location, 
	population,
	MAX(total_cases) AS Highest_Infected_Count,
	MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM Covid_Deaths
	GROUP BY
		location,
		population
	ORDER BY 
		Percent_Population_Infected DESC;
-- ----------------------------------------------------------------------------------------------------------

-- country sorted with the largest death count 
SELECT 
	location, 
	MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM Covid_Deaths
WHERE continent IS NOT NULL
	GROUP BY
		location,
		population
	ORDER BY 
		Total_Death_Count DESC;
-- ------------------------------------------------------------------------------------------------------------

-- continent sorted with the largest death count 
SELECT 
	continent, 
	MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM Covid_Deaths
WHERE continent is not null
	GROUP BY
		continent
	ORDER BY 
		Total_Death_Count DESC;
-- -------------------------------------------------------------------------------------------------------------

-- global death percentage 
SELECT
	-- date,
	SUM(new_cases) as total_death,
	SUM(CAST(new_deaths as int)) as total_cases,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Covid_Deaths
	WHERE continent is not null
		-- GROUP BY 
			-- date
		ORDER BY
			total_death,
			total_cases
-- -----------------------------------------------------------------------------------------------------------------

-- JOIN both table Covid_Deaths and Covid_Vaccinations

SELECT *
FROM PortfolioProjectCovid19..Covid_Deaths dea
	JOIN PortfolioProjectCovid19..Covid_Vaccinations vac
		ON dea.location = vac.location
			AND dea.date = vac.date
-- -------------------------------------------------------------------------------------------------------------------

-- Total Population vs Vaccination
-- CTE(Common Table Expression)
WITH Pop_vs_Vacc
	(
		continent,
		location, 
		date, 
		population, 
		new_vaccinations,
		cummulative_total_vaccination
	) 
	AS
	(SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cummulative_total_vaccination
	FROM PortfolioProjectCovid19..Covid_Deaths dea
		JOIN PortfolioProjectCovid19..Covid_Vaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
				WHERE dea.continent is not  null
	)
	SELECT *, (cummulative_total_vaccination/population) * 100
	FROM Pop_vs_Vacc
-- --------------------------------------------------------------------------------------------------

-- TEMPORARY TABLE (same result with CTE)

DROP Table if exists #PercentPopulationVaccinated -- to re-create the table after ateration 
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cummulative_total_vaccination numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cummulative_total_vaccination
	FROM PortfolioProjectCovid19..Covid_Deaths dea
		JOIN PortfolioProjectCovid19..Covid_Vaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
				WHERE dea.continent is not  null;
	
SELECT *, (cummulative_total_vaccination/population) * 100 AS percent_vaccinated
	FROM #PercentPopulationVaccinated
-- ----------------------------------------------------------------------------------------------------------------------------------------------

-- Create data for visualization
CREATE VIEW Percent_Population_Vaccinated AS 
	SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cummulative_total_vaccination
	FROM PortfolioProjectCovid19..Covid_Deaths dea
		JOIN PortfolioProjectCovid19..Covid_Vaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
				WHERE dea.continent is not  null;


SELECT *
FROM Percent_Population_Vaccinated
				