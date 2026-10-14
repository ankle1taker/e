/*
DATABASE EXERCISES FINAL — PRACTICAL SQL ANSWERS
Target: MySQL 8.0+ / MariaDB
Run section by section. Administrative statements (CREATE USER / GRANT) require a
privileged MySQL account. Review the notes where the question paper omits table data.
*/

-- =========================================================
-- QUESTION 1 / 3 / 6: DATABASE, USER, PRIVILEGES
-- Run as an administrator (for example, root).
-- =========================================================
CREATE DATABASE IF NOT EXISTS IPRCHUYE;
CREATE USER IF NOT EXISTS 'HRUSER'@'localhost' IDENTIFIED BY 'HRUSER123';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER
ON IPRCHUYE.* TO 'HRUSER'@'localhost';

CREATE DATABASE IF NOT EXISTS ICT;
CREATE USER IF NOT EXISTS 'HODUSER'@'localhost' IDENTIFIED BY 'HODUSER123';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER
ON ICT.* TO 'HODUSER'@'localhost';

-- Connect in a NEW terminal/session:
-- mysql -u HRUSER -p IPRCHUYE
-- mysql -u HODUSER -p ICT
-- Enter the relevant password when prompted.
-- FLUSH PRIVILEGES is not required after CREATE USER or GRANT in modern MySQL.

-- =========================================================
-- QUESTION 2: FOODS AND COMPANY TABLES, SAMPLE DATA, JOIN
-- =========================================================
CREATE DATABASE IF NOT EXISTS food_company_db;
USE food_company_db;

