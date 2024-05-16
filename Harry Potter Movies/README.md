# Harry Potter Movies
### By Eray Balkaya
![135275](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/02f2fe8b-4198-41af-b67e-d1ddc9563094)

### This project is about a boy who lived ! ⚡

The Harry Potter franchise, created by British author J.K. Rowling, has captivated audiences worldwide since the release of the first novel, "Harry Potter and the Philosopher's Stone," in 1997 (titled "Harry Potter and the Sorcerer's Stone" in the United States). Set in a magical universe where wizards and witches coexist with ordinary humans, the series follows the young wizard Harry Potter and his friends Hermione Granger and Ron Weasley as they navigate the trials and tribulations of growing up while confronting the dark wizard Lord Voldemort. The immense success of the novels led to the creation of a blockbuster film series, produced by Warner Bros. Pictures, which brought Rowling's magical world to life on the big screen. Spanning eight films released between 2001 and 2011, the Harry Potter movies became a cultural phenomenon, beloved by fans of all ages for their compelling storytelling, memorable characters, and breathtaking visual effects.

You can find the database [HERE](https://www.mavenanalytics.io/data-playground?page=7&pageSize=5)

## Descriptions of Tables: 🦉

#### Movies Table :

Movie ID:Unique identifier for each movie
  
Movie Title:Full movie name

Release Year:Year the movie was released in theaters
 
Runtime:Length of the movie in minutes
 
Budget:Budget for the movie is US Dollars
 
Box Office:Box office revenue for the movie in US Dollars

#### Chapters Table :

Chapter ID:Unique identifier for each chapter
  
Chapter Name:Name of the chapter in the movie script
 
Movie ID:Foreign key to match with Movies table
 
Movie Chapter:Chapter number within each movie script

#### Characters Table :

Character ID:Unique identifier for each character
  
Character Name:Name of the character
 
Species:Species of the character
 
Gender:Gender of the character
 
House:Hogwarts house (or name of other magical school)
 
Patronus:Patronus of the character
 
Wand (Wood):Type of wood for the character's wand
 
Wand (Core):Core for the character's wand

#### Places Table :

Place ID:Unique identifier for each place
	
Place Name:Name of the place

Place Category:Type of place

#### Spells Table :

Spell ID:Unique identifier for each spell

Incantation:Words needed to conjure the spell	

Spell Name:Name of the spell

Effect:What the spell does

Light:Light the spell casts

#### Dialogue Table :
Dialogue ID:Unique identifier for each line of dialogue

Chapter ID:Foreign key to match with Chapters table

Place ID:Foreign key to match with Places table

Character ID:Foreign key to match with Characters table

Dialogue:Line of dialogue from the movie script

## Case Study Questions: 🏰

1)What is the total budget allocated for all the Harry Potter movies released after 2005?

2)Which movie has the longest runtime and profit of it?

3)List all the characters who belong to Gryffindor house and not totally human.

4)Which light has the most unique spells?

5)Which character has the 3rd highest number of dialogues in "Harry Potter and the Order of the Phoenix"?

6)What is the total profit generated all movies in the series?

7)List all the boys who have not been sorted into any house.

8)Which movie has the highest ratio of box office revenue to budget?

9)For each movie, list the top 3 characters who have the highest number of dialogues, along with the number of dialogues spoken by each character.

10)For each house, find the average runtime of the movies in which characters belonging to that house have appeared, along with the house name.

11)List all the movies along with the names of the characters who have dialogues spoken in places categorized as "School", sorted by movie title and character name.EXCEPT the 3 lead roles.

12)For each movie, find the total number of unique places where dialogues were spoken, along with the movie title.

13)List the top 3 characters who have spoken the most dialogues in the 'Harry Potter and the Goblet of Fire' movie, along with the number of dialogues spoken by each character.EXCEPT the 3 lead characters.

14)List the top 5 characters who have spoken the most dialogues across all Harry Potter movies, excluding the characters Harry Potter, Ron Weasley, and Hermione Granger. Include the total number of dialogues spoken by each character.

