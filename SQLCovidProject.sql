
Select * From SQLProject..CovidDeaths
Order by 3, 4


Select Location, date, total_cases, new_cases, total_deaths, population 
From SQLProject..CovidDeaths
Order by 1,2



-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLProject..CovidDeaths 
Where Location Like '%States%'
Order by 1, 2



--Looking at Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionsbyPop
From SQLProject..CovidDeaths 
Where Location Like '%States%'
Order by 1, 2



--Looking at Countries with Highest Infection Rates

Select Location, population, max(total_cases) AS HighestInfectionCount
, Max(total_cases/population)*100 AS 
PercentOfPopulationInfected
From SQLProject..CovidDeaths 
--Where Location Like '%States%'
Group By Location, population
Order by PercentOfPopulationInfected Desc



--Showing Countries with Highest DeathCount

Select location, Max(Cast(total_deaths as INT)) AS TotalDeathCount 
From SQLProject..CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount Desc



--Showing Continents with Highest DeathCount

Select location, Max(Cast(total_deaths as INT)) AS TotalDeathCount 
From SQLProject..CovidDeaths
Where continent is null
Group By location
Order By TotalDeathCount Desc



--Showing Countries with Highest DeathCount per Population

Select Location, population, Max(Cast(total_deaths as INT)) AS TotalDeathCount
, (Max(total_deaths)/population)*100 As
DeathsPerPopulationPercentage 
From SQLProject..CovidDeaths
Where continent is not null
Group By Location, population
Order By DeathsPerPopulationPercentage Desc



--Total cases, deaths, and DeathsPerCases for World

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths AS Int)) as total_deaths
, Sum(Cast(new_deaths as int))/ Sum(new_cases) *100 as DeathsPerCasesPercentage
From SQLProject..CovidDeaths 
--Where Location Like '%States%'
Where continent is not null
--Group by date
Order by 1, 2



--Total cases, deaths, and DeathsPerCases for World per day

Select date, Sum(new_cases) as total_cases, Sum(Cast(new_deaths AS Int)) as total_deaths
, Sum(Cast(new_deaths as int))/ Sum(new_cases) *100 as DeathsPerCasesPercentage
From SQLProject..CovidDeaths 
--Where Location Like '%States%'
Where continent is not null
Group by date
Order by 1, 2



--Looking at Total Population vs Vaccinations Using a CTE

Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS 
RollingVacCount 
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	

--CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingVacCount)
as
(
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS 
RollingVacCount 
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
)

Select *, (RollingVacCount/Population) *100
From PopVsVac




--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVacCount numeric
)


Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS 
RollingVacCount 
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null

	Select *, (RollingVacCount/Population) *100
From #PercentPopulationVaccinated



--Create View to store data in for later Visualizations 

Create View PercentPopulationVaccinated as
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS 
RollingVacCount 
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null


Select * 
From PercentPopulationVaccinated