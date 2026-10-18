DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(50)
);

COPY customers
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/customers.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM customers;

--------------------------------------------------------------
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    prod_id INT PRIMARY KEY,
    prod_name VARCHAR(50),
    category VARCHAR(20)
);

COPY products
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/products.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM products;

--------------------------------------------------------------
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

COPY departments
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/departments.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM departments;

--------------------------------------------------------------
DROP TABLE IF EXISTS events;

CREATE TABLE events (
    user_id INT,
    event_date DATE 
);

COPY events
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/events.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM events;

--------------------------------------------------------------
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT REFERENCES departments(dept_id),
    salary NUMERIC(10, 2)
);

COPY employees
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/employees.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM employees;

--------------------------------------------------------------
DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    prod_id INT REFERENCES products(prod_id),
    order_count INT,
    revenue NUMERIC(10, 2)
);

COPY sales
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/sales.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM sales;

--------------------------------------------------------------
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    prod_id INT REFERENCES products(prod_id),
    category VARCHAR(20),
    salePrice NUMERIC(10, 2),
    costPrice NUMERIC(10, 2),
    order_date DATE
);

COPY orders
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/orders.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM orders;

--------------------------------------------------------------
DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    prod_id INT REFERENCES products(prod_id),
    quantity INT,
    amount NUMERIC(10, 2),
    transaction_date DATE
);

COPY transactions
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/transactions.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM transactions;

--------------------------------------------------------------
DROP TABLE IF EXISTS df1;

CREATE TABLE df1 (
    col1 VARCHAR(5),
    col2 INT
);

COPY df1
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/df1.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM df1;

--------------------------------------------------------------
DROP TABLE IF EXISTS df2;

CREATE TABLE df2 (
    col2 INT,        
    col3 VARCHAR(5)
);

COPY df2
FROM 'C:/Users/Nikhil RK/Desktop/GIT/SQL/3. General/General DataSet/df2.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM df2;