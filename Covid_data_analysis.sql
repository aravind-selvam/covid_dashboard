select  location, date_1, total_cases, new_cases, total_deaths, population
from covid_deaths order by 1,2


----------TOTAL CASES VS TOTAL DEATHS IN INDIA----------
----shows what percent of case died------------

select location, date_1, total_cases,total_deaths, 
cast(total_deaths as float) /cast(total_cases as float)*100  as death_percentage from covid_deaths
where location like 'India'
order by 1,2;
--as per 23-03-22 1.2% of total cases died due to Covid (i.e 51.6L people died out of 4.3 crores cases)---

----------TOTAL CASE VS POPULATION IN INDIA--------------
---shows what percent of pouplation got Covid---

select location, date_1,population,total_cases,
(cast(total_cases as float) /population *100)  as death_percentage from covid_deaths
where location like 'India'
order by 1,2;
---as per 23-03-22 3% of population got Covid (i.e 4.3 crores people infected by Covid out of 139.3 crore people)--

----COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION----

select location,population,max (total_cases)as Highestinfection_count,
max((cast(total_cases as float) /population *100)) as percentofpopulation_infected from covid_deaths
group by location, population
order by 4 desc;
---as per 23-03-22 highest affected is Faeroe island 70%, Denmark 52% of popluation got infected-----

----COUNTRIES WITH HIGHEST DEATH COUNT-----

select location, max(cast(total_deaths as int)) Recentdeath_count , 
max((cast(total_deaths as float) /population *100)) as percentofpopulation_died   
from covid_deaths
where total_deaths is not null and continent is not null 
group by location, population
order by 2 desc;
---- TOP 3 Countries with highest deaths are US,Brazil,India-----

----CONTINENTS WITH HIGHEST DEATH COUNT----

select Continent, max(cast(total_deaths as int)) Recentdeath_count     
from covid_deaths
where total_deaths is not null and continent is not null 
group by Continent
order by 2 desc;


--- TOTAL CASES AND TOTAL DEATHS PER DAY THROUGHOUT THE WORLD-----

select date_1 ,sum(new_cases) as total_cases,sum (cast(new_deaths as float)) as total_deaths, 
sum(cast(new_deaths as float))/sum(new_cases)*100 as death_percent 
from covid_deaths 
where continent is not null and new_cases is not null
group by date_1 
order by 1;
---this returns death_percentage of total cases---- 

----TOTAL CASES AND DEATH IN WORLD TILL NOW (world number)-----

select sum(new_cases) as total_cases,sum (cast(new_deaths as float)) as total_deaths, 
sum(cast(new_deaths as float))/sum(new_cases)*100 as death_percent 
from covid_deaths 
where continent is not null and new_cases is not null 
order by total_cases;
--- Total death 1.2% which is 60L deaths on 47 crore cases--

---Each country's population and new vaccinations---

select d.continent,d.location,d.date_1, d.population,v.new_vaccinations,sum(v.new_vaccinations) over 
(partition by d.location order by d.location,d.date_1) as sumofnew_vaccinatons 
from covid_deaths as d
join covid_vaccine as v on d.location = v.location and d.date_1 = v.date_1 where d.continent is not null
order by d.location,d.date
---Returns Cumulative sum of vaccinations done by each country---

---- use cte to find % of each country's population vaccinated----
with poppulation_vaccinated (continent,location,date_1,population,new_vaccinations,sumnew_vaccinations)
as
(
select d.continent,d.location,d.date_1, d.population,v.new_vaccinations,sum(v.new_vaccinations) over 
(partition by d.location order by d.location,d.date_1) as sumnew_vaccinatons 
from covid_deaths as d
join covid_vaccine as v on d.location = v.location and d.date_1 = v.date_1 
where d.continent is not null
order by 2,3
)
select *,(sumnew_vaccinations/population)*100 as percentofpeople_vaccinated
from population_vaccinated 
---Albania as per 23-3-22 has got 14L people vaccinated which is 49% of population------

---Temp table to find % of country's population vaccinated ----

drop table if exists percentage_of_people_vaccinated;
Create table percentage_of_people_vaccinated
(
Continent varchar(255),
location varchar(255),
date_1 date,
population numeric,
new_vaccination numeric,
sumnew_vaccinations numeric
);
insert into percentage_of_people_vaccinated 
select d.continent,d.location,d.date_1, d.population,v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date_1) 
as sumnew_vaccinatons 
from covid_deaths as d
join covid_vaccine as v on d.location = v.location and d.date_1 = v.date_1 
;select *,(sumnew_vaccinations/population)*100 percentofpeople_vaccinated
from percentage_of_people_vaccinated;

-----Create view for visualizations----

create view percentofpeople_vaccinated as
select d.continent,d.location,d.date_1, d.population,v.new_vaccinations,sum(v.new_vaccinations) over 
(partition by d.location order by d.location,d.date_1) as sumnew_vaccinatons 
from covid_deaths as d
join covid_vaccine as v on d.location = v.location and d.date_1 = v.date_1 
where d.continent is not null

----- SQL exploration with Big_dataset----:D
