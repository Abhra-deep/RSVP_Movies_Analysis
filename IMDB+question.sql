USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT *
FROM   (SELECT Count(*) AS count_of_director_mapping
        FROM   director_mapping) AS count_of_director_mapping,
       (SELECT Count(*) AS count_of_genre
        FROM   genre) AS count_of_genre,
       (SELECT Count(*) AS count_of_movie
        FROM   movie) AS count_of_movie,
       (SELECT Count(*) AS count_of_names
        FROM   names) AS count_of_names,
       (SELECT Count(*) AS count_of_ratings
        FROM   ratings) AS count_of_ratings,
       (SELECT Count(*) AS count_of_role_mapping
        FROM   role_mapping) AS count_of_role_mapping; 
/*
# count_of_director_mapping	count_of_genre	count_of_movie	count_of_names	count_of_ratings	count_of_role_mapping
3867	14662	7997	25735	7997	15615
*/


-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT
    SUM(id IS NULL) AS id_null,
    SUM(title IS NULL) AS title_null,
    SUM(year IS NULL) AS movie_null,
    SUM(date_published IS NULL) AS date_published_null,
    SUM(country IS NULL) AS country_null,
    SUM(worlwide_gross_income IS NULL) AS worlwide_gross_income_null,
    SUM(languages IS NULL) AS languages_null,
    SUM(production_company IS NULL) AS production_company_null
FROM movie;

/* Below columns with null data
country=20
worlwide_gross_income=3724
language_null = 194
production company = 528
*/

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT year, COUNT(id) AS number_of_movies
FROM movie
GROUP BY year;

SELECT
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);

/*
# month_num	number_of_movies
1	804
2	640
3	824
4	680
5	625
6	580
7	493
8	678
9	809
10	801
11	625
12	438
*/

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT COUNT(id) AS US_IN_MOVIES_2019
FROM movie
WHERE (country LIKE '%USA%' OR country LIKE '%India%')
AND year = '2019';-- 1059


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT DISTINCT genre
FROM genre 
ORDER BY genre;
/*
# genre
Action
Adventure
Comedy
Crime
Drama
Family
Fantasy
Horror
Mystery
Others
Romance
Sci-Fi
Thriller
*/
/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
SELECT gen.genre, COUNT(gen.movie_id) AS Movie_count
FROM genre gen
INNER JOIN movie mov ON gen.movie_id = mov.id
GROUP BY gen.genre
ORDER BY COUNT(gen.movie_id) DESC
LIMIT 1;
/*
# genre	Movie_count
Drama	4285
*/

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
SELECT COUNT(*) AS single_genre_count
FROM (
    SELECT movie_id
    FROM genre
    GROUP BY movie_id
    HAVING COUNT(DISTINCT genre) = 1
) AS single_genre;
/*
# single_genre_count
3289
*/

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT
    gen.genre,
    ROUND(SUM(mov.duration) / COUNT(gen.movie_id), 2) AS avg_duration
FROM genre gen
INNER JOIN movie mov ON gen.movie_id = mov.id
GROUP BY gen.genre
ORDER BY gen.genre;
/*
# genre	avg_duration
Action	112.88
Adventure	101.87
Comedy	102.62
Crime	107.05
Drama	106.77
Family	100.97
Fantasy	105.14
Horror	92.72
Mystery	101.80
Others	100.16
Romance	109.53
Sci-Fi	97.94
Thriller	101.58
*/

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)



/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT *
FROM (
    SELECT
        genre,
        COUNT(movie_id) AS movie_cnt,
        RANK() OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
    FROM genre
    GROUP BY genre
) AS ranked_genre_data
WHERE genre = 'Thriller';

/*
# genre	movie_cnt	genre_rank
Thriller	1484	3
*/


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT Floor(Max(avg_rating))    AS min_avg_rating,
       Floor(Min(avg_rating))    AS max_avg_rating,
       Floor(Max(total_votes))   AS min_total_votes,
       Floor(Min(total_votes))   AS max_total_votes,
       Floor(Max(median_rating)) AS min_median_rating,
       Floor(Min(median_rating)) AS min_median_rating
