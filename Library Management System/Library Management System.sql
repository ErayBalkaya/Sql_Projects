--1. How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"? 
SELECT BC.NO_OF_COPIES
FROM BOOK B
JOIN BOOK_COPIES BC ON B.BOOK_ID = BC.BOOK_ID
JOIN LIBRARY_BRANCH LB ON BC.BRANCH_ID = LB.BRANCH_ID
WHERE TITLE = 'The Lost Tribe'
	AND BRANCH_NAME = 'Sharpstown'

--2. How many copies of the book titled "The Lost Tribe" are owned by each library branch?
SELECT B.TITLE,
	BC.NO_OF_COPIES,
	LB.BRANCH_NAME
FROM BOOK B
JOIN BOOK_COPIES BC ON B.BOOK_ID = BC.BOOK_ID
JOIN LIBRARY_BRANCH LB ON BC.BRANCH_ID = LB.BRANCH_ID
WHERE TITLE = 'The Lost Tribe'

--3. For each book that is loaned out from the "Sharpstown" branch and whose DueDate is before 2018-03-01 , retrieve the book title, the borrower's name, and the borrower's address.
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

--4. For each library branch, retrieve the branch name and the total number of books loaned out from that branch

SELECT LB.BRANCH_NAME,
	COUNT(BL.BOOK_ID) TOTAL_LOANS
FROM BOOK_LOANS BL
JOIN LIBRARY_BRANCH LB ON BL.BRANCH_ID = LB.BRANCH_ID
GROUP BY 1
ORDER BY 2 DESC

--5. Retrieve the names, addresses, and number of books checked out for all borrowers who have more than 6 books checked out.
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

--6. For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
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

--7.Which three books have been borrowed the most across all branches?

SELECT B.TITLE,
	COUNT(BL.BOOK_ID) AS TOTAL_BORROWED
FROM BOOK_LOANS BL
JOIN BOOK B ON BL.BOOK_ID = B.BOOK_ID
GROUP BY B.TITLE
ORDER BY TOTAL_BORROWED DESC
LIMIT 3;

--8.Which branch has the highest and lowest average number of books borrowed per borrower?

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

--9.What is the distribution of books among different publishers? Which publisher has the highest number of books loaned?

SELECT PUBLISHERNAME,
	COUNT(*) AS TOTAL_BOOKS
FROM BOOK
GROUP BY PUBLISHERNAME
ORDER BY TOTAL_BOOKS DESC;

--10.What is the average number of books borrowed per borrower across all branches?

SELECT ROUND(AVG(TOTAL_BOOKS_BORROWED),2) AS AVG_BOOKS_BORROWED_PER_BORROWER
FROM
	(SELECT CARD_NO,
			COUNT(*) AS TOTAL_BOOKS_BORROWED
		FROM BOOK_LOANS
		GROUP BY CARD_NO) AS SUBQUERY;

--11.What is the distribution of book copies across different branches?

SELECT BRANCH_ID,
	SUM(NO_OF_COPIES) AS TOTAL_COPIES
FROM BOOK_COPIES
GROUP BY BRANCH_ID;

--12.Which borrower has borrowed the most number of books?

SELECT BOR.NAME AS BORROWER_NAME,
	COUNT(BL.BOOK_ID) AS TOTAL_BOOKS_BORROWED
FROM BOOK_LOANS BL
JOIN BORROWER BOR ON BL.CARD_NO = BOR.CARD_NO
GROUP BY BOR.NAME
ORDER BY TOTAL_BOOKS_BORROWED DESC
LIMIT 1;


--13.Among the top five publishers with the most books loaned, which one has the highest average number of copies per book across all branches?

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

--14.Which branch has the highest average number of books borrowed per borrower?

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

--15.What is the total number of books borrowed from each publisher?

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
