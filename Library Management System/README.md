# Library Management System
### By Eray Balkaya
![library2](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/fc59a08d-8425-4e31-8a4f-b63e72b6b126)


Library management systems are essential components that form the foundation of modern libraries, enabling the effective management of library resources. These systems automate processes such as recording, 
cataloging, lending, and returning books, reducing the workload of library staff while facilitating user access to books. SQL (Structured Query Language) is a powerful tool used in database management for library 
management systems. This study will focus on an Entity-Relationship Diagram (EDA) analysis of the database design and implementation of a library management system. The aim of this study is to enhance the efficiency 
of library services and improve the user experience.

## Entity Relationship Diagram:

![Untitled (1)](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/9c001dd1-1742-4e1d-bc4e-d964c3cbd829)

## Descriptions of Tables:

### book : 
The table has three columns: "book_id" column is id for books, "title" as names of the books, and "publishername" as company names of the publishers.
### book_authors :
The table has three columns: "author_id" column is id for authors,"book_id" and "author_name".
### book_copies :
The table has four columns: "copies_id" column is id for copies,"book_id" , "branch_id" as id for each brand and "no_of_copies" as the amount of the copies.
### book_loans :
The table has six columns: "loans_id" column is id for loans,"book_id" , "branch_id" ,"card_no" as the card number of the member,"date_out" and "due_date".
### borrower :
The table has four columns: "card_no","name" as the name of the borrower , "address" is the address of the borrower and "phone" is for the phone number of the borrower.
### library_branch :
The table has three columns: "branch_id" column is id for branches,"branch_name" shows the names of the branches,"branch_address" shows the addresses of the branches.
### publisher :
The table has three columns: "name" column is names of the publishers,"address" as the locations of publishers , "phone" column is for the phone numbers of publishers.

## Case Study Questions:

1)How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"? 

2)How many copies of the book titled "The Lost Tribe" are owned by each library branch?

3)For each book that is loaned out from the "Sharpstown" branch and whose DueDate is before 2018-03-01 , retrieve the book title, the borrower's name, and the borrower's address.

4)For each library branch, retrieve the branch name and the total number of books loaned out from that branch

5)Retrieve the names, addresses, and number of books checked out for all borrowers who have more than 6 books checked out.

6)For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

7)Which three books have been borrowed the most across all branches?

8)Which branch has the highest and lowest average number of books borrowed per borrower?

9)What is the distribution of books among different publishers? Which publisher has the highest number of books loaned?

10)What is the average number of books borrowed per borrower across all branches?

11)What is the distribution of book copies across different branches?

12)Which borrower has borrowed the most number of books?

13)Among the top five publishers with the most books loaned, which one has the highest average number of copies per book across all branches?

14)Which branch has the highest average number of books borrowed per borrower?

15)What is the total number of books borrowed from each publisher?

#### It is time to see my answers for these questions 🚀

#### 1) How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"? 

```sql

SELECT BC.NO_OF_COPIES
FROM BOOK B
JOIN BOOK_COPIES BC ON B.BOOK_ID = BC.BOOK_ID
JOIN LIBRARY_BRANCH LB ON BC.BRANCH_ID = LB.BRANCH_ID
WHERE TITLE = 'The Lost Tribe'
	AND BRANCH_NAME = 'Sharpstown'

```

![1](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/dc5705a7-5ca5-4ea6-9b6e-a3a631d6d58e)

#### 2) How many copies of the book titled "The Lost Tribe" are owned by each library branch?

```sql

SELECT B.TITLE,
	BC.NO_OF_COPIES,
	LB.BRANCH_NAME
FROM BOOK B
JOIN BOOK_COPIES BC ON B.BOOK_ID = BC.BOOK_ID
JOIN LIBRARY_BRANCH LB ON BC.BRANCH_ID = LB.BRANCH_ID
WHERE TITLE = 'The Lost Tribe'

```
![2](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/deabb5b0-32fc-401d-b032-29fabc72317a)

#### 3) For each book that is loaned out from the "Sharpstown" branch and whose DueDate is before 2018-03-01 , retrieve the book title, the borrower's name, and the borrower's address.