15)List all the movies along with the names of the top 3 characters who have spoken the most dialogues in each movie, excluding the characters Harry Potter, Ron Weasley, and Hermione Granger. Include the number of dialogues spoken by each character.

16)Show the amount of inhuman characters.

17)Which movie has the most non human characters ?

18)Which movie has the most unique places where dialogues were spoken?

19)What is the most popular location in each film?

### Let the magic begin 🧙‍♂️

#### 1) What is the total budget allocated for all the Harry Potter movies released after 2005?

```sql

SELECT SUM(BUDGET) AS TOTAL_BUDGET
FROM MOVIES
WHERE MOVIE_TITLE LIKE 'Harry Potter%'
	AND RELEASE_YEAR > 2005;
```
![1](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/30515877-4570-4c46-8568-00f31604aab2)

#### 2) Which movie has the longest runtime and profit of it?

```sql

SELECT MOVIE_TITLE,
	BOX_OFFICE - BUDGET AS REVENUE
FROM MOVIES
WHERE RUNTIME =
		(SELECT MAX(RUNTIME)
			FROM MOVIES);
   ```
![2](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/79f166a5-a11b-4e35-bd63-b939f0f50928)

#### 3) List all the characters who belong to Gryffindor house and not totally human.

```sql

SELECT CHARACTER_NAME,
	SPECIES
FROM CHARACTERS
WHERE HOUSE = 'Gryffindor'
	AND SPECIES NOT LIKE ('Human');
```
![3](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/430d7e75-6a29-4423-94ff-e10f549d9a15)

#### 4) Which light has the most unique spells?

```sql

SELECT LIGHT,
	COUNT(DISTINCT INCANTATION) AS MOST_LIGHTS
FROM SPELLS
WHERE LIGHT IS NOT NULL
GROUP BY LIGHT
ORDER BY MOST_LIGHTS DESC
LIMIT 1;
```
![4](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/5b61cf5f-25d3-47ed-897f-5c5fabbef7a3)

#### 5) Which character has the 3rd highest number of dialogues in "Harry Potter and the Order of the Phoenix"?

```sql

SELECT C.CHARACTER_NAME,
	COUNT(D.DIALOGUE_ID) AS NUM_DIALOGUES
FROM DIALOGUE D
JOIN CHARACTERS C ON D.CHARACTER_ID = C.CHARACTER_ID
JOIN CHAPTERS CH ON D.CHAPTER_ID = CH.CHAPTER_ID
JOIN MOVIES M ON CH.MOVIE_ID = M.MOVIE_ID
WHERE M.MOVIE_TITLE = 'Harry Potter and the Order of the Phoenix'
GROUP BY C.CHARACTER_NAME
ORDER BY NUM_DIALOGUES DESC
LIMIT 1
OFFSET 2;
```
![5](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/4d8b4348-6e6e-47ae-9298-78d8704a4f30)

#### 6) What is the total profit generated all movies in the series?

```sql

SELECT SUM(BOX_OFFICE - BUDGET) AS TOTAL_PROFIT,
	ROUND(SUM(BOX_OFFICE - BUDGET) * 100.0 / SUM(BOX_OFFICE),2) AS PERCENTAGE
FROM MOVIES;
```
![6](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/38bd93ed-a85b-4572-9080-ed68a5d6fd97)

#### 7) List all the boys who have not been sorted into any house.

```sql

SELECT CHARACTER_NAME
FROM CHARACTERS
WHERE HOUSE IS NULL
	AND GENDER = 'Male';
```
![7](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/5cb57605-85fc-4dfd-93a7-2bdeb82a5808)
                                                                                                         ![7 1](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/311302a9-f4e3-4647-825e-b484a2b653ee)

#### 8) Which movie has the highest ratio of box office revenue to budget?