FROM   ratings;   

/*
# min_avg_rating	max_avg_rating	min_total_votes	max_total_votes	min_median_rating	min_median_rating
10	1	725138	100	10	1
*/ 

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
SELECT     mov.title,
           rat.avg_rating,
           Rank() OVER (ORDER BY rat.avg_rating DESC) AS movie_rank
FROM       movie mov
INNER JOIN ratings rat
ON         rat.movie_id = mov.id limit 10;

/*
# title	avg_rating	movie_rank
Kirket	10.0	1
Love in Kilnerry	10.0	1
Gini Helida Kathe	9.8	3
Runam	9.7	4
Fan	9.6	5
Android Kunjappan Version 5.25	9.6	5
Yeh Suhaagraat Impossible	9.5	7
Safe	9.5	7
The Brighton Miracle	9.5	7
Shibu	9.4	10
*/

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
SELECT rat.median_rating,
       Count(rat.movie_id) AS movie_count
FROM   ratings rat
GROUP  BY rat.median_rating
ORDER  BY rat.median_rating;
/*
# median_rating	movie_count
1	94
2	119
3	283
4	479
5	985
6	1975
7	2257
8	1030
9	429
10	346
*/

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT *
FROM (
    SELECT mov.production_company,
           COUNT(mov.id) AS movie_count,
           RANK() OVER (ORDER BY COUNT(mov.id) DESC) AS movie_rank
    FROM movie mov
    INNER JOIN ratings rat
        ON rat.movie_id = mov.id
        AND rat.avg_rating > '8'
        AND mov.production_company IS NOT NULL
    GROUP BY mov.production_company
) AS prod_rating_rank
WHERE movie_rank = 1;
/*
# production_company	movie_count	movie_rank
Dream Warrior Pictures	3	1
National Theatre Live	3	1
*/

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT gen.genre,
       Count(mov.id) AS movie_count
FROM   movie mov
       INNER JOIN ratings rat
               ON rat.movie_id = mov.id
       INNER JOIN genre gen
               ON gen.movie_id = mov.id
WHERE  mov.date_published BETWEEN '2017-03-01' AND '2017-03-31'
       AND mov.country LIKE '%USA%'
       AND rat.total_votes > 1000
GROUP  BY gen.genre
ORDER  BY gen.genre DESC;



-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT mov.title,
       rat.avg_rating,
       gen.genre
FROM   movie mov
       INNER JOIN ratings rat
               ON rat.movie_id = mov.id
       INNER JOIN genre gen
               ON gen.movie_id = mov.id
WHERE  mov.title LIKE 'The%'
       AND rat.avg_rating > '8'; 

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT Count(mov.id) as movie_count
FROM   movie mov
       INNER JOIN ratings rat
               ON rat.movie_id = mov.id
WHERE  rat.median_rating = '8'
       AND mov.date_published BETWEEN '2018-04-01' AND '2019-04-01';
       
/*
# movie_count
361
*/

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
select * from (select "german" as language, sum(total_votes) as total_german_votes  FROM   movie mov
       INNER JOIN ratings rat
               ON rat.movie_id = mov.id
               WHERE  mov.languages like '%German%') as a,
 (select "Italian" as language, sum(total_votes)  as total_italian_votes    FROM   movie mov
       INNER JOIN ratings rat
               ON rat.movie_id = mov.id
               WHERE  mov.languages like '%Italian%') as b;
-- Yes, German(4421525) has more votes than Italian(2559540)

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT
    SUM(name IS NULL) AS name_nulls,
    SUM(height IS NULL) AS height_nulls,
    SUM(date_of_birth IS NULL) AS date_of_birth_nulls,
    SUM(known_for_movies IS NULL) AS known_for_movies_nulls
FROM names;
/*
# name_nulls	height_nulls	date_of_birth_nulls	known_for_movies_nulls
0	17335	13431	15226
*/

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT nam.name      AS director_name,
       Count(mov.id) AS movie_count
