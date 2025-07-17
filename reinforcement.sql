use imdb;

select * from director_mapping;
select * from genre;
select * from movie;
select * from names;
select * from ratings;
select * from role_mapping;

 -- Count the total number of records in each table of the database.[1]  
 
 select count(*) as count_of_directormapping from director_mapping;
 select count(*) as count_of_genre from genre;
 select count(*) as count_of_movie from movie;
 select count(*) as count_of_names from names;
 select count(*) as count_of_ratings from ratings;
 select count(*) as count_of_rolemapping from role_mapping;
 
-- Identify which columns in the movie table contain null values.[2]

select * from movie where title is null or date_published is null or duration is null or country is null or 
worlwide_gross_income is null or languages is null or production_company is null;

SELECT 
CASE WHEN COUNT(*) - COUNT(title) > 0 THEN 'title has nulls' 
ELSE'title has no nulls'
END AS title,
CASE WHEN COUNT(*) - COUNT(year) > 0 THEN 'year has nulls'
ELSE'year has no nulls'
END AS year,
CASE WHEN COUNT(*) - COUNT(duration) > 0 THEN 'duration has nulls' 
ELSE'duration has no nulls'
END AS duration,
CASE WHEN COUNT(*) - COUNT(country) > 0 THEN 'country has nulls' 
ELSE'country has no nulls'
END AS country,
CASE WHEN COUNT(*) - COUNT(worlwide_gross_income) > 0 THEN 'worlwide_gross_income has nulls' 
ELSE'worlwide_gross_income has no nulls'
END AS worlwide_gross_income,
CASE WHEN COUNT(*) - COUNT(date_published) > 0 THEN 'date_published has nulls' 
ELSE'date_published has no nulls'
END AS date_published,
CASE WHEN COUNT(*) - COUNT(languages) > 0 THEN 'languages has nulls'
ELSE'languages has no nulls'
 END AS languages,
CASE WHEN COUNT(*) - COUNT(production_company) > 0 THEN 'production_company has nulls' 
ELSE'production_company has no nulls'
END AS production_company
FROM movie;

-- Determine the total number of movies released each year, and analyze how the trend changes month-wise.[3]

SELECT 
  release_year,
  total_movies,
  RANK() OVER (ORDER BY total_movies DESC) AS ranking
FROM (
  SELECT 
    YEAR(date_published) AS release_year,
    COUNT(title) AS total_movies
  FROM 
    movie
  GROUP BY 
    YEAR(date_published)
) AS subquery
ORDER BY 
  total_movies DESC;

SELECT 
 RANK() OVER (ORDER BY total_movies DESC) AS ranking,
 ELT(release_month, 'January', 'February', 'March', 'April', 'May', 'June', 
 'July', 'August', 'September', 'October', 'November', 'December') AS release_month_name,
  release_month,
  total_movies
FROM (
  SELECT 
    MONTH(date_published) AS release_month,
    COUNT(title) AS total_movies
  FROM 
    movie
  GROUP BY 
    MONTH(date_published)
) AS subquery
ORDER BY 
  total_movies DESC;


--  How many movies were produced in either the USA or India in the year 2019?[4]

SELECT COUNT(title) AS number_of_movies_in_usa_or_india_from_2019 
FROM movie
 where (country="USA" OR country="INDIA") AND (YEAR="2019");

-- List the unique genres in the dataset, and count how many movies belong exclusively to one genre.[5]

SELECT RANK()OVER(ORDER BY COUNT(movie_id) DESC) AS ranking,COUNT(movie_id) AS no_movie,genre
 FROM genre GROUP BY genre ORDER BY
 COUNT(movie_id) DESC; -- [top three-drama,comedy,thriller]

--  Which genre has the highest total number of movies produced?[6]

SELECT genre,COUNT(movie_id) AS no_movie
 FROM genre 
 GROUP BY genre 
 ORDER BY COUNT(movie_id) DESC LIMIT 1;

-- Calculate the average movie duration for each genre.[7]

SELECT RANK()OVER(ORDER BY AVG(m.duration) DESC)AS ranking,g.genre,AVG(m.duration) FROM
genre g INNER JOIN movie m ON
g.movie_id=m.id GROUP BY genre;

-- dentify actors or actresses who have appeared in more than three movies with an average rating below 5.[8]


SELECT n.name, r.category, m.movie_count, m.avg_ratings
FROM names n INNER JOIN role_mapping r 
ON n.id = r.name_id
  INNER JOIN (SELECT 
      m.id,COUNT(m.title) AS movie_count, 
      AVG(rs.median_rating) AS avg_ratings
    FROM movie m 
      INNER JOIN ratings rs ON m.id = rs.movie_id
    GROUP BY m.id
    HAVING COUNT(m.title) > 3 AND AVG(rs.median_rating) < 5)m ON r.movie_id = m.id;

-- Find the minimum and maximum values for each column in the ratings table, excluding the movie_id column.[9]

SELECT MAX(avg_rating) AS max_averagerating,MIN(avg_rating) AS min_averagerating,
MAX(total_votes) AS maxvotes,MIN(total_votes) AS minvotes,
MAX(median_rating) AS max_medianrating,MIN(median_rating) AS min_medianrating 
FROM ratings;

-- Which are the top 10 movies based on their average rating?[10]

SELECT RANK()OVER (ORDER BY r.avg_rating DESC)AS ranking,m.title,r.avg_rating 
FROM movie m inner join ratings r
ON m.id=r.movie_id GROUP BY m.title,m.id 
ORDER BY avg_rating DESC LIMIT 10;

 -- Summarize the ratings table by grouping movies based on their median ratings.[11]
 
 SELECT m.title,r.total_votes,r.median_rating
 FROM movie m INNER JOIN ratings r
 ON m.id=r.movie_id GROUP BY r.movie_id 
 ORDER BY median_rating ASC;
 
-- How many movies, released in March 2017 in the USA within a specific genre, had more than 1,000 votes?[12]

SELECT COUNT(m.title),m.year,m.country,g.genre
FROM movie m INNER JOIN genre g
ON m.id=g.movie_id 
INNER JOIN ratings r 
ON r.movie_id=m.id 
WHERE year="2017" AND country="usa" AND genre="romance"AND total_votes>"1000"
GROUP BY 
  m.year, m.country, g.genre;

-- Find movies from each genre that begin with the word “The” and have an average rating greater than 8.[13]

SELECT g.genre,m.title,r.avg_rating
FROM movie m INNER JOIN genre g ON
m.id=g.movie_id 
INNER JOIN ratings r 
ON r.movie_id=m.id
 HAVING title LIKE"the%" AND avg_rating>"8";

-- No Of the movies released between April 1, 2018, and April 1, 2019, how many received a median rating of 8?[14]

SELECT COUNT(m.title) AS number_movies_relesed_in_from_18to19,r.median_rating
FROM movie m INNER JOIN ratings r ON
m.id=r.movie_id
 WHERE median_rating="8" AND (date_published >= '2018-04-01' 
  AND date_published< '2019-04-01');
  
  -- Do German movies receive more votes on average than Italian movies?[15]
  
  SELECT RANK()OVER (ORDER BY AVG(r.total_votes)DESC) AS ranking,COUNT(m.title),m.country,AVG(r.total_votes)
  FROM movie m INNER JOIN ratings r
  ON m.id=r.movie_id
  WHERE m.country IN ("germany","italy") GROUP BY country; 
  
  SELECT 
  CASE 
    WHEN (
      SELECT SUM(r.total_votes) 
      FROM movie m 
      INNER JOIN ratings r ON m.id = r.movie_id 
      WHERE m.country = "germany"
    ) > (
      SELECT SUM(r.total_votes) 
      FROM movie m 
      INNER JOIN ratings r ON m.id = r.movie_id 
      WHERE m.country = "italy"
    ) THEN "GERMANY HAS HIGHEST TOTAL"
    ELSE "ITALY HAS HIGHEST TOTAL"
  END AS RESULT;
  
  
-- Identify the columns in the names table that contain null values.[16]

SELECT * FROM names WHERE id IS null OR name IS null OR height IS null OR date_of_birth IS null OR known_for_movies IS null;