```sql

SELECT MOVIE_TITLE,
	BOX_OFFICE - BUDGET AS PROFIT
FROM MOVIES
ORDER BY PROFIT DESC
LIMIT 1;
```
![8](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/2d5d144e-8389-4780-abbf-1a06b6d9ca47)

#### 9) For each movie, list the top 3 characters who have the highest number of dialogues, along with the number of dialogues spoken by each character.

```sql

SELECT MOVIE_TITLE,
	CHARACTER_NAME,
	NUM_DIALOGUES
FROM
	(SELECT M.MOVIE_TITLE,
			C.CHARACTER_NAME,
			COUNT(D.DIALOGUE_ID) AS NUM_DIALOGUES,
			ROW_NUMBER() OVER (PARTITION BY M.MOVIE_TITLE ORDER BY COUNT(D.DIALOGUE_ID) DESC) AS RN
		FROM MOVIES M
		JOIN CHAPTERS CH ON M.MOVIE_ID = CH.MOVIE_ID
		JOIN DIALOGUE D ON CH.CHAPTER_ID = D.CHAPTER_ID
		JOIN CHARACTERS C ON D.CHARACTER_ID = C.CHARACTER_ID
		GROUP BY M.MOVIE_TITLE,
			C.CHARACTER_NAME) AS RANKED
WHERE RN <= 3;
```
![9](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/d9e5fcae-6a65-428b-8dfd-eb21013a550a)

#### 10) For each house, find the average runtime of the movies in which characters belonging to that house have appeared, along with the house name.

```sql

SELECT C.HOUSE,
	ROUND(AVG(M.RUNTIME),2) AS AVERAGE_RUNTIME
FROM CHARACTERS C
JOIN DIALOGUE D ON C.CHARACTER_ID = D.CHARACTER_ID
JOIN CHAPTERS CH ON D.CHAPTER_ID = CH.CHAPTER_ID
JOIN MOVIES M ON CH.MOVIE_ID = M.MOVIE_ID
WHERE C.HOUSE IS NOT NULL
GROUP BY C.HOUSE
ORDER BY AVERAGE_RUNTIME DESC;
```
![10](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/f8d6c6ed-f3ce-4ac6-842b-59ae23c16982)

#### 11) List all the movies along with the names of the characters who have dialogues spoken in places categorized as "School", sorted by movie title and character name.EXCEPT the 3 lead roles.

```sql

SELECT DISTINCT M.MOVIE_TITLE,
	C.CHARACTER_NAME
FROM MOVIES M
JOIN CHAPTERS CH ON M.MOVIE_ID = CH.MOVIE_ID
JOIN DIALOGUE D ON CH.CHAPTER_ID = D.CHAPTER_ID
JOIN CHARACTERS C ON D.CHARACTER_ID = C.CHARACTER_ID
JOIN PLACES P ON D.PLACE_ID = P.PLACE_ID
WHERE P.PLACE_CATEGORY = 'Hogwarts'
	AND C.CHARACTER_NAME NOT IN ('Harry Potter','Ron Weasley','Hermione Granger')
ORDER BY M.MOVIE_TITLE,
	C.CHARACTER_NAME;
```
![11](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/b3ff9438-033d-420f-abee-00b3f33aa703)

#### 12) For each movie, find the total number of unique places where dialogues were spoken, along with the movie title.

```sql

SELECT M.MOVIE_TITLE,
	COUNT(DISTINCT P.PLACE_ID) AS UNIQUE_PLACES_COUNT
FROM MOVIES M
JOIN CHAPTERS CH ON M.MOVIE_ID = CH.MOVIE_ID
JOIN DIALOGUE D ON CH.CHAPTER_ID = D.CHAPTER_ID
JOIN PLACES P ON D.PLACE_ID = P.PLACE_ID
GROUP BY M.MOVIE_TITLE;
```
![12](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/c6653943-1b37-46b0-a850-f281545dfc89)

#### 13) List the top 3 characters who have spoken the most dialogues in the 'Harry Potter and the Goblet of Fire' movie,along with the number of dialogues spoken by each character.EXCEPT the 3 lead characters.