CREATE TABLE IF NOT EXISTS company (
    company_id INT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    company_city VARCHAR(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS foods (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    item_unit VARCHAR(20) NOT NULL,
    company_id INT NULL,
    CONSTRAINT fk_foods_company
        FOREIGN KEY (company_id) REFERENCES company(company_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

INSERT INTO company (company_id, company_name, company_city) VALUES
(18, 'Order All', 'Boston'),
(15, 'Jack Hill Ltd', 'London'),
(16, 'Akas Foods', 'Delhi'),
(17, 'Foodies.', 'London'),
(19, 'sip-n-Bite.', 'New York')
ON DUPLICATE KEY UPDATE
company_name = VALUES(company_name), company_city = VALUES(company_city);

INSERT INTO foods (item_id, item_name, item_unit, company_id) VALUES
(1, 'Chex Mix', 'Pcs', 16),
(6, 'Cheez-It', 'Pcs', 15),
(2, 'BN Biscuit', 'Pcs', 15),
(3, 'Mighty Munch', 'Pcs', 17),
(4, 'Pot Rice', 'Pcs', 15),
(5, 'Jaffa Cakes', 'Pcs', 18),
(7, 'Salt n Shake', 'pcs', NULL)
ON DUPLICATE KEY UPDATE
item_name = VALUES(item_name), item_unit = VALUES(item_unit),
company_id = VALUES(company_id);

-- Required output columns; matches the four rows shown in the question.
SELECT f.item_name, f.item_unit, c.company_name, c.company_city
FROM foods AS f
JOIN company AS c ON c.company_id = f.company_id
WHERE f.item_name IN ('Cheez-It', 'BN Biscuit', 'Mighty Munch', 'Pot Rice')
ORDER BY FIELD(f.item_name, 'Cheez-It', 'BN Biscuit', 'Mighty Munch', 'Pot Rice');

-- =========================================================
-- QUESTION 4: PRODUCTS AND INDUSTRY
-- The paper's product/industry table is structurally the same as foods/company.
-- =========================================================
CREATE DATABASE IF NOT EXISTS products_industry_db;
USE products_industry_db;

CREATE TABLE IF NOT EXISTS industry (
    industry_id INT PRIMARY KEY,
    industry_name VARCHAR(100) NOT NULL,
    industry_city VARCHAR(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    item_unit VARCHAR(20) NOT NULL,
    industry_id INT NULL,
    CONSTRAINT fk_products_industry
        FOREIGN KEY (industry_id) REFERENCES industry(industry_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

INSERT INTO industry (industry_id, industry_name, industry_city) VALUES
(18, 'Order All', 'Boston'),
(15, 'Jack Hill Ltd', 'London'),
(16, 'Akas Foods', 'Delhi'),
(17, 'Foodies.', 'London'),
(19, 'sip-n-Bite.', 'New York')
ON DUPLICATE KEY UPDATE
industry_name = VALUES(industry_name), industry_city = VALUES(industry_city);

INSERT INTO products (item_id, item_name, item_unit, industry_id) VALUES
(1, 'Chex Mix', 'Pcs', 16),
(6, 'Cheez-It', 'Pcs', 15),
(2, 'BN Biscuit', 'Pcs', 15),
(3, 'Mighty Munch', 'Pcs', 17),
(4, 'Pot Rice', 'Pcs', 15),
(5, 'Jaffa Cakes', 'Pcs', 18),
(7, 'Salt n Shake', 'pcs', NULL)
ON DUPLICATE KEY UPDATE
item_name = VALUES(item_name), item_unit = VALUES(item_unit),
industry_id = VALUES(industry_id);

SELECT p.item_name, p.item_unit, i.industry_name, i.industry_city
FROM products AS p
JOIN industry AS i ON i.industry_id = p.industry_id
ORDER BY p.item_id;

-- =========================================================
-- QUESTIONS 3 / 5 / 8: EMPLOYEE PRACTICAL QUERIES
-- The source PDF does not show all employee rows/columns clearly.
-- This table definition assumes the column names stated in the questions.
-- If your lecturer's Employee table already exists, do not recreate it;
-- use the queries below and adjust names to match your actual table.
-- =========================================================
CREATE DATABASE IF NOT EXISTS employee_practical_db;
USE employee_practical_db;

CREATE TABLE IF NOT EXISTS employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(80) NOT NULL,
    job_name VARCHAR(40) NOT NULL,
    hire_date DATE,
    salary DECIMAL(10,2) NOT NULL DEFAULT 0,
    commission DECIMAL(10,2) NULL,
    qualification VARCHAR(100) NULL
);

-- A. Display employees in descending salary order.
SELECT * FROM employee ORDER BY salary DESC;

-- B. Insert KAYLING. The job/date/salary were not specified in the PDF,
-- so use explicit example values; change them to the values supplied in class.
INSERT INTO employee (emp_name, job_name, hire_date, salary, commission, qualification)
VALUES ('KAYLING', 'CLERK', '2024-01-01', 2000.00, NULL, NULL);

-- C. Update Frank's salary to 3500.
UPDATE employee SET salary = 3500.00 WHERE UPPER(emp_name) = 'FRANK';

-- D. Delete WADE's record.
DELETE FROM employee WHERE UPPER(emp_name) = 'WADE';

-- E. Total salary of all managers.
SELECT SUM(salary) AS total_manager_salary
FROM employee
WHERE LOWER(job_name) = 'manager';

-- F. Average salary of all employees.
SELECT AVG(salary) AS average_salary FROM employee;

-- G. Drop commission column (run only once; fails if already removed).
-- ALTER TABLE employee DROP COLUMN commission;

-- H. Employees earning more than 2500 whose job is not manager.
SELECT emp_name, job_name, hire_date, salary
FROM employee
WHERE salary > 2500 AND LOWER(job_name) <> 'manager';

-- I. Add qualification column after hire_date (MySQL/MariaDB).
-- If the column already exists, do not run this statement again.
-- ALTER TABLE employee ADD COLUMN qualification VARCHAR(100) NULL AFTER hire_date;

-- J. Query from the paper: employees with salary < 4000, manager/analyst,
-- excluding CLARE and FRANK.
SELECT emp_name, job_name, salary
FROM employee
WHERE salary < 4000
  AND LOWER(job_name) IN ('manager', 'analyst')
  AND UPPER(emp_name) NOT IN ('CLARE', 'FRANK');

-- =========================================================
-- QUESTION 7: FRIENDS TABLE
-- Assumed fields because the table image/data is not readable in extracted text.
-- =========================================================
CREATE DATABASE IF NOT EXISTS friends_practical_db;
USE friends_practical_db;

CREATE TABLE IF NOT EXISTS friends (
    friend_id INT PRIMARY KEY AUTO_INCREMENT,
    firstname VARCHAR(60) NOT NULL,
    lastname VARCHAR(60) NOT NULL,
    st CHAR(2) NOT NULL
);

-- B. Everyone whose last name begins with M.
SELECT * FROM friends WHERE lastname LIKE 'M%';

-- C. Everyone who lives in IL and whose first name is AL.
SELECT * FROM friends WHERE st = 'IL' AND firstname = 'AL';

-- D. Remove all rows but keep the table structure.
TRUNCATE TABLE friends;

-- E. Remove the table itself.
-- DROP TABLE friends;

-- F. What the query returns: FIRSTNAME and ST for rows where FIRSTNAME is AL or JD.
SELECT firstname, st
FROM friends
WHERE firstname = 'AL' OR firstname = 'JD';

-- =========================================================
-- QUESTION 9: SOCCER DATABASE DESIGN (TABLES + KEYS)
-- Captures teams, players, matches, match participation, substitutions and referees.
-- =========================================================
CREATE DATABASE IF NOT EXISTS soccer_db;
USE soccer_db;

CREATE TABLE IF NOT EXISTS teams (
    team_id INT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    main_stadium VARCHAR(120) NOT NULL,
    city VARCHAR(80) NOT NULL
);

CREATE TABLE IF NOT EXISTS players (
    player_id INT PRIMARY KEY,
    team_id INT NOT NULL,
    player_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    start_year YEAR,
    shirt_number INT NOT NULL,
    CONSTRAINT uq_player_team_shirt UNIQUE (team_id, shirt_number),
    CONSTRAINT fk_players_team FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE IF NOT EXISTS matches (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    host_team_id INT NOT NULL,
    guest_team_id INT NOT NULL,
    match_date DATETIME NOT NULL,
    host_goals INT NOT NULL DEFAULT 0,
    guest_goals INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_match_host FOREIGN KEY (host_team_id) REFERENCES teams(team_id),
    CONSTRAINT fk_match_guest FOREIGN KEY (guest_team_id) REFERENCES teams(team_id),
    CONSTRAINT chk_different_teams CHECK (host_team_id <> guest_team_id),
    CONSTRAINT chk_match_goals CHECK (host_goals >= 0 AND guest_goals >= 0)
);

CREATE TABLE IF NOT EXISTS match_players (
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    goals_scored INT NOT NULL DEFAULT 0,
    yellow_card BOOLEAN NOT NULL DEFAULT FALSE,
    red_card BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (match_id, player_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    CHECK (goals_scored >= 0)
);

CREATE TABLE IF NOT EXISTS substitutions (
    substitution_id INT PRIMARY KEY AUTO_INCREMENT,
    match_id INT NOT NULL,
    player_out_id INT NOT NULL,
    player_in_id INT NOT NULL,
    substitution_minute SMALLINT NOT NULL,
    FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    FOREIGN KEY (player_out_id) REFERENCES players(player_id),
    FOREIGN KEY (player_in_id) REFERENCES players(player_id),
    CHECK (player_out_id <> player_in_id),
    CHECK (substitution_minute BETWEEN 0 AND 130)
);

CREATE TABLE IF NOT EXISTS referees (
    referee_id INT PRIMARY KEY,
    referee_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    years_experience TINYINT UNSIGNED NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS match_referees (
    match_id INT NOT NULL,
    referee_id INT NOT NULL,
    referee_role ENUM('MAIN', 'ASSISTANT') NOT NULL,
    PRIMARY KEY (match_id, referee_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id) ON DELETE CASCADE,
    FOREIGN KEY (referee_id) REFERENCES referees(referee_id)
);
-- Business rule "exactly three referees per match, one MAIN and two ASSISTANT"
-- needs application logic or database triggers; a simple CHECK cannot enforce row counts.

-- =========================================================
-- QUESTION 25: NOTOWN RECORDS DATABASE DESIGN
-- =========================================================
CREATE DATABASE IF NOT EXISTS notown_records_db;
USE notown_records_db;

CREATE TABLE IF NOT EXISTS musicians (
    ssn VARCHAR(20) PRIMARY KEY,
    musician_name VARCHAR(120) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    CONSTRAINT uq_musician_phone UNIQUE (phone)
);

CREATE TABLE IF NOT EXISTS instruments (
    instrument_id INT PRIMARY KEY,
    instrument_name VARCHAR(80) NOT NULL,
    musical_key VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS albums (
    album_id INT PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    copyright_date DATE,
    format ENUM('CD', 'MC', 'VINYL', 'DIGITAL', 'OTHER') NOT NULL,
    album_identifier VARCHAR(80) NOT NULL UNIQUE,
    producer_ssn VARCHAR(20) NOT NULL,
    FOREIGN KEY (producer_ssn) REFERENCES musicians(ssn)
);

CREATE TABLE IF NOT EXISTS songs (
    song_id INT PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    author VARCHAR(120) NOT NULL,
    album_id INT NOT NULL,
    CONSTRAINT fk_song_album FOREIGN KEY (album_id) REFERENCES albums(album_id)
);

-- Many musicians can play many instruments.
CREATE TABLE IF NOT EXISTS musician_instruments (
    ssn VARCHAR(20) NOT NULL,
    instrument_id INT NOT NULL,
    PRIMARY KEY (ssn, instrument_id),
    FOREIGN KEY (ssn) REFERENCES musicians(ssn) ON DELETE CASCADE,
    FOREIGN KEY (instrument_id) REFERENCES instruments(instrument_id)
);

-- Many musicians perform many songs.
CREATE TABLE IF NOT EXISTS song_performers (
    song_id INT NOT NULL,
    ssn VARCHAR(20) NOT NULL,
    PRIMARY KEY (song_id, ssn),
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE,
    FOREIGN KEY (ssn) REFERENCES musicians(ssn)
);

-- =========================================================
-- QUESTIONS 56-58: USERS, PRIVILEGES, VIEWS, INDEXES
-- =========================================================
-- 56(a) List MySQL accounts (requires permission to read mysql.user).
SELECT user, host FROM mysql.user ORDER BY user, host;

-- 56(b) Check privileges (run each command for the account being audited).
SHOW GRANTS FOR 'analyst'@'localhost';
SHOW GRANTS FOR 'HRUSER'@'localhost';
SHOW GRANTS FOR 'HODUSER'@'localhost';

-- 56(c-e) Passwords cannot be retrieved as readable original text.
-- Reset instead, as an administrator:
-- ALTER USER 'analyst'@'localhost' IDENTIFIED BY 'NewStrongPassword!2026';

-- 57: Example view; a view stores a query definition, not normally a separate copy of rows.
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(190) UNIQUE
);

CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE OR REPLACE VIEW customer_order_summary AS
SELECT c.id AS customer_id, c.name, COUNT(o.id) AS total_orders,
       COALESCE(SUM(o.amount), 0) AS total_spent
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.name;

-- View query:
SELECT * FROM customer_order_summary;

-- 58: Index creation examples.
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);
-- Inspect indexes:
SHOW INDEX FROM orders;
-- Inspect a query plan:
EXPLAIN SELECT * FROM orders WHERE customer_id = 20;

-- =========================================================
-- QUESTIONS 59-70: TRANSACTIONS, TESTING, BACKUP NOTES, PERFORMANCE
-- =========================================================
-- 59. Transaction failure handling example.
-- Requires an InnoDB table. This section creates a separate example accounts table.
CREATE TABLE IF NOT EXISTS accounts (
    id INT PRIMARY KEY,
    balance DECIMAL(12,2) NOT NULL,
    CHECK (balance >= 0)
) ENGINE=InnoDB;

-- Example transfer; run only after inserting account IDs 1 and 2.
-- START TRANSACTION;
-- UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- COMMIT;
-- If an operation fails, issue ROLLBACK before committing.

-- 60. Deadlock guidance (no single SQL statement solves every deadlock):
-- update rows in the same order in every transaction; keep transactions short;
-- retry the transaction selected by MySQL as the deadlock victim.

-- 61. Leading wildcard usually prevents use of a normal B-tree index efficiently:
-- Inefficient for a normal index:
-- SELECT * FROM users WHERE email LIKE '%gmail.com';
-- Prefer equality when exact email is known:
-- SELECT * FROM users WHERE email = 'abc@gmail.com';

-- 62. Index on a join/filter column (if not already present).
-- CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- 63. Data integrity checks.
-- Duplicate primary-key check is unnecessary for a correctly enforced PK, but useful
-- for imported/staging tables where the key is not yet constrained:
SELECT id, COUNT(*) AS occurrences
FROM customers
GROUP BY id
HAVING COUNT(*) > 1;

-- Find orders whose customer row is missing (should return zero rows when FK is enforced).
SELECT o.customer_id
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
WHERE c.id IS NULL;

-- 64. Constraint testing: use a deliberate duplicate only in a disposable test database.
-- If customers.email already contains this address, this INSERT should be rejected
-- by UNIQUE; it is commented out to avoid interrupting a complete script.
-- INSERT INTO customers (id, name, email)
-- VALUES (999999, 'Test Duplicate', 'existing-address@example.com');

-- 65. Final validation examples.
SHOW INDEX FROM orders;
EXPLAIN SELECT * FROM orders WHERE customer_id = 20;
SHOW CREATE TABLE customers;
SHOW CREATE TABLE orders;

-- 66. Backup/restore commands are shell commands, not SQL; run in terminal:
-- Backup: mysqldump -u root -p company_db > backup.sql
-- Restore: mysql -u root -p company_db < backup.sql

-- 67. Improve SELECT query performance with an index.
-- CREATE INDEX idx_orders_customer_id ON orders(customer_id);
-- SELECT * FROM orders WHERE customer_id = 20;

-- 68. Create a read-only analyst user.
CREATE USER IF NOT EXISTS 'analyst'@'localhost'
IDENTIFIED BY 'password123';
GRANT SELECT ON company_db.* TO 'analyst'@'localhost';

-- 69. Return each customer and their total order amount.
SELECT c.name, SUM(o.amount) AS total_amount
FROM customers AS c
JOIN orders AS o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- 70. Count orders and total amount for customers with at least two orders.
SELECT c.id, c.name,
       COUNT(o.id) AS total_orders,
       SUM(o.amount) AS total_spent
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.name
HAVING COUNT(o.id) >= 2;

-- END OF ANSWERS
