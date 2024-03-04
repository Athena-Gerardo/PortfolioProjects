/*

Book Store Data (String Functions)

*/

CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title NVARCHAR(100),
    AuthorFirstName NVARCHAR(50),
    AuthorLastName NVARCHAR(50),
    YearPublished INT,
    QuantityInStore INT,
    Pages INT
);

INSERT INTO Books (BookID, Title, AuthorFirstName, AuthorLastName, YearPublished, QuantityInStore, Pages)
VALUES
    (1, 'To Kill a Mockingbird', 'Harper', 'Lee', 1960, 50, 281),
    (2, 'The Name of the Wind', 'Patrick', 'Rothfuss', 2007, 20, 662),
	(3, 'The Alchemist', 'Paulo', 'Coelho', 1988, 25, 197);
    (4, 'Pride and Prejudice', 'Jane', 'Austen', 1813, 20, 279),
    (5, 'The Great Gatsby', 'F. Scott', 'Fitzgerald', 1925, 35, 180),
	(6, 'The Hobbit', 'J.R.R.', 'Tolkien', 1937, 25, 310),
    (7, 'The Lord of the Rings', 'J.R.R.', 'Tolkien', 1954, 15, 1178),
    (8, 'Harry Potter and the Philosopher''s Stone', 'J.K.', 'Rowling', 1997, 60, 332),
    (9, 'The Da Vinci Code', 'Dan', 'Brown', 2003, 45, 489),
    (10, 'The Hunger Games', 'Suzanne', 'Collins', 2008, 55, 374);

SELECT * 
FROM dbo.Books

-- SUBSTRING(), select the characters from the title after 4 spaces, and only show up to 10 characters
SELECT SUBSTRING(Title, 1, 10) AS 'Short Titles'
FROM dbo.Books;


-- RIGHT() takes the rightmost word and selects up to a specific amount of characters, and LEFT() does the opposite
SELECT RIGHT(Title, 3)
FROM dbo.Books;


-- -- Take Book Titles and spell it backwards; 
SELECT REVERSE(Title)
FROM dbo.Books;


--CHARINDEX(expression to find, expression to search, start location) 
SELECT CHARINDEX(' ', Title, 1)
FROM dbo.Books;


-- Show every word in the Title besides the first word
SELECT SUBSTRING(Title, CHARINDEX(' ', Title, 1) + 1, LEN(Title)-CHARINDEX(' ', Title, 1))
FROM dbo.Books;


-- Show only the last word of the Title // When used with other string manipulation 
-- functions, REVERSE() works with the string in reverse order
SELECT RIGHT(Title, CHARINDEX( ' ', REVERSE(Title)) -1) AS LastWord
FROM dbo.Books;


-- concat and concat ws
-- Create a column and put together the Authors' first and last names, give it an alias
SELECT CONCAT(AuthorFirstName, ' ', AuthorLastName) AS [Full Name]
FROM dbo.Books;


-- Put together the Title, the author's last name, and the year the book was published, give it an alias and order by the 3 most recently published books
SELECT TOP(3) CONCAT_WS(' - ', Title, AuthorLastName, YearPublished) AS BookDetails
FROM dbo.Books
ORDER BY YearPublished DESC


-- Put together the Title, the author's full name, and the year the book was published, give it an alias
SELECT CONCAT_WS(' - ', Title, CONCAT(AuthorFirstName, ' ', AuthorLastName), YearPublished) AS BookDetails
FROM dbo.Books;
--NOTE: CONCAT_WS only works with 3 or more arguments


--Put together the Title and the Authors' Last Name
SELECT CONCAT_WS(' - ', Title, AuthorLastName)
FROM dbo.Books;


-- Put hyphens in every space
SELECT REPLACE(CONCAT(Title, ' ', AuthorLastName), ' ', '-')
FROM dbo.Books;


-- Select only the first 10 words of the Title and add an elipses after each one, give it an alias
SELECT CONCAT(SUBSTRING(Title, 1, 10), '...') AS [Short Title...]
FROM dbo.Books


-- Put only the last name in the Authors' Full Name column in all caps
SELECT UPPER(RIGHT(Title, CHARINDEX( ' ', REVERSE(Title)) -1)) AS LastWordCAPS
FROM dbo.Books;


-- Replace every 'e' in the Titles with the number '3'
SELECT REPLACE(Title, 'e', 3) AS Test
FROM dbo.Books;


-- Replace every 'e' in the Titles with the number '3', and only show the first 10 letters
SELECT SUBSTRING(REPLACE(Title, 'e', 3), 1, 10)
FROM dbo.Books;


-- Show the length of each title
SELECT Title, LEN(Title) AS Title_Length
FROM dbo.Books;


-- Show the count of each Title with a displayed message, give it an alias
SELECT CONCAT(Title, ' is ', LEN(Title), ' characters long.') AS [Title Message]
FROM dbo.Books;


-- Select the Authors' last name and the year their book was published, and list them in one row. Give the new column an alias
SELECT STRING_AGG(
					CONCAT(AuthorLastName, ' (', YearPublished, ') '),
					', ') AS [Author and Published Year]
FROM dbo.Books