```sql

WITH GOBLET_OF_FIRE_DIALOGUES AS
	(SELECT C.CHARACTER_NAME,
			COUNT(*) AS NUM_DIALOGUES
		FROM DIALOGUE D
		JOIN CHAPTERS CH ON D.CHAPTER_ID = CH.CHAPTER_ID
		JOIN CHARACTERS C ON D.CHARACTER_ID = C.CHARACTER_ID
		JOIN MOVIES M ON CH.MOVIE_ID = M.MOVIE_ID
		WHERE M.MOVIE_TITLE = 'Harry Potter and the Goblet of Fire'
			AND C.CHARACTER_NAME NOT IN ('Harry Potter','Ron Weasley','Hermione Granger')
		GROUP BY C.CHARACTER_NAME)
SELECT CHARACTER_NAME,
	NUM_DIALOGUES
FROM GOBLET_OF_FIRE_DIALOGUES
ORDER BY NUM_DIALOGUES DESC
LIMIT 3;
```
![13](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/017bc4b5-e969-4374-b6f9-eee3b13672da)

#### 14) List the top 5 characters who have spoken the most dialogues across all Harry Potter movies, excluding the characters Harry Potter, Ron Weasley, and Hermione Granger. Include the total number of dialogues spoken by each character.

```sql

WITH CHARACTER_DIALOGUES AS
	(SELECT C.CHARACTER_NAME,
			COUNT(*) AS NUM_DIALOGUES
		FROM DIALOGUE D
		JOIN CHARACTERS C ON D.CHARACTER_ID = C.CHARACTER_ID
		WHERE C.CHARACTER_NAME NOT IN ('Harry Potter','Ron Weasley','Hermione Granger')
		GROUP BY C.CHARACTER_NAME)
SELECT CHARACTER_NAME,
	NUM_DIALOGUES
FROM CHARACTER_DIALOGUES
ORDER BY NUM_DIALOGUES DESC
LIMIT 5;
```
![14](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/f85bef6c-50da-4625-b369-fc9c0c1f3862)

#### 15) List all the movies along with the names of the top 3 characters who have spoken the most dialogues in each movie, excluding the characters Harry Potter, Ron Weasley, and Hermione Granger. Include the number of dialogues spoken by each character.

```sql

WITH MOVIE_CHARACTERS_DIALOGUES AS
	(SELECT M.MOVIE_ID,
			M.MOVIE_TITLE,
			C.CHARACTER_NAME,
			COUNT(*) AS NUM_DIALOGUES
		FROM DIALOGUE D
		JOIN CHAPTERS CH ON D.CHAPTER_ID = CH.CHAPTER_ID
		JOIN CHARACTERS C ON D.CHARACTER_ID = C.CHARACTER_ID
		JOIN MOVIES M ON CH.MOVIE_ID = M.MOVIE_ID
		WHERE C.CHARACTER_NAME NOT IN ('Harry Potter','Ron Weasley','Hermione Granger')
		GROUP BY M.MOVIE_ID,
			M.MOVIE_TITLE,
			C.CHARACTER_NAME),
	RANKED_DIALOGUES AS
	(SELECT MOVIE_ID,
			MOVIE_TITLE,
			CHARACTER_NAME,
			NUM_DIALOGUES,
			ROW_NUMBER() OVER (PARTITION BY MOVIE_ID ORDER BY NUM_DIALOGUES DESC) AS RN
		FROM MOVIE_CHARACTERS_DIALOGUES)
SELECT MOVIE_TITLE,
	CHARACTER_NAME,
	NUM_DIALOGUES
FROM RANKED_DIALOGUES
WHERE RN <= 3
ORDER BY MOVIE_ID, RN;
```
![15](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/0fc8e050-f640-4cb2-9888-f977db61fe03)

#### 16) Show the amount of inhuman characters.

