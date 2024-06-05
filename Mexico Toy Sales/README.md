# Mexico Toy Sales
### By Eray Balkaya
![toy store 4b35042a-af06-4f53-b8f0-ebce7eb18eed](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/435aeebc-36f6-4703-bb01-b56fce3cfb32)

Toy sales have experienced a significant boost this season, driven by a combination of innovative product launches, strategic marketing campaigns, and the rising demand for educational and interactive toys. Parents 
are increasingly seeking toys that not only entertain but also promote learning and development, contributing to higher sales in categories like STEM toys and creative playsets. Additionally, the growing popularity 
of licensed merchandise from blockbuster movies and TV shows has fueled consumer interest and spending. Retailers are capitalizing on these trends by offering exclusive deals and expanding their online presence,
making it easier for customers to find and purchase the latest must-have toys.

This data analysis project is about the toy sales in Mexico.You can find the database [HERE](https://www.mavenanalytics.io/data-playground?page=8&pageSize=5)

## Descriptions of Tables: 

#### Products Table :                                                        

Product_ID : Product ID

Product_Name :	Product name

Product_Category :	Product Category

Product_Cost :	Product cost ($USD)

Product_Price :	Product retail price ($USD)

#### Inventory Table :

Store_ID : Store ID

Product_ID :	Product ID

Stock_On_Hand :	Stock quantity of the product in the store (inventory)

#### Stores Table :

Store_ID :	Store ID

Store_Name :	Store name

Store_City :	City in Mexico where the store is located

Store_Location :	Location in the city where the store is located

Store_Open_Date	: Date when the store was opened

#### Sales Table :

Sale_ID :	Sale ID

Date	: Date of the transaction

Store_ID :	Store ID

Product_ID :	Product ID

Units :	Units sold

#### Calendar Table :

Date :	Calendar date

## Create Tables :

#### Create Sales table

```sql

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    date DATE,
    store_id INTEGER,
    product_id INTEGER,
    units INTEGER
);
```
#### Create Products table

```sql

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    product_cost NUMERIC(12, 2),
    product_price NUMERIC(12, 2)
);
```
#### Create Stores table

```sql

CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100),
    store_city VARCHAR(50),
    store_location VARCHAR(100),
    store_open_date DATE
);
```

#### Create Inventory table

```sql

CREATE TABLE inventory (
    store_id INTEGER,
    product_id INTEGER,
    stock_on_hand INTEGER,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

#### Create Calendar table

```sql

CREATE TABLE calendar (
    date DATE PRIMARY KEY
);
```

## Case Study Questions: 

1)What is the total sales revenue for each product category in each city?

2)Which store has the highest profit in a day?

3)What is the total stock on hand for each product category across all stores?

4)What are the product categories that make the most profit in total for each city?

5)For each store, what is the total revenue generated in the first quarter of the year (January to March)?

6)What is the top selling product of each store  ?

7)For each product category, what is the total stock on hand across all AND what percentage of the total stock are these?

8)What are the top 10 products have been sold most?

9)Find the most profitable product for each store.

10)How much is the average profit margin of each store since their opening ?

11)Show stores with the highest profit margins of each month.

12)Which city or cities have the most stores ?

13)Which categories have the most revenue?
	
14)Which is the most profitable month ?

15)What is the difference of product cost and price between highest product price and lowest product price?

16)Which month has the most sales?

## Solutions :

#### 1)What is the total sales revenue for each product category in each city?
```sql
SELECT ST.STORE_CITY,
	P.PRODUCT_CATEGORY,
	SUM(S.UNITS * P.PRODUCT_PRICE) AS TOTAL_REVENUE
FROM SALES S
INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
INNER JOIN STORES ST ON S.STORE_ID = ST.STORE_ID
GROUP BY ST.STORE_CITY,P.PRODUCT_CATEGORY;
```
![1](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/9b24a8a2-347c-44f3-9c64-0342647dbbd4)

#### 2)Which store has the highest profit in a day?
```sql
SELECT S.STORE_ID,
	ST.STORE_NAME,
	DATE_TRUNC('day',S.DATE) AS DAY,
	SUM(S.UNITS * (P.PRODUCT_PRICE - P.PRODUCT_COST)) AS DAILY_PROFIT
FROM SALES S
INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
INNER JOIN STORES ST ON S.STORE_ID = ST.STORE_ID
GROUP BY S.STORE_ID,
	ST.STORE_NAME,
	DATE_TRUNC('day',S.DATE)
ORDER BY DAILY_PROFIT DESC
LIMIT 1
```
![2](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/29303473-a888-45b2-a02d-a235c77a9789)

#### 3)What is the total stock on hand for each product category across all stores?
```sql
SELECT P.PRODUCT_CATEGORY,
	SUM(I.STOCK_ON_HAND) AS TOTAL_STOCK
FROM INVENTORY I
INNER JOIN PRODUCTS P ON I.PRODUCT_ID = P.PRODUCT_ID
GROUP BY P.PRODUCT_CATEGORY
ORDER BY TOTAL_STOCK DESC;
```
![3](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/9be1fbb1-aabb-4ce9-9dba-38a55492d890)

#### 4) What are the product categories that make the most profit in total for each city?
```sql
WITH PRODUCTPROFITS AS
	(SELECT ST.STORE_CITY,
			P.PRODUCT_ID,
			P.PRODUCT_CATEGORY,
			SUM(S.UNITS * (P.PRODUCT_PRICE - P.PRODUCT_COST)) AS TOTAL_PROFIT
		FROM SALES S
		INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
		INNER JOIN STORES ST ON S.STORE_ID = ST.STORE_ID
		GROUP BY ST.STORE_CITY,
			P.PRODUCT_ID,
			P.PRODUCT_CATEGORY),
	MAXPRODUCTPROFIT AS
	(SELECT STORE_CITY,
			MAX(TOTAL_PROFIT) AS MAX_PROFIT
		FROM PRODUCTPROFITS
		GROUP BY STORE_CITY)
SELECT PP.STORE_CITY,
	PP.PRODUCT_CATEGORY,
	PP.TOTAL_PROFIT
FROM PRODUCTPROFITS PP
INNER JOIN MAXPRODUCTPROFIT MPP ON PP.STORE_CITY = MPP.STORE_CITY
AND PP.TOTAL_PROFIT = MPP.MAX_PROFIT
ORDER BY PP.STORE_CITY;
```
![4](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/ba5e336f-ae8d-43df-9793-ae5454fc13db)

#### 5)For each store, what is the total revenue generated in the first quarter of the year (January to March)?
```sql
SELECT ST.STORE_NAME,
	SUM(S.UNITS * P.PRODUCT_PRICE) AS TOTAL_REVENUE_1ST_QUARTER
FROM SALES S
INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
INNER JOIN STORES ST ON S.STORE_ID = ST.STORE_ID
WHERE EXTRACT(MONTH	FROM S.DATE) BETWEEN 1 AND 3
GROUP BY ST.STORE_NAME;
```
![5](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/6c69897d-3518-41e9-8b4a-066afdeff8ce)

#### 6) What is the top selling product of each store  ?
```sql
WITH TOPSELLINGPRODUCTS AS
	(SELECT S.STORE_ID,
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			SUM(S.UNITS) AS TOTAL_SALES,
			ROW_NUMBER() OVER (PARTITION BY S.STORE_ID ORDER BY SUM(S.UNITS) DESC) AS RN
		FROM SALES S
		INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY S.STORE_ID,
			P.PRODUCT_ID,
			P.PRODUCT_NAME)
SELECT ST.STORE_NAME,
	TSP.PRODUCT_NAME,
	TSP.TOTAL_SALES
FROM TOPSELLINGPRODUCTS TSP
INNER JOIN STORES ST ON TSP.STORE_ID = ST.STORE_ID
WHERE TSP.RN = 1
ORDER BY TOTAL_SALES DESC;
```
![6](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/dc552506-da17-427c-af96-b1c4d8727f90)

#### 7)For each product category, what is the total stock on hand across all AND what percentage of the total stock are these?
```sql
WITH TOTALSTOCKPERCATEGORY AS
	(SELECT P.PRODUCT_CATEGORY,
			SUM(I.STOCK_ON_HAND) AS TOTAL_STOCK_PER_CATEGORY
		FROM INVENTORY I
		INNER JOIN PRODUCTS P ON I.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY P.PRODUCT_CATEGORY)
SELECT T.PRODUCT_CATEGORY,
	T.TOTAL_STOCK_PER_CATEGORY AS TOTAL_STOCK,
	(T.TOTAL_STOCK_PER_CATEGORY * 100) / TOTAL_STOCK.TOTAL_STOCK AS PERCENTAGE_OF_TOTAL_STOCK
FROM TOTALSTOCKPERCATEGORY T,

	(SELECT SUM(STOCK_ON_HAND) AS TOTAL_STOCK
		FROM INVENTORY) AS TOTAL_STOCK;
```
![7](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/808b2c53-b233-4562-b023-fb6fabf4e6bf)

#### 8)What are the top 10 products have been sold most?
```sql
SELECT P.PRODUCT_NAME,
	   COUNT(*) AS TOTAL_SALE
FROM SALES S
JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
GROUP BY P.PRODUCT_NAME
ORDER BY TOTAL_SALE DESC
LIMIT 10;
```
![8](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/d98c5e6b-99c9-4923-9790-62a11272b9b9)

#### 9) Find the most profitable product for each store.
```sql
WITH PRODUCTPROFITS AS
	(SELECT S.STORE_ID,
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			SUM(S.UNITS * (P.PRODUCT_PRICE - P.PRODUCT_COST)) AS TOTAL_PROFIT,
			ROW_NUMBER() OVER (PARTITION BY S.STORE_ID ORDER BY SUM(S.UNITS * (P.PRODUCT_PRICE - P.PRODUCT_COST)) DESC) AS RN
		FROM SALES S
		INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY S.STORE_ID,
			P.PRODUCT_ID,
			P.PRODUCT_NAME)
SELECT ST.STORE_NAME,
	PP.PRODUCT_NAME,
	PP.TOTAL_PROFIT
FROM PRODUCTPROFITS PP
INNER JOIN STORES ST ON PP.STORE_ID = ST.STORE_ID
WHERE PP.RN = 1;
```
![9](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/5f641f54-dc5d-45b8-92c6-1b631a6da96d)

#### 10) How much is the average profit margin of each store since their opening ?
```sql
WITH STORESALES AS
	(SELECT S.STORE_ID,
			ST.STORE_NAME,
			SUM(S.UNITS * (P.PRODUCT_PRICE - P.PRODUCT_COST)) AS TOTAL_PROFIT,
			SUM(S.UNITS * P.PRODUCT_PRICE) AS TOTAL_REVENUE
		FROM SALES S
		INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
		INNER JOIN STORES ST ON S.STORE_ID = ST.STORE_ID
		GROUP BY S.STORE_ID,
			ST.STORE_NAME),
	STOREPROFITMARGINS AS
	(SELECT STORE_ID,
			STORE_NAME,
			TOTAL_PROFIT,
			TOTAL_REVENUE,
			CASE WHEN TOTAL_REVENUE = 0 THEN 0
				ELSE ROUND((TOTAL_PROFIT / TOTAL_REVENUE) * 100,2)
			END AS PROFIT_MARGIN
		FROM STORESALES)
SELECT STORE_NAME,
	PROFIT_MARGIN
FROM STOREPROFITMARGINS
ORDER BY PROFIT_MARGIN DESC;
```
![10](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/a2970164-dc9a-415d-9b48-e408885e17ca)

#### 11) Show stores with the highest profit margins of each month.
```sql
WITH MONTHLYSTORESALES AS
	(SELECT S.STORE_ID,
			ST.STORE_NAME,
			TO_CHAR(DATE_TRUNC('month',	S.DATE),'YYYY-MM') AS MONTH,
			SUM(S.UNITS * (P.PRODUCT_PRICE - P.PRODUCT_COST)) AS MONTHLY_PROFIT,
			SUM(S.UNITS * P.PRODUCT_PRICE) AS MONTHLY_REVENUE
		FROM SALES S
		INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
		INNER JOIN STORES ST ON S.STORE_ID = ST.STORE_ID
		GROUP BY S.STORE_ID,ST.STORE_NAME,TO_CHAR(DATE_TRUNC('month',S.DATE),'YYYY-MM')),
	MONTHLYPROFITMARGINS AS
	(SELECT STORE_ID,
			STORE_NAME,
			MONTH,
			CASE WHEN MONTHLY_REVENUE = 0 THEN 0
				ELSE ROUND((MONTHLY_PROFIT / MONTHLY_REVENUE) * 100,2)
			END AS MONTHLY_PROFIT_MARGIN,
			ROW_NUMBER() OVER (PARTITION BY MONTH ORDER BY (MONTHLY_PROFIT / MONTHLY_REVENUE) DESC) AS RANK
		FROM MONTHLYSTORESALES)
SELECT STORE_NAME,
	MONTH,
	MONTHLY_PROFIT_MARGIN
FROM MONTHLYPROFITMARGINS
WHERE RANK = 1
ORDER BY MONTH;
```
![11](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/bdc138c4-147c-4d4b-8fbe-19f9d618c0c3)

#### 12) Which city or cities have the most stores ?
```sql
WITH STORECOUNTS AS
	(SELECT STORE_CITY,
			COUNT(*) AS STORE_COUNT
		FROM STORES
		GROUP BY STORE_CITY),
	MAXSTORECOUNT AS
	(SELECT MAX(STORE_COUNT) AS MAX_COUNT
		FROM STORECOUNTS)
SELECT STORE_CITY,
	STORE_COUNT
FROM STORECOUNTS
WHERE STORE_COUNT =
		(SELECT MAX_COUNT
			FROM MAXSTORECOUNT)
ORDER BY STORE_CITY;
```

![12](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/e6488b2b-e3dc-4b19-984d-24147cfa3c30)

⭐ if we simple do a 'count' and 'limit 1' query it would have choose one of city instead of the other cities which may have the same amount

#### 13) Which categories have the most revenue?
```sql	
SELECT P.PRODUCT_CATEGORY,
	   SUM(S.UNITS * P.PRODUCT_PRICE) AS TOTAL_REVENUE
FROM SALES S
INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
GROUP BY P.PRODUCT_CATEGORY
ORDER BY TOTAL_REVENUE DESC;
```
![13](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/83a2b369-a26f-4057-99c9-c39d10c1355e)

#### 14) Which is the most profitable month ?
```sql
SELECT DATE_TRUNC('month',S.DATE) AS MONTH,
	SUM(S.UNITS * (P.PRODUCT_PRICE - P.PRODUCT_COST)) AS TOTAL_PROFIT
FROM SALES S
INNER JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
GROUP BY DATE_TRUNC('month',S.DATE)
ORDER BY TOTAL_PROFIT DESC
LIMIT 1;
```
![14](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/b2ca51a5-3cf9-4505-bf8b-5898047d8cae)

#### 15) What is the difference of product cost and price between highest product price and lowest product price?
```sql
SELECT
	(SELECT MAX(PRODUCT_PRICE) FROM PRODUCTS)-(SELECT MIN(PRODUCT_PRICE) FROM PRODUCTS) AS PRICE_DIFFERENCE,
	(SELECT PRODUCT_COST FROM PRODUCTS WHERE PRODUCT_PRICE =
  (SELECT MAX(PRODUCT_PRICE)FROM PRODUCTS)) -	(SELECT PRODUCT_COST FROM PRODUCTS WHERE PRODUCT_PRICE =
  (SELECT MIN(PRODUCT_PRICE)FROM PRODUCTS)) AS COST_DIFFERENCE;
```
![15](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/fea52b00-43f3-4347-ba81-e58dc8390e27)

#### 16) Which month has the most sales?
```sql
SELECT DATE_TRUNC('month', date) AS MONTH,
	COUNT(*) AS SALES_COUNT
FROM SALES
GROUP BY DATE_TRUNC('month', date)
ORDER BY SALES_COUNT DESC
LIMIT 1;
```
![16](https://github.com/ErayBalkaya/Sql_Projects/assets/159141102/39728d43-f39d-4292-87f7-be5806eac875)







