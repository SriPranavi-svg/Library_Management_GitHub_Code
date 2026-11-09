-- ============================================================
-- LIBRARY MANAGEMENT SYSTEM
-- DBMS Mini Project | MySQL 8.0+
-- ============================================================

DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- 1. TABLE CREATION

CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(60)
);

CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL
);

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publisher_id INT,
    category_id INT,
    publication_year YEAR,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE,
    join_date DATE NOT NULL,
    member_status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE'
);

CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    accession_number VARCHAR(30) NOT NULL UNIQUE,
    copy_status ENUM('AVAILABLE', 'ISSUED', 'DAMAGED', 'LOST')
        DEFAULT 'AVAILABLE',
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id INT,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    loan_status ENUM('ISSUED', 'RETURNED') DEFAULT 'ISSUED',
    CHECK (due_date >= issue_date),
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_status ENUM('PENDING', 'FULFILLED', 'CANCELLED')
        DEFAULT 'PENDING',
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL UNIQUE,
    fine_amount DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    payment_status ENUM('UNPAID', 'PAID') DEFAULT 'UNPAID',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id),
    CHECK (fine_amount >= 0)
);

-- 2. SAMPLE DATA

INSERT INTO publishers (publisher_name, city) VALUES
('Pearson', 'London'),
('Penguin Random House', 'New York'),
('O''Reilly Media', 'California');

INSERT INTO authors (author_name) VALUES
('R. K. Narayan'),
('James Clear'),
('Andrew S. Tanenbaum'),
('Herbert Schildt');

INSERT INTO categories (category_name) VALUES
('Fiction'), ('Self Help'), ('Computer Science');

INSERT INTO books (title, isbn, publisher_id, category_id, publication_year) VALUES
('Malgudi Days', 'ISBN1001', 2, 1, 1982),
('Atomic Habits', 'ISBN1002', 2, 2, 2018),
('Computer Networks', 'ISBN1003', 1, 3, 2011),
('Java: The Complete Reference', 'ISBN1004', 1, 3, 2018);

INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4);

INSERT INTO members (member_name, email, phone, join_date) VALUES
('Ananya Rao', 'ananya@example.com', '9000000001', '2026-01-10'),
('Rahul Kumar', 'rahul@example.com', '9000000002', '2026-02-15'),
('Meera Shah', 'meera@example.com', '9000000003', '2026-03-20'),
('Arjun Reddy', 'arjun@example.com', '9000000004', '2026-04-05');

INSERT INTO staff (staff_name, email) VALUES
('Kavya Sharma', 'kavya@library.com'),
('Suresh Nair', 'suresh@library.com');

INSERT INTO book_copies (book_id, accession_number, copy_status) VALUES
(1, 'ACC1001', 'AVAILABLE'),
(1, 'ACC1002', 'AVAILABLE'),
(2, 'ACC1003', 'AVAILABLE'),
(3, 'ACC1004', 'AVAILABLE'),
(3, 'ACC1005', 'AVAILABLE'),
(4, 'ACC1006', 'AVAILABLE');

-- 3. BASIC DML
-- Issue a book copy to a member.
INSERT INTO loans (copy_id, member_id, staff_id, issue_date, due_date)
VALUES (1, 1, 1, '2026-10-01', '2026-10-15');

UPDATE book_copies
SET copy_status = 'ISSUED'
WHERE copy_id = 1;

-- Add a reservation.
INSERT INTO reservations (book_id, member_id, reservation_date)
VALUES (3, 2, '2026-10-02');

-- 4. BASIC SELECT AND JOINS

SELECT * FROM books;
SELECT * FROM members;

SELECT b.book_id, b.title, c.category_name, p.publisher_name
FROM books b
LEFT JOIN categories c ON b.category_id = c.category_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id;

SELECT b.title, a.author_name
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id;

SELECT l.loan_id, m.member_name, b.title, l.issue_date, l.due_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id;

-- 5. CONSTRAINT / SET OPERATION EXAMPLES

-- Books whose category ID is equal to at least one category ID used by books.
SELECT title
FROM books
WHERE category_id = ANY (
    SELECT category_id FROM categories WHERE category_name = 'Computer Science'
);

-- Members who have made every reservation in the selected result set.
-- ALL example using a numeric comparison:
SELECT member_name
FROM members
WHERE member_id > ALL (
    SELECT member_id FROM members WHERE member_id < 2
);

-- UNION: titles from books and a second list of sample reading materials.
SELECT title AS item_name FROM books
UNION
SELECT 'Library Annual Report' AS item_name;

-- MySQL does not support INTERSECT in all older versions.
-- This JOIN gives the intersection: books that have at least one copy.
SELECT b.title
FROM books b
INNER JOIN book_copies bc ON b.book_id = bc.book_id;

-- 6. NESTED AND CORRELATED SUBQUERIES

-- Books belonging to the category 'Computer Science'.
SELECT title
FROM books
WHERE category_id = (
    SELECT category_id
    FROM categories
    WHERE category_name = 'Computer Science'
);

-- Members who have at least one loan (correlated subquery).
SELECT m.member_id, m.member_name
FROM members m
WHERE EXISTS (
    SELECT 1
    FROM loans l
    WHERE l.member_id = m.member_id
);