FROM   movie mov
       INNER JOIN director_mapping dir
               ON mov.id = dir.movie_id
       INNER JOIN names nam
               ON nam.id = dir.name_id
       INNER JOIN genre gen
               ON gen.movie_id = mov.id
       INNER JOIN ratings rat
               ON mov.id = rat.movie_id
WHERE  gen.genre IN (SELECT *
                     FROM   (SELECT gen.genre
                             FROM   movie mov
                                    INNER JOIN genre gen
                                            ON mov.id = gen.movie_id
                                    INNER JOIN ratings rat
                                            ON rat.movie_id = mov.id
                             WHERE  rat.avg_rating > 8
                             GROUP  BY gen.genre
                             ORDER  BY Count(mov.id) DESC
                             LIMIT  3) AS sub)
       AND rat.avg_rating > 8
GROUP  BY nam.name
ORDER  BY Count(mov.id) DESC
LIMIT  3; 
/*
# director_name	movie_count
James Mangold	4
Joe Russo	3
Anthony Russo	3
*/
/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT nam.name      AS actor_name,
       Count(mov.id) AS movie_count
FROM   movie mov
       INNER JOIN ratings rat
               ON mov.id = rat.movie_id
       INNER JOIN role_mapping rol
               ON mov.id = rol.movie_id
       INNER JOIN names nam
               ON nam.id = rol.name_id
WHERE  rat.median_rating >= 8
GROUP  BY nam.name
ORDER  BY Count(mov.id) DESC
LIMIT  2; 
/*
# actor_name	movie_count
Mammootty	8
Mohanlal	5
*/
/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     mov.production_company,
           Sum(rat.total_votes)                             AS vote_count,
           Rank() OVER (ORDER BY Sum(rat.total_votes) DESC) AS prod_comp_rank
FROM       movie mov
INNER JOIN ratings rat
ON         mov.id = rat.movie_id
GROUP BY   mov.production_company limit 3;
/*
# production_company	vote_count	prod_comp_rank
Marvel Studios	2656967	1
Twentieth Century Fox	2411163	2
Warner Bros.	2396057	3
*/

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT nam.NAME                                                               AS
       actor_name,
       Sum(rat.total_votes)                                                   AS
       total_votes,
       Count(mov.id)                                                          AS
       movie_count,
       Round(Sum(rat.avg_rating * rat.total_votes) / Sum(rat.total_votes), 2) AS
       actor_avg_rating,
       Rank()
         OVER (
           ORDER BY Round(Sum(rat.avg_rating * rat.total_votes) /
         Sum(rat.total_votes),
         2) DESC)                                                             AS
       actor_rank
FROM   names nam
       INNER JOIN role_mapping rol
               ON nam.id = rol.name_id
       INNER JOIN ratings rat
               ON rol.movie_id = rat.movie_id
       INNER JOIN movie mov
               ON mov.id = rol.movie_id
WHERE  rol.category = 'actor'
       AND mov.country LIKE '%India%'
GROUP  BY nam.NAME
HAVING Count(mov.id) >= 5
LIMIT 1; 
/*
# actor_name	total_votes	movie_count	actor_avg_rating	actor_rank
Vijay Sethupathi	23114	5	8.42	1
*/

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT nam.NAME                                                               AS
       actress_name,
       Sum(rat.total_votes)                                                   AS
       total_votes,
       Count(mov.id)                                                          AS
       movie_count,
       Round(Sum(rat.avg_rating * rat.total_votes) / Sum(rat.total_votes), 2) AS
       actress_avg_rating,
       Rank()
         OVER (
           ORDER BY Round(Sum(rat.avg_rating * rat.total_votes) /
         Sum(rat.total_votes),
         2) DESC)                                                             AS
       actress_rank
FROM   names nam
       INNER JOIN role_mapping rol
               ON nam.id = rol.name_id
       INNER JOIN ratings rat
               ON rol.movie_id = rat.movie_id
       INNER JOIN movie mov
               ON mov.id = rol.movie_id
WHERE  rol.category = 'actress'
       AND mov.languages LIKE '%Hindi%'
       AND mov.country LIKE '%India%'
