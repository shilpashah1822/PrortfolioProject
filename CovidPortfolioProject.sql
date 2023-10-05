select *
from PortfolioProject..coviddeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..[covidvaccination]
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2

--looking at Total cases vs Total Deaths
--Showing likelyhood of dying iof you contract covid in your country

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
from PortfolioProject..coviddeaths
where location like '%india%'
and continent is not null
order by 1,2

--looking at Total cases vs total Population
--Showing at what percentage of people got covid


select location, date, total_cases,population, new_cases, (total_cases/population)*100 as DeathPrecentage
from PortfolioProject..coviddeaths
where location like '%india%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..coviddeaths
group by location, population
order by PercentagePopulationInfected desc

--countries with highest death count per Population

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc


--showing continents with the highest death count per population

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc 

--Global Numbers


select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2



--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)  
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE 
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating veiw to store data for latter visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select*
from PercentPopulationVaccinated