-- Books with more copies than the average number of copies per book.
SELECT b.title
FROM books b
WHERE (
    SELECT COUNT(*)
    FROM book_copies bc
    WHERE bc.book_id = b.book_id
) > (
    SELECT AVG(copy_count)
    FROM (
        SELECT COUNT(*) AS copy_count
        FROM book_copies
        GROUP BY book_id
    ) AS copy_totals
);

-- 7. AGGREGATE FUNCTIONS, GROUP BY, HAVING, WINDOW FUNCTIONS

SELECT COUNT(*) AS total_books FROM books;
SELECT COUNT(*) AS total_members FROM members;

SELECT category_id, COUNT(*) AS number_of_books
FROM books
GROUP BY category_id;

SELECT book_id, COUNT(*) AS copies
FROM book_copies
GROUP BY book_id
HAVING COUNT(*) >= 2;

SELECT member_id, COUNT(*) AS total_loans
FROM loans
GROUP BY member_id;

SELECT
    member_id,
    loan_id,
    issue_date,
    ROW_NUMBER() OVER (
        PARTITION BY member_id ORDER BY issue_date
    ) AS loan_number
FROM loans;

SELECT
    book_id,
    title,
    RANK() OVER (ORDER BY publication_year DESC) AS publication_rank
FROM books;

-- 8. VIEWS

CREATE VIEW available_books AS
SELECT b.book_id, b.title, bc.copy_id, bc.accession_number
FROM books b
JOIN book_copies bc ON b.book_id = bc.book_id
WHERE bc.copy_status = 'AVAILABLE';

CREATE VIEW active_loans AS
SELECT l.loan_id, m.member_name, b.title, l.issue_date, l.due_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE l.loan_status = 'ISSUED';

SELECT * FROM available_books;
SELECT * FROM active_loans;

-- 9. TRIGGERS

DELIMITER //

CREATE TRIGGER after_loan_insert
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
    UPDATE book_copies
    SET copy_status = 'ISSUED'
    WHERE copy_id = NEW.copy_id;
END//

CREATE TRIGGER after_loan_return
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.loan_status = 'RETURNED'
       AND OLD.loan_status <> 'RETURNED' THEN
        UPDATE book_copies
        SET copy_status = 'AVAILABLE'
        WHERE copy_id = NEW.copy_id;
    END IF;
END//

DELIMITER ;

-- 10. STORED PROCEDURES

DELIMITER //

CREATE PROCEDURE GetMemberLoans(IN p_member_id INT)
BEGIN
    SELECT l.loan_id, b.title, l.issue_date, l.due_date,
           l.return_date, l.loan_status
    FROM loans l
    JOIN book_copies bc ON l.copy_id = bc.copy_id
    JOIN books b ON bc.book_id = b.book_id
    WHERE l.member_id = p_member_id;
END//

CREATE PROCEDURE ReturnBook(IN p_loan_id INT, IN p_return_date DATE)
BEGIN
    UPDATE loans
    SET return_date = p_return_date,
        loan_status = 'RETURNED'
    WHERE loan_id = p_loan_id;
END//

DELIMITER ;

-- Procedure calls (run when required):
-- CALL GetMemberLoans(1);
-- CALL ReturnBook(1, '2026-10-12');

-- 11. CURSOR EXAMPLE
-- Displays each member and their number of loans.

DELIMITER //

CREATE PROCEDURE DisplayMemberLoanCounts()
BEGIN
    DECLARE finished INT DEFAULT 0;
    DECLARE v_member_name VARCHAR(100);
    DECLARE v_loan_count INT;

    DECLARE member_cursor CURSOR FOR
        SELECT m.member_name, COUNT(l.loan_id)
        FROM members m
        LEFT JOIN loans l ON m.member_id = l.member_id
        GROUP BY m.member_id, m.member_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN member_cursor;

    read_loop: LOOP
        FETCH member_cursor INTO v_member_name, v_loan_count;

        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        SELECT v_member_name AS member_name,
               v_loan_count AS total_loans;
    END LOOP;

    CLOSE member_cursor;
END//

DELIMITER ;

-- Run cursor procedure:
-- CALL DisplayMemberLoanCounts();

-- 12. PROJECT-SPECIFIC QUERIES

-- List all currently available copies.
SELECT b.title, bc.accession_number
FROM books b
JOIN book_copies bc ON b.book_id = bc.book_id
WHERE bc.copy_status = 'AVAILABLE';

-- Find overdue loans that have not yet been returned.
SELECT l.loan_id, m.member_name, b.title, l.due_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE l.loan_status = 'ISSUED'
  AND l.due_date < CURDATE();

-- Count books by category.
SELECT c.category_name, COUNT(b.book_id) AS total_books
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name;

-- Show pending reservations.
SELECT r.reservation_id, m.member_name, b.title, r.reservation_date
FROM reservations r
JOIN members m ON r.member_id = m.member_id
JOIN books b ON r.book_id = b.book_id
WHERE r.reservation_status = 'PENDING';

-- Mark a fine as paid (example).
-- UPDATE fines SET payment_status = 'PAID' WHERE fine_id = 1;

-- END OF PROJECT