```sql

SELECT SPECIES,
	COUNT(CHARACTER_NAME)
FROM CHARACTERS
WHERE SPECIES IS NOT NULL
	AND SPECIES != 'Human'
GROUP BY SPECIES
ORDER BY COUNT DESC
```
![16](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/4ae3ac4c-3566-4851-b261-e33234dca38e)

#### 17) Which movie has the most non human characters ?

```sql

WITH NON_HUMAN_CHARACTERS_PER_MOVIE AS
	(SELECT M.MOVIE_TITLE,
			COUNT(DISTINCT C.CHARACTER_ID) AS NUM_NON_HUMAN_CHARACTERS
		FROM MOVIES M
		JOIN CHAPTERS CH ON M.MOVIE_ID = CH.MOVIE_ID
		JOIN DIALOGUE D ON CH.CHAPTER_ID = D.CHAPTER_ID
		JOIN CHARACTERS C ON D.CHARACTER_ID = C.CHARACTER_ID
		WHERE C.SPECIES != 'Human'
		GROUP BY M.MOVIE_TITLE)
SELECT MOVIE_TITLE,
	NUM_NON_HUMAN_CHARACTERS
FROM NON_HUMAN_CHARACTERS_PER_MOVIE
ORDER BY NUM_NON_HUMAN_CHARACTERS DESC
LIMIT 1;
```
![17](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/cb88eeed-1660-4ae5-bb1f-d56a4de92528)

#### 18) Which movie has the most unique places where dialogues were spoken?

```sql

WITH UNIQUE_PLACES_PER_MOVIE AS
	(SELECT M.MOVIE_TITLE,
			COUNT(DISTINCT P.PLACE_ID) AS NUM_UNIQUE_PLACES
		FROM MOVIES M
		JOIN CHAPTERS CH ON M.MOVIE_ID = CH.MOVIE_ID
		JOIN DIALOGUE D ON CH.CHAPTER_ID = D.CHAPTER_ID
		JOIN PLACES P ON D.PLACE_ID = P.PLACE_ID
		GROUP BY M.MOVIE_TITLE)
SELECT MOVIE_TITLE,
	NUM_UNIQUE_PLACES
FROM UNIQUE_PLACES_PER_MOVIE
ORDER BY NUM_UNIQUE_PLACES DESC
LIMIT 1;
```
![18](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/c9b51dd8-9ffd-4907-8b0e-8aa555cf3f72)

#### 19) What is the most popular location in each film?

```sql

WITH DIALOGUE_COUNTS_PER_MOVIE AS
	(SELECT M.MOVIE_TITLE,
			P.PLACE_NAME,
			COUNT(*) AS DIALOGUE_COUNT
		FROM MOVIES M
		JOIN CHAPTERS CH ON M.MOVIE_ID = CH.MOVIE_ID
		JOIN DIALOGUE D ON CH.CHAPTER_ID = D.CHAPTER_ID
		JOIN PLACES P ON D.PLACE_ID = P.PLACE_ID
		GROUP BY M.MOVIE_TITLE,
			P.PLACE_NAME),
	MAX_DIALOGUE_COUNT_PER_MOVIE AS
	(SELECT MOVIE_TITLE,
			MAX(DIALOGUE_COUNT) AS MAX_DIALOGUE_COUNT
		FROM DIALOGUE_COUNTS_PER_MOVIE
		GROUP BY MOVIE_TITLE)
SELECT D.MOVIE_TITLE,
	D.PLACE_NAME,
	D.DIALOGUE_COUNT
FROM DIALOGUE_COUNTS_PER_MOVIE D
JOIN MAX_DIALOGUE_COUNT_PER_MOVIE M ON D.MOVIE_TITLE = M.MOVIE_TITLE
AND D.DIALOGUE_COUNT = M.MAX_DIALOGUE_COUNT
ORDER BY D.MOVIE_TITLE;
```
![19](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/d084e263-1312-4a8c-9f00-ed65d303bc38)




 