GROUP  BY nam.NAME
HAVING Count(mov.id) >= 3
LIMIT 5; 
/*
# actor_name	total_votes	movie_count	actor_avg_rating	actor_rank
Taapsee Pannu	18061	3	7.74	1
Kriti Sanon	21967	3	7.05	2
Divya Dutta	8579	3	6.88	3
Shraddha Kapoor	26779	3	6.63	4
Kriti Kharbanda	2549	3	4.80	5
*/
/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT mov.title, rat.avg_rating,
       CASE
         WHEN rat.avg_rating > '8' THEN 'Superhit movies'
         WHEN rat.avg_rating BETWEEN'7' AND '8' THEN 'Hit movies'
         WHEN rat.avg_rating BETWEEN'5' AND '7' THEN 'One-time-watch movies'
         WHEN rat.avg_rating < '5' THEN 'Flop movies'
       END AS category
FROM   movie mov
       INNER JOIN genre gen
               ON mov.id = gen.movie_id
       INNER JOIN ratings rat
               ON rat.movie_id = mov.id
WHERE  gen.genre = 'Thriller'
ORDER  BY rat.avg_rating DESC;

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT gen.genre,
       Round(SUM(mov.duration) / Count(gen.movie_id), 2)      AS avg_duration,
       SUM(Round(SUM(mov.duration) / Count(gen.movie_id), 2))
         over (
           ORDER BY gen.genre)                                AS
       running_total_duration,
       Round(Avg(Round(SUM(mov.duration) / Count(gen.movie_id), 2))
               over (
                 ORDER BY gen.genre ROWS unbounded preceding), 2) AS
       moving_avg_duration
FROM   movie mov
       inner join genre gen
               ON mov.id = gen.movie_id
GROUP  BY gen.genre
ORDER  BY gen.genre;
/*
# genre	avg_duration	running_total_duration	moving_avg_duration
Action	112.88	112.88	112.88
Adventure	101.87	214.75	107.38
Comedy	102.62	317.37	105.79
Crime	107.05	424.42	106.11
Drama	106.77	531.19	106.24
Family	100.97	632.16	105.36
Fantasy	105.14	737.30	105.33
Horror	92.72	830.02	103.75
Mystery	101.80	931.82	103.54
Others	100.16	1031.98	103.20
Romance	109.53	1141.51	103.77
Sci-Fi	97.94	1239.45	103.29
Thriller	101.58	1341.03	103.16
*/

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies


SELECT *
FROM   (
                  SELECT     gen.genre,
                             mov.year,
                             mov.title,
                             Cast(Replace(Ifnull(worlwide_gross_income,0),'$','') AS DECIMAL(10))                                                   AS worlwide_gross_income,
                             Rank() OVER( partition BY mov.year ORDER BY Cast(Replace(Ifnull(worlwide_gross_income,0),'$','') AS DECIMAL(10)) DESC) AS movie_rank
                  FROM       movie mov
                  INNER JOIN genre gen
                  ON         mov.id = gen.movie_id
                  WHERE      mov.worlwide_gross_income LIKE '$%'
                  AND        gen.genre IN
                             (
                                    SELECT *
                                    FROM   (
                                                      SELECT     gen.genre
                                                      FROM       movie mov
                                                      INNER JOIN genre gen
                                                      ON         mov.id = gen.movie_id
                                                      INNER JOIN ratings rat
                                                      ON         rat.movie_id = mov.id
                                                      GROUP BY   gen.genre
                                                      ORDER BY   Count(mov.id) DESC limit 3) AS sub)) AS final_list
WHERE  movie_rank <='5';

