USE sql_project;
## Dataset 1
SELECT * 
FROM dataset1;

## Dataset 2
SELECT * 
FROM dataset1;

##  number of rows into our dataset 1
SELECT COUNT(*) 
FROM dataset1;

##  number of rows into our dataset 2
SELECT COUNT(*) 
FROM dataset2;

## dataset for Maharashtra and Gujarat
 SELECT* 
FROM dataset1 
where state in ('Maharashtra' ,'Gujarat');

## population of India
SELECT SUM(population) as Population 
FROM dataset2;

## average growth 
SELECT state,ROUND(avg(growth)*100,2) avg_growth 
FROM dataset1 
group by state;

## average sex ratio
SELECT state,ROUND(avg(sex_ratio),0) avg_sex_ratio 
FROM dataset1 
group by state 
order by avg_sex_ratio desc;

## average literacy rate
SELECT state,ROUND(avg(literacy)) avg_literacy_ratio
FROM dataset1
group by state 
order by avg_literacy_ratio desc ;

## top 5 state showing highest growth ratio
SELECT state, avg(growth)*100 avg_growth 
FROM dataset1 
group by state 
order by avg_growth desc
limit 5 ;


### bottom 5 state showing lowest sex ratio
SELECT state, ROUND(avg(sex_ratio)) avg_sex_ratio 
FROM dataset1 
group by state 
order by avg_sex_ratio asc
limit 5 ;

## State having highest number of workest
SELECT State, SUM(Workers) AS total_workers
FROM Workers
GROUP BY State
ORDER BY total_workers DESC;

## District having highest number of workest
SELECT District, SUM(Workers) AS total_workers
FROM Workers
GROUP BY District
ORDER BY total_workers DESC;

## Total Male and Female workers in each state
SELECT State , SUM(male_workers) AS total_male_workers , SUM(female_workers) AS total_male_workers
FROM Workers
GROUP BY State;

## Top 5 states having highest number Agricultural Workers
SELECT state, SUM(Agricultural_workers) AS total_Agricultural_workers
FROM Workers
GROUP BY State
ORDER BY total_Agricultural_workers DESC
LIMIT 5;

## Top 5 states having highest percentage of Agricultural Workers 
SELECT W.state, ROUND(((W.total_Agricultural_workers/P.population)*100),2) AS Perc_of_Agricultural_workers
FROM (SELECT State,SUM(Agricultural_workers) AS total_Agricultural_workers
		FROM workers
        GROUP BY State) W JOIN 
	(SELECT State , SUM(Population) AS population
					FROM dataset2
                    GROUP BY State) P ON P.state = W.state
GROUP BY W.state
ORDER BY Perc_of_Agricultural_workers DESC
LIMIT 5;

## Percentage of total worker's population divided into of Main workers and Marginal workers by State
SELECT W.state, ROUND(((W.main_workers/W.workers)*100),0) AS Perc_of_main_workers, 
				ROUND(((W.Marginal_workers/W.workers)*100),0) AS Perc_of_Marginal_workers
FROM (SELECT  State, SUM(workers) AS workers, SUM(main_workers) AS main_workers , SUM(Marginal_workers) AS Marginal_workers
		FROM workers
        GROUP BY State) W 
GROUP BY W.state;

## top and bottom 5 states in literacy state
# creating a table for Topstates
create table top_literacy( 
state varchar(255),
top_literacy_rate float
);

insert into top_literacy
SELECT state,ROUND(avg(literacy)) avg_literacy_ratio 
FROM dataset1 
group by state 
order by avg_literacy_ratio desc;

SELECT * 
FROM top_literacy
order by top_literacy_rate desc;

# creating a table for Bottomstates
create table bottom_literacy( 
state varchar(255),
bottom_literacy_rate float
);

insert into bottom_literacy
SELECT state,ROUND(avg(literacy),0) avg_literacy_ratio 
FROM dataset1
group by state 
order by avg_literacy_ratio desc;

SELECT * 
FROM bottom_literacy 
order by bottom_literacy_rate asc;

## Using union opertor
SELECT * 
FROM 
	(SELECT * 
	FROM top_literacy 
	order by top_literacy_rate desc
	limit 5) a UNION
	SELECT* FROM
	(SELECT * 
	FROM bottom_literacy
	order by bottom_literacy_rate asc
	limit 5) b;

## States having Total Population less than the average population of all States.
SELECT A.State, A.total_population
FROM (SELECT State , SUM(Population) AS total_population FROM dataset2 GROUP BY State) A
WHERE A.total_population < (SELECT AVG(Population) AS avg_population 
						FROM dataset2)
GROUP BY State
ORDER BY total_population DESC;

## States having Total Population Greater than the average population of all States.
SELECT A.State, A.total_population
FROM (SELECT State , SUM(Population) AS total_population FROM dataset2 GROUP BY State) A
WHERE A.total_population > (SELECT AVG(Population) AS avg_population 
						FROM dataset2)
GROUP BY State
ORDER BY total_population DESC;


## state names starting with letter a
SELECT distinct state 
FROM dataset1 
WHERE state like 'a%' or state like 'b%';

## state names starting with letter a and ending with letter m
SELECT distinct state 
FROM dataset1 
WHERE state like 'a%' and state like '%m';

# Average of every column of literate and education 
SELECT state,
       ROUND(AVG(literate),0)  total_literate, 
       ROUND(AVG(Male_Literate),0)  male_literate, 
	   ROUND(AVG(Female_Literate),0)  female_literate,
       ROUND(AVG(Below_Primary_Education),0) Below_Primary_Education,
       ROUND(AVG(Primary_Education),0) Primary_Education,
       ROUND(AVG(Middle_Education),0) Primary_Education,
       ROUND(AVG(Secondary_Education),0) Secondary_Education,
       ROUND(AVG(Higher_Education),0) Higher_Education,
       ROUND(AVG(Graduate_Education),0) Graduate_Education,
       ROUND(AVG(Total_Education),0) Total_Education
FROM education
GROUP BY state;

## joining both table
## total males and females
SELECT d.state,SUM(d.males) total_males,SUM(d.females) total_females 
FROM
	(SELECT c.district,c.state state,ROUND(c.population/(c.sex_ratio+1),0) males, ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females 
	FROM
		(SELECT a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population 
		FROM dataset1 a inner join dataset2 b 
		ON a.district=b.district ) c) d
group by d.state;

## total literacy rate
SELECT c.state,SUM(literate_people) total_literate_pop,SUM(illiterate_people) total_lliterate_pop 
FROM 
	(SELECT d.district,d.state,ROUND(d.literacy_ratio*d.population,0) literate_people,
	ROUND((1-d.literacy_ratio)* d.population,0) illiterate_people 
    FROM
		(SELECT a.district,a.state,a.literacy/100 literacy_ratio,b.population 
        FROM dataset1 a 
		inner join dataset2 b on a.district=b.district) d) c
group by c.state;

## population in previous census
SELECT SUM(m.previous_census_population) previous_census_population,SUM(m.current_census_population) current_census_population 
FROM
	(SELECT e.state,SUM(e.previous_census_population) previous_census_population,SUM(e.current_census_population) current_census_population 
    FROM
		(SELECT d.district,d.state,ROUND(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population 
		FROM
			(SELECT a.district,a.state,a.growth growth,b.population FROM dataset1 a inner join dataset2 b on a.district=b.district) d) e
group by e.state)m;

## window 
# output top 3 districts from each state with highest literacy rate
SELECT a.* FROM
(SELECT district,state,literacy,rank() over(partition by state order by literacy desc) rnk 
FROM dataset1) a
WHERE a.rnk in (1,2,3) 
order by state