SELECT 
CASE WHEN COUNT(*) - COUNT(id) > 0 THEN 'id has nulls' 
ELSE 'id has no nulls'
END AS id,
CASE WHEN COUNT(*) - COUNT(name) > 0 THEN 'name has nulls' 
ELSE 'name has no nulls' 
END AS name,
CASE WHEN COUNT(*) - COUNT(height) > 0 THEN 'height has nulls' 
ELSE 'height has no nulls' 
END AS height,
CASE WHEN COUNT(*) - COUNT(date_of_birth) > 0 THEN 'D_O_B has nulls' 
ELSE 'D_O_B has no nulls' 
END AS D_0_B,
CASE WHEN COUNT(*) - COUNT(known_for_movies) > 0 THEN 'K_F_M has nulls' 
ELSE 'K_F_M has no nulls' 
END AS K_F_M
FROM names;

-- Who are the top two actors whose movies have a median rating of 8 or higher?[17]

SELECT 
  n.name,rm.category,m.title,r.median_rating
FROM 
  ratings r 
  INNER JOIN movie m ON m.id = r.movie_id
  INNER JOIN role_mapping rm 
  ON m.id = rm.movie_id
  INNER JOIN names n ON rm.name_id = n.id
WHERE 
  r.median_rating >= 8 ORDER BY median_rating DESC LIMIT 5;
  
-- Which are the top three production companies based on the total number of votes their movies received?[18]

SELECT m.production_company,m.title,r.total_votes
FROM movie m INNER JOIN ratings r
ON m.id=r.movie_id ORDER BY total_votes DESC LIMIT 3;

-- How many directors have worked on more than three movies?[19]

SELECT d.name_id,COUNT(m.title)
FROM movie m INNER JOIN director_mapping d
ON m.id=d.movie_id GROUP BY d.name_id HAVING COUNT(m.title)>3 ORDER BY COUNT(m.title) DESC; --  [9]

-- Calculate the average height of actors and actresses separately.[20]

SELECT rm.category,AVG(n.height) AS average_height
FROM names n INNER JOIN role_mapping rm
ON n.id=rm.name_id GROUP BY category ORDER BY AVG(n.height) DESC;

-- List the 10 oldest movies in the dataset along with their title, country, and director.[21]

SELECT m.title,m.country,d.name_id AS director_id,m.year
FROM movie m INNER JOIN director_mapping d
ON m.id=d.movie_id ORDER BY year ASC LIMIT 10;

-- List the top 5 movies with the highest total votes, along with their genres.[22]

SELECT DENSE_RANK()OVER(ORDER BY total_votes DESC) AS ranking,m.title,g.genre,r.total_votes AS votes
FROM movie m INNER JOIN ratings r
ON m.id=r.movie_id INNER JOIN genre g 
ON m.id=g.movie_id ORDER BY total_votes DESC LIMIT 5;

-- Identify the movie with the longest duration, along with its genre and production company.[23]

SELECT m.title,m.duration,m.production_company,g.genre
FROM movie m INNER JOIN genre g 
ON m.id=g.movie_id ORDER BY duration DESC LIMIT 4;

-- Determine the total number of votes for each movie released in 2018.[24]

SELECT m.title,m.year,r.total_votes
FROM movie m INNER JOIN ratings r
ON m.id=r.movie_id WHERE year="2018" ORDER BY total_votes DESC;

-- What is the most common language in which movies were produced?[25]

SELECT DENSE_RANK()OVER (ORDER BY COUNT(title) DESC) AS rabking,COUNT(title) AS number_of_movies,languages FROM movie 
GROUP BY languages ORDER BY COUNT(TITLE) DESC LIMIT 5;


SELECT title,worlwide_gross_income FROM movie order by worlwide_gross_income desc limit 5;  


SELECT * FROM MOVIE;
SELECT * FROM NAMES;
SELECT * FROM ROLE_MAPPING;
SELECT NAME FROM NAMES WHERE NAME LIKE "JAMES G%";

SELECT M.TITLE,RO.CATEGORY,N.NAME FROM 
MOVIE M INNER JOIN  ROLE_MAPPING RO
ON M.ID=RO.MOVIE_ID INNER JOIN NAMES N ON N.ID=RO.NAME_iD WHERE N.NAME="BEN AFFLECK";















  


 






 
 




 