```sql

SELECT LB.BRANCH_NAME,
	B.TITLE,
	BO.NAME,
	BO.ADDRESS
FROM BOOK_LOANS BL
JOIN LIBRARY_BRANCH LB ON BL.BRANCH_ID = LB.BRANCH_ID
JOIN BOOK B ON B.BOOK_ID = BL.BOOK_ID
JOIN BORROWER BO ON BO.CARD_NO = BL.CARD_NO
WHERE BRANCH_NAME = 'Sharpstown'
	AND BL.DUE_DATE < '2018-03-01'

```
![3](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/cb44d80d-3e17-4f9b-af12-31d786db686d)

#### 4) For each library branch, retrieve the branch name and the total number of books loaned out from that branch

```sql

SELECT LB.BRANCH_NAME,
	COUNT(BL.BOOK_ID) TOTAL_LOANS
FROM BOOK_LOANS BL
JOIN LIBRARY_BRANCH LB ON BL.BRANCH_ID = LB.BRANCH_ID
GROUP BY 1
ORDER BY 2 DESC

```
![4](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/b1a90335-d142-4d52-af04-15439096c4b5)

#### 5) Retrieve the names, addresses, and number of books checked out for all borrowers who have more than 6 books checked out.

```sql

SELECT BO.NAME,
	BO.ADDRESS,
	BO.PHONE,
	BL.CARD_NO,
	COUNT(BL.CARD_NO) TOTAL_BOOKS
FROM BOOK_LOANS BL
JOIN BORROWER BO ON BL.CARD_NO = BO.CARD_NO
GROUP BY 4,1,
	2,3
HAVING COUNT(BL.CARD_NO) > 6

```
![5](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/17ef2f50-d464-4482-b07f-4645ac7a01a2)

#### 6) For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

```sql

SELECT BA.AUTHOR_NAME,
	B.TITLE,
	BC.NO_OF_COPIES,
	LB.BRANCH_NAME
FROM BOOK_AUTHORS BA
JOIN BOOK B ON BA.BOOK_ID = B.BOOK_ID
JOIN BOOK_COPIES BC ON B.BOOK_ID = BC.BOOK_ID
JOIN LIBRARY_BRANCH LB ON BC.BRANCH_ID = LB.BRANCH_ID
WHERE AUTHOR_NAME = 'Stephen King'
	AND BRANCH_NAME = 'Central'

```
![6](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/f2a59aa1-f737-4814-9651-7749af2ae772)

#### 7) Which three books have been borrowed the most across all branches?

```sql

SELECT B.TITLE,
	COUNT(BL.BOOK_ID) AS TOTAL_BORROWED
FROM BOOK_LOANS BL
JOIN BOOK B ON BL.BOOK_ID = B.BOOK_ID
GROUP BY B.TITLE
ORDER BY TOTAL_BORROWED DESC
LIMIT 3;

```
![7](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/652a94f4-dc4d-4ca2-8381-ca4d55019411)

#### 8) Which branch has the highest and lowest average number of books borrowed per borrower?

```sql

SELECT BRANCH_ID,
	ROUND(AVG(TOTAL_BOOKS_BORROWED),
		2) AS AVG_BOOKS_BORROWED_PER_BORROWER
FROM
	(SELECT BRANCH_ID,
			CARD_NO,
			COUNT(*) AS TOTAL_BOOKS_BORROWED
		FROM BOOK_LOANS
		GROUP BY BRANCH_ID,
			CARD_NO) AS SUBQUERY
GROUP BY BRANCH_ID
ORDER BY AVG_BOOKS_BORROWED_PER_BORROWER DESC,
	BRANCH_ID;

```
![8](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/686a1a59-0508-4a29-90d0-1b215f684c45)

#### 9) What is the distribution of books among different publishers? Which publisher has the highest number of books loaned?

```sql

SELECT PUBLISHERNAME,
	COUNT(*) AS TOTAL_BOOKS
FROM BOOK
GROUP BY PUBLISHERNAME
ORDER BY TOTAL_BOOKS DESC;

```
![9](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/4bd58786-a18e-4185-b093-14252c0dfa9b)

#### 10) What is the average number of books borrowed per borrower across all branches?

```sql

SELECT ROUND(AVG(TOTAL_BOOKS_BORROWED),2) AS AVG_BOOKS_BORROWED_PER_BORROWER
FROM
	(SELECT CARD_NO,
			COUNT(*) AS TOTAL_BOOKS_BORROWED
		FROM BOOK_LOANS
		GROUP BY CARD_NO) AS SUBQUERY;

```
![10](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/a5894cfe-0e57-490e-942c-41fb3a3d3b1a)

#### 11) What is the distribution of book copies across different branches?

```sql

SELECT BRANCH_ID,
	SUM(NO_OF_COPIES) AS TOTAL_COPIES
FROM BOOK_COPIES
GROUP BY BRANCH_ID;

```
![11](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/e4e317f6-52d3-48dd-bdfc-8753c7201bcd)

#### 12) Which borrower has borrowed the most number of books?

```sql

SELECT BOR.NAME AS BORROWER_NAME,
	COUNT(BL.BOOK_ID) AS TOTAL_BOOKS_BORROWED
FROM BOOK_LOANS BL
JOIN BORROWER BOR ON BL.CARD_NO = BOR.CARD_NO
GROUP BY BOR.NAME
ORDER BY TOTAL_BOOKS_BORROWED DESC
LIMIT 1;

```
![12](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/670b1b47-d302-4d80-9c85-bb7814b8b857)

#### 13) Among the top five publishers with the most books loaned, which one has the highest average number of copies per book across all branches?

```sql

SELECT P.NAME AS PUBLISHER_NAME,
	ROUND(AVG(BC.NO_OF_COPIES),2) AS AVG_COPIES_PER_BOOK
FROM PUBLISHER P
JOIN BOOK B ON P.NAME = B.PUBLISHERNAME
JOIN BOOK_COPIES BC ON B.BOOK_ID = BC.BOOK_ID
WHERE P.NAME IN
		(SELECT P2.NAME
			FROM PUBLISHER P2
			JOIN BOOK B2 ON P2.NAME = B2.PUBLISHERNAME
			GROUP BY P2.NAME
			ORDER BY COUNT(*) DESC
			LIMIT 5)
GROUP BY P.NAME
ORDER BY AVG_COPIES_PER_BOOK DESC;

```
![13](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/2fe96b29-3633-4a8f-9111-4a05b58e76a7)

#### 14) Which branch has the highest average number of books borrowed per borrower?

```sql

WITH BORROWERBOOKS AS
	(SELECT LB.BRANCH_NAME,
			BL.CARD_NO,
			COUNT(*) AS TOTAL_BOOKS_BORROWED
		FROM BOOK_LOANS BL
		JOIN LIBRARY_BRANCH LB ON BL.BRANCH_ID = LB.BRANCH_ID
		GROUP BY LB.BRANCH_NAME,
			BL.CARD_NO)
SELECT BRANCH_NAME,
	ROUND(AVG(TOTAL_BOOKS_BORROWED),
		2) AS AVG_BOOKS_BORROWED_PER_BORROWER
FROM BORROWERBOOKS
GROUP BY BRANCH_NAME
ORDER BY AVG_BOOKS_BORROWED_PER_BORROWER DESC
LIMIT 1;

```
![14](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/fcb064eb-ea43-4bd9-81d4-7ad42652b420)

#### 15) What is the total number of books borrowed from each publisher?

```sql

WITH BOOKSPERPUBLISHER AS
	(SELECT B.PUBLISHERNAME,
			COUNT(BL.BOOK_ID) AS TOTAL_BOOKS_BORROWED
		FROM BOOK_LOANS BL
		JOIN BOOK B ON BL.BOOK_ID = B.BOOK_ID
		GROUP BY B.PUBLISHERNAME)
SELECT PUBLISHERNAME,
	TOTAL_BOOKS_BORROWED
FROM BOOKSPERPUBLISHER
ORDER BY TOTAL_BOOKS_BORROWED DESC;

```
![15](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/557ecd89-d6a2-4969-a234-5b855e89bbd2)
