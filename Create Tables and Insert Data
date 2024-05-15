CREATE TABLE publisher (
    name VARCHAR(100) PRIMARY KEY NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(50) NOT NULL
);

CREATE TABLE book (
    book_id SERIAL4 PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    publishername VARCHAR(100) NOT NULL,
    CONSTRAINT fk_publisher_name1 FOREIGN KEY (publishername) REFERENCES publisher(name) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE library_branch (
    branch_id SERIAL4 PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    branch_address VARCHAR(200) NOT NULL
);

CREATE TABLE borrower (
    card_no SERIAL4 PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(50) NOT NULL
);

CREATE TABLE book_loans (
    loans_id SERIAL4 PRIMARY KEY,
    book_id INT NOT NULL,
    branch_id INT NOT NULL,
    card_no INT NOT NULL,
    date_out DATE NOT NULL,
    due_date DATE NOT NULL,
    CONSTRAINT fk_book_id1 FOREIGN KEY (book_id) REFERENCES book(book_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_branch_id1 FOREIGN KEY (branch_id) REFERENCES library_branch(branch_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_cardno FOREIGN KEY (card_no) REFERENCES borrower(card_no) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE book_copies (
    copies_id SERIAL4 PRIMARY KEY,
    book_id INT NOT NULL,
    branch_id INT NOT NULL,
    no_of_copies INT NOT NULL,
    CONSTRAINT fk_book_id2 FOREIGN KEY (book_id) REFERENCES book(book_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_branch_id2 FOREIGN KEY (branch_id) REFERENCES library_branch(branch_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE book_authors (
    author_id SERIAL4 PRIMARY KEY,
    book_id INT NOT NULL,
    author_name VARCHAR(50) NOT NULL,
    CONSTRAINT fk_book_id3 FOREIGN KEY (book_id) REFERENCES book(book_id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO publisher
    (name, address, phone)
    VALUES
    ('DAW Books','375 Hudson Street, New York, NY 10014','212-366-2000'),
    ('Viking','375 Hudson Street, New York, NY 10014','212-366-2000'),
    ('Signet Books','375 Hudson Street, New York, NY 10014','212-366-2000'),
    ('Chilton Books','Not Available','Not Available'),
    ('George Allen & Unwin','83 Alexander Ln, Crows Nest NSW 2065, Australia','+61-2-8425-0100'),
    ('Alfred A. Knopf','The Knopf Doubleday Group Domestic Rights, 1745 Broadway, New York, NY 10019','212-940-7390'),      
    ('Bloomsbury','Bloomsbury Publishing Inc., 1385 Broadway, 5th Floor, New York, NY 10018','212-419-5300'),
    ('Shinchosa','Oga Bldg. 8, 2-5-4 Sarugaku-cho, Chiyoda-ku, Tokyo 101-0064 Japan','+81-3-5577-6507'),
    ('Harper and Row','HarperCollins Publishers, 195 Broadway, New York, NY 10007','212-207-7000'),
    ('Pan Books','175 Fifth Avenue, New York, NY 10010','646-307-5745'),
    ('Chalto & Windus','375 Hudson Street, New York, NY 10014','212-366-2000'),
    ('Harcourt Brace Jovanovich','3 Park Ave, New York, NY 10016','212-420-5800'),
    ('W.W. Norton',' W. W. Norton & Company, Inc., 500 Fifth Avenue, New York, New York 10110','212-354-5500'),
    ('Scholastic','557 Broadway, New York, NY 10012','800-724-6527'),
    ('Bantam','375 Hudson Street, New York, NY 10014','212-366-2000'),
    ('Picador USA','175 Fifth Avenue, New York, NY 10010','646-307-5745')      
;

SELECT * FROM publisher;

INSERT INTO book
    (title, publishername)
    VALUES 
    ('The Name of the Wind', 'DAW Books'),
    ('It', 'Viking'),
    ('The Green Mile', 'Signet Books'),
    ('Dune', 'Chilton Books'),
    ('The Hobbit', 'George Allen & Unwin'),
    ('Eragon', 'Alfred A. Knopf'),
    ('A Wise Mans Fear', 'DAW Books'),
    ('Harry Potter and the Philosophers Stone', 'Bloomsbury'),
    ('Hard Boiled Wonderland and The End of the World', 'Shinchosa'),
    ('The Giving Tree', 'Harper and Row'),
    ('The Hitchhikers Guide to the Galaxy', 'Pan Books'),
    ('Brave New World', 'Chalto & Windus'),
    ('The Princess Bride', 'Harcourt Brace Jovanovich'),
    ('Fight Club', 'W.W. Norton'),
    ('Holes', 'Scholastic'),
    ('Harry Potter and the Chamber of Secrets', 'Bloomsbury'),
    ('Harry Potter and the Prisoner of Azkaban', 'Bloomsbury'),
    ('The Fellowship of the Ring', 'George Allen & Unwin'),
    ('A Game of Thrones', 'Bantam'),
    ('The Lost Tribe', 'Picador USA');

SELECT * FROM book;

INSERT INTO library_branch
    (branch_name, branch_address)
    VALUES
    ('Sharpstown','32 Corner Road, New York, NY 10012'),
    ('Central','491 3rd Street, New York, NY 10014'),
    ('Saline','40 State Street, Saline, MI 48176'),
    ('Ann Arbor','101 South University, Ann Arbor, MI 48104');

SELECT * FROM library_branch;

INSERT INTO borrower
    (name, address, phone)
    VALUES
    ('Joe Smith','1321 4th Street, New York, NY 10014','212-312-1234'),
    ('Jane Smith','1321 4th Street, New York, NY 10014','212-931-4124'),
    ('Tom Li','981 Main Street, Ann Arbor, MI 48104','734-902-7455'),
    ('Angela Thompson','2212 Green Avenue, Ann Arbor, MI 48104','313-591-2122'),
    ('Harry Emnace','121 Park Drive, Ann Arbor, MI 48104','412-512-5522'),
    ('Tom Haverford','23 75th Street, New York, NY 10014','212-631-3418'),
    ('Haley Jackson','231 52nd Avenue New York, NY 10014','212-419-9935'),
    ('Michael Horford','653 Glen Avenue, Ann Arbor, MI 48104','734-998-1513');

SELECT * FROM borrower;

INSERT INTO book_loans
    		(book_id, branch_id, card_no, date_out, due_date)
		VALUES
    ('1', '1', '1', '2018-01-01', '2018-02-02'),
    ('2', '1', '2', '2018-01-01', '2018-02-02'),
    ('3', '1', '3', '2018-01-01', '2018-02-02'),
    ('4', '1', '4', '2018-01-01', '2018-02-02'),
    ('5', '1', '5', '2018-01-03', '2018-02-03'),
    ('6', '1', '6', '2018-01-03', '2018-02-03'),
    ('7', '1', '7', '2018-01-03', '2018-02-03'),
    ('8', '1', '8', '2018-01-03', '2018-02-03'),
    ('9', '1', '1', '2018-01-03', '2018-02-03'),
    ('11', '1', '2', '2018-01-03', '2018-02-03'),
    ('12', '2', '3', '2017-12-12', '2018-01-12'),
    ('10', '2', '4', '2017-12-12', '2017-01-12'),
    ('20', '2', '5', '2018-02-03', '2018-03-03'),
    ('18', '2', '6', '2018-01-05', '2018-02-05'),
    ('19', '2', '7', '2018-01-05', '2018-02-05'),
    ('19', '2', '8', '2018-01-03', '2018-02-03'),
    ('11', '2', '1', '2018-01-07', '2018-02-07'),
    ('1', '2', '2', '2018-01-07', '2018-02-07'),
    ('2', '2', '3', '2018-01-07', '2018-02-07'),
    ('3', '2', '4', '2018-01-07', '2018-02-07'),
    ('5', '2', '5', '2017-12-12', '2018-01-12'),
    ('4', '3', '6', '2018-01-09', '2018-02-09'),
    ('7', '3', '7', '2018-01-03', '2018-02-03'),
    ('17', '3', '8', '2018-01-03', '2018-02-03'),
    ('16', '3', '1', '2018-01-03', '2018-02-03'),
    ('15', '3', '2', '2018-01-03', '2018-02-03'),
    ('15', '3', '3', '2018-01-03', '2018-02-03'),
    ('14', '3', '4', '2018-01-03', '2018-02-03'),
    ('13', '3', '5', '2018-01-03', '2018-02-03'),
    ('13', '3', '6', '2018-01-03', '2018-02-03'),
    ('19', '3', '7', '2017-12-12', '2018-01-12'),
    ('20', '4', '8', '2018-01-03', '2018-02-03'),
    ('1', '4', '1', '2018-01-12', '2018-02-12'),
    ('3', '4', '2', '2018-01-03', '2018-02-03'),
    ('18', '4', '3', '2018-01-03', '2018-02-03'),
    ('12', '4', '4', '2018-01-04', '2018-02-04'),
    ('11', '4', '5', '2018-01-15', '2018-02-15'),
    ('9', '4', '6', '2018-01-15', '2018-02-15'),
    ('7', '4', '7', '2018-01-01', '2018-02-02'),
    ('4', '4', '8', '2018-01-01', '2018-02-02'),
    ('1', '4', '1', '2017-02-02', '2018-02-03'),
    ('20', '4', '2', '2018-01-03', '2018-02-03'),
    ('1', '4', '3', '2018-01-12', '2018-02-12'),
    ('3', '4', '4', '2018-01-13', '2018-02-13'),
    ('18', '4', '5', '2018-01-13', '2018-02-13'),
    ('12', '4', '6', '2018-01-14', '2018-02-14'),
    ('11', '4', '7', '2018-01-15', '2018-02-15'),
    ('9', '4', '8', '2018-01-15', '2018-02-15'),
    ('7', '4', '1', '2018-01-19', '2018-02-19'),
    ('4', '4', '2', '2018-01-19', '2018-02-19'),
    ('1', '4', '3', '2018-01-22', '2018-02-22');

	
		
	SELECT * FROM book_loans;

	INSERT INTO book_copies
		(book_id, branch_id, no_of_copies)
		VALUES
		('1','1','5'),
		('2','1','5'),
		('3','1','5'),
		('4','1','5'),
		('5','1','5'),
		('6','1','5'),
		('7','1','5'),
		('8','1','5'),
		('9','1','5'),
		('10','1','5'),
		('11','1','5'),
		('12','1','5'),
		('13','1','5'),
		('14','1','5'),
		('15','1','5'),
		('16','1','5'),
		('17','1','5'),
		('18','1','5'),
		('19','1','5'),
		('20','1','5'),
		('1','2','5'),
		('2','2','5'),
		('3','2','5'),
		('4','2','5'),
		('5','2','5'),
		('6','2','5'),
		('7','2','5'),
		('8','2','5'),
		('9','2','5'),
		('10','2','5'),
		('11','2','5'),
		('12','2','5'),
		('13','2','5'),
		('14','2','5'),
		('15','2','5'),
		('16','2','5'),
		('17','2','5'),
		('18','2','5'),
		('19','2','5'),
		('20','2','5'),
		('1','3','5'),
		('2','3','5'),
		('3','3','5'),
		('4','3','5'),
		('5','3','5'),
		('6','3','5'),
		('7','3','5'),
		('8','3','5'),
		('9','3','5'),
		('10','3','5'),
		('11','3','5'),
		('12','3','5'),
		('13','3','5'),
		('14','3','5'),
		('15','3','5'),
		('16','3','5'),
		('17','3','5'),
		('18','3','5'),
		('19','3','5'),
		('20','3','5'),
		('1','4','5'),
		('2','4','5'),
		('3','4','5'),
		('4','4','5'),
		('5','4','5'),
		('6','4','5'),
		('7','4','5'),
		('8','4','5'),
		('9','4','5'),
		('10','4','5'),
		('11','4','5'),
		('12','4','5'),
		('13','4','5'),
		('14','4','5'),
		('15','4','5'),
		('16','4','5'),
		('17','4','5'),
		('18','4','5'),
		('19','4','5'),
		('20','4','5');

	SELECT * FROM book_copies;
 

	INSERT INTO book_authors
		(book_id,author_name)
		VALUES
		('1','Patrick Rothfuss'),
		('2','Stephen King'),
		('3','Stephen King'),
		('4','Frank Herbert'),
		('5','J.R.R. Tolkien'),
		('6','Christopher Paolini'),
		('6','Patrick Rothfuss'),
		('8','J.K. Rowling'),
		('9','Haruki Murakami'),
		('10','Shel Silverstein'),
		('11','Douglas Adams'),
		('12','Aldous Huxley'),
		('13','William Goldman'),
		('14','Chuck Palahniuk'),
		('15','Louis Sachar'),
		('16','J.K. Rowling'),
		('17','J.K. Rowling'),
		('18','J.R.R. Tolkien'),
		('19','George R.R. Martin'),
		('20','Mark Lee');
