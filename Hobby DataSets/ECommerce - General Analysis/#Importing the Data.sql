-- LOOKUP TABLE CREATION
-- ADD COMMENTS

DROP TABLE IF EXISTS payment_types CASCADE;  -- drop table if it exists and remove dependent objects

CREATE TABLE payment_types (  -- create lookup table for payment methods
	paytid SERIAL PRIMARY KEY,  -- unique auto-incrementing identifier for each payment type
	paytype VARCHAR(20) NOT NULL  -- name of the payment method
);

COPY payment_types  -- bulk load data into payment_types table
FROM 'C:\Users\Nikhil RK\Desktop\Data Analysis\SQL\SQL PRAC DBs\LASTSQL\payment_types.csv'  -- source CSV file path
DELIMITER ','  -- comma is used as the column separator
CSV HEADER;  -- first row contains column names



-- MASTER TABLE CREATION
-- TABLE: customers
-- ADD COMMENTS

DROP TABLE IF EXISTS customers CASCADE;  -- drop customers table if it exists

CREATE TABLE customers (  -- create table storing customer information
	custid SERIAL PRIMARY KEY,  -- unique auto-incrementing customer ID
	customer_name VARCHAR(50) NOT NULL,  -- full name of the customer
	city VARCHAR(50) NOT NULL,  -- city where the customer resides
	signup_date DATE NOT NULL,  -- date when the customer registered
	age INT NOT NULL,  -- age of the customer
	sex VARCHAR(2) NOT NULL,  -- gender code such as M or F
	preferredpaytype INT REFERENCES payment_types(paytid)  -- foreign key referencing preferred payment type
);

COPY customers  -- bulk load customer data into customers table
FROM 'C:\Users\Nikhil RK\Desktop\Data Analysis\SQL\SQL PRAC DBs\LASTSQL\customers.csv'  -- source CSV file path
DELIMITER ','  -- comma is used as the column separator
CSV HEADER;  -- first row contains column names



-- TABLE: products
-- ADD COMMENTS

DROP TABLE IF EXISTS products CASCADE;  -- drop products table if it exists

CREATE TABLE products (  -- create table storing product information
	prodid SERIAL PRIMARY KEY,  -- unique auto-incrementing product ID
	prodCat VARCHAR(25) NOT NULL,  -- category of the product
	prodName VARCHAR(100) NOT NULL,  -- name of the product
	rate NUMERIC(4) NOT NULL,  -- price or rate of the product
	age INT NOT NULL,  -- target customer age group for the product
	sex VARCHAR(2) NOT NULL,  -- target gender for the product
	preferredpaytype INT REFERENCES payment_types(paytid)  -- recommended payment type linked via foreign key
);

COPY products  -- bulk load product data into products table
FROM 'C:\Users\Nikhil RK\Desktop\Data Analysis\SQL\SQL PRAC DBs\LASTSQL\products.csv'  -- source CSV file path
DELIMITER ','  -- comma is used as the column separator
CSV HEADER;  -- first row contains column names