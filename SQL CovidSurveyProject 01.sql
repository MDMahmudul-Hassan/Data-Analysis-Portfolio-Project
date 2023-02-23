select * 
From ProtfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


--select * 
--From ProtfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From ProtfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, Date, Total_cases, total_deaths, (total_deaths/total_cases)*100 as "Deaths Percentage"
From ProtfolioProject..CovidDeaths
Where location like '%state%'
Where continent is not null
Order by 1,2 

-- Looking at Total Cases vs Population
-- Shows What Percentage of Population got Covid

Select Location, date, Population, Total_Cases,  (Total_cases/Population)*100 as PopulationPercentage
From ProtfolioProject..CovidDeaths
Where location like '%state%'
Order by 1,2

-- Looking at Countries with Hight Infection Rate Compared to  Population

Select Location, Population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfected
From ProtfolioProject..CovidDeaths
Group by Location, Population
Order by PopulationInfected desc

-- Showing Countries with Highest Death Count Per Population

Select Location , MAX(cast(Total_deaths as int)) as TotalDeathsCount
From ProtfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathsCount desc

-- LET'S BREAT THINGS DOWN BY CONTINENT

-- Showing the Continets With the Highst Deaths Count

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathsCount
From ProtfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathsCount desc

-- GLOBAL NUMBERS


Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProtfolioProject..CovidDeaths
where continent is not null
order by 1,2

Select * 
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(INT, vac.new_vaccinations)) Over (Partition by dea.Location)
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingpeopleVaccinated
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date 
Where dea.continent is not null

Select *, (rollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to Store Data for Leter Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PercentPopulationVaccinated
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null




