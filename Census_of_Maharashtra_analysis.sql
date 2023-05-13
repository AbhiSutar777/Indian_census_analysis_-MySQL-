# MAHARASHTRA info
use sql_project;
# Population of maharashtra
SELECT state, SUM(population) AS population
FROM dataset2
WHERE state = 'Maharashtra';

# Top 5 district of maharashtra showing highest population
SELECT state, district, SUM(Population) AS Population
FROM dataset2
WHERE state = 'Maharashtra' 
group by district 
order by Population desc
limit 5 ;

# Sex ratio, Growth and literacy rate of MAHARASHTRA
SELECT state,
SUM(sex_ratio) AS sex_ratio, 
SUM(growth) AS total_growth, 
Round(AVG(literacy),2) AS avg_literacy_rate
FROM dataset1
WHERE state = 'Maharashtra';


## Total number of males and females in each District located in Maharashtra.
SELECT d.district, SUM(d.males) AS total_males, SUM(d.females) AS total_females 
FROM
	(SELECT c.district ,c.state  AS state,ROUND(c.population/(c.sex_ratio+1),0) AS males,
    ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) AS females 
	FROM
		(SELECT a.district,a.state,a.sex_ratio/1000 AS sex_ratio, b.population 
		FROM dataset1 a INNER JOIN dataset2 b 
		ON a.district=b.district
         ) c) d
WHERE d.State = 'Maharashtra'
GROUP BY d.district;

## total number of literate and lliterate population in each District located in Maharashtra.
SELECT c.district,SUM(literate_people) total_literate_people,SUM(illiterate_people) total_iliterate_people 
FROM 
	(SELECT d.district,d.state,ROUND(d.literacy_ratio*d.population,0) literate_people,
	ROUND((1-d.literacy_ratio)* d.population,0) illiterate_people 
    FROM
		(select a.district,a.state,a.literacy/100 literacy_ratio,b.population 
        FROM dataset1 a 
		inner join dataset2 b ON a.district=b.district) d) c
WHERE c.state = 'Maharashtra'
group by c.district;

# Sum of all education of Maharshtra by district
SELECT district, 
	SUM(Below_Primary_Education) Below_Primary_Education,
	SUM(Primary_Education) Primary_Education,
    SUM(Middle_Education) Middle_Education,
    SUM(Secondary_Education) Secondary_Education,
    SUM(Higher_Education) Higher_Education,
    SUM(Graduate_Education) Graduate_Education    
FROM education
WHERE state = 'Maharashtra'
GROUP BY district;

# Graduate Education of all states which is more than Maharashtra
SELECT STATE,
SUM(Graduate_Education) AS Graduate_education
FROM education
WHERE state != 'Maharashtra' AND Graduate_Education > 0
group by state;

# RELIGION
# Top 5 state having high population in hindu
SELECT state,
	SUM(Hindus) AS Hindus
FROM religion
group by state
order by Hindus desc
limit 5 ;

# Total Hindu population in MAHARASHTRA
SELECT state,  SUM(Hindus) AS Hindus
FROM religion
WHERE state = 'Maharashtra';

# Hindu'percentile of MAHARASHTRA by district
SELECT P.district AS District,
    (100 * R.hindus / P.population) AS hindu_percentage
FROM 
    dataset2 P
JOIN 
    religion R
ON 
    P.district=R.district
WHERE 
     P.state = 'Maharashtra'
ORDER BY hindu_percentage desc;     

 # Average of each religion of MAHARASHTRA
SELECT state,
	ROUND(AVG(Hindus),2) Hindus,
	ROUND(AVG(Christians),2) Christians,
	ROUND(AVG(Sikhs),2) Sikhs,
	ROUND(AVG(Buddhists),2) Buddhists,
	ROUND(AVG(Jains),2) Jains,
	ROUND(AVG(Muslims),2) Muslims,
	ROUND(AVG(Others_Religions),2) Others_Religions
FROM religion
WHERE 
	State = 'Maharashtra';
    
## WORKERS
## Top 5 Districts in maharashtra having highest percentage of Agricultural Workers 
SELECT W.district, ROUND(((W.total_Agricultural_workers/P.population)*100),2) AS Perc_of_Agricultural_workers
FROM (SELECT district,SUM(Agricultural_workers) AS total_Agricultural_workers
		FROM workers
        WHERE state = 'Maharashtra'
        GROUP BY district) W JOIN 
	(SELECT district , SUM(Population) AS population
		FROM dataset2
		GROUP BY district) P ON P.district = W.district
GROUP BY W.district
ORDER BY Perc_of_Agricultural_workers DESC
LIMIT 5;


## Percentage of total worker's population divided into of Main workers and Marginal workers in each district of magharashtra
SELECT W.state, W.District, W.total_workers, W.Main_Workers, ROUND(((W.main_workers/W.total_workers)*100),2) AS Perc_of_main_workers, 
				W.marginal_workers, ROUND(((W.Marginal_workers/W.total_workers)*100),2) AS Perc_of_Marginal_workers
FROM (SELECT  state, District, SUM(workers) AS total_workers, SUM(main_workers) AS main_workers , SUM(Marginal_workers) AS Marginal_workers
		FROM workers
        WHERE State = 'Maharashtra'
        GROUP BY state , District) W ;