/*
Thriller	2017	The Fate of the Furious	1236005118	1
Comedy	2017	Despicable Me 3	1034799409	2
Comedy	2017	Jumanji: Welcome to the Jungle	962102237	3
Drama	2017	Zhan lang II	870325439	4
Thriller	2017	Zhan lang II	870325439	4
Drama	2018	Bohemian Rhapsody	903655259	1
Thriller	2018	Venom	856085151	2
Thriller	2018	Mission: Impossible - Fallout	791115104	3
Comedy	2018	Deadpool 2	785046920	4
Comedy	2018	Ant-Man and the Wasp	622674139	5
Drama	2019	Avengers: Endgame	2797800564	1
Drama	2019	The Lion King	1655156910	2
Comedy	2019	Toy Story 4	1073168585	3
Drama	2019	Joker	995064593	4
Thriller	2019	Joker	995064593	4
*/

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     mov.production_company,
           Count(mov.id)                            AS movie_count,
           Rank() OVER(ORDER BY Count(mov.id) DESC) AS prod_comp_rank
FROM       movie                                    AS mov
INNER JOIN ratings                                  AS rat
ON         mov.id=rat.movie_id
WHERE      rat.median_rating>='8'
AND        mov.languages LIKE '%,%'
AND        mov.production_company IS NOT NULL
GROUP BY   mov.production_company
ORDER BY   Count(mov.id) DESC limit 2;
/*
# production_company	movie_count	prod_comp_rank
Star Cinema	7	1
Twentieth Century Fox	4	2
*/

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT     nam.NAME                                                               AS actress_name,
           Sum(rat.total_votes)                                                   AS total_votes,
           Count(mov.id)                                                          AS movie_count,
           Round(Sum(rat.avg_rating * rat.total_votes) / Sum(rat.total_votes), 2) AS actress_avg_rating,
           Rank() OVER ( ORDER BY Count(mov.id) DESC)                             AS actress_rank
FROM       names nam
INNER JOIN role_mapping rol
ON         nam.id = rol.name_id
INNER JOIN ratings rat
ON         rol.movie_id = rat.movie_id
INNER JOIN movie mov
ON         mov.id = rol.movie_id
INNER JOIN genre gen
ON         mov.id = gen.movie_id
WHERE      rol.category = 'actress'
AND        gen.genre='Drama'
AND        rat.avg_rating>='8'
GROUP BY   nam.NAME limit 3;

/*
# actress_name	total_votes	movie_count	actress_avg_rating	actress_rank
Parvathy Thiruvothu	4974	2	8.25	1
Susan Brown	656	2	8.94	1
Amanda Lawrence	656	2	8.94	1
*/

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)      AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     (
                SELECT *,
                       Datediff(next_date, date_published) AS date_difference
                FROM   (
                                  SELECT     dir.name_id,
                                             nam.NAME,
                                             dir.movie_id,
                                             mov.duration,
                                             rat.avg_rating,
                                             rat.total_votes,
                                             mov.date_published,
                                             Lead(date_published,1) OVER(partition BY dir.name_id ORDER BY mov.date_published, dir.movie_id ) AS next_date
                                  FROM       director_mapping                                                                                 AS dir
                                  INNER JOIN names                                                                                            AS nam
                                  ON         nam.id = dir.name_id
                                  INNER JOIN movie AS mov
                                  ON         mov.id = dir.movie_id
                                  INNER JOIN ratings AS rat
                                  ON         rat.movie_id = mov.id) AS subqry1 ) AS subqry2
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;
/*
# director_id	director_name	number_of_movies	avg_inter_movie_days	avg_rating	total_votes	min_rating	max_rating	total_duration
nm2096009	Andrew Jones	5	190.75	3.02	1989	2.7	3.2	432
nm1777967	A.L. Vijay	5	176.75	5.42	1754	3.7	6.9	613
nm0814469	Sion Sono	4	331.00	6.03	2972	5.4	6.4	502
nm0831321	Chris Stokes	4	198.33	4.33	3664	4.0	4.6	352
nm0515005	Sam Liu	4	260.33	6.23	28557	5.8	6.7	312
nm0001752	Steven Soderbergh	4	254.33	6.48	171684	6.2	7.0	401
nm0425364	Jesse V. Johnson	4	299.00	5.45	14778	4.2	6.5	383
nm2691863	Justin Price	4	315.00	4.50	5343	3.0	5.8	346
nm6356309	Özgür Bakar	4	112.00	3.75	1092	3.1	4.9	374
*/