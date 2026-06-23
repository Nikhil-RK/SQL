-- CTE PRAC 1


-- Creating Master Table: Products
CREATE TABLE products(
	product_id SERIAL PRIMARY KEY,
	product_name VARCHAR(50) UNIQUE, 
	category VARCHAR(20) NOT NULL,
	price NUMERIC(7,2) NOT NULL
);

DROP TABLE cteprac1.products;

COPY products 
FROM 'C:\Users\Nikhil RK\Desktop\Data\SQL\Local Store Analysis\Dataset\products.csv' 
DELIMITER ',' 
CSV HEADER;


-- Creating Transaction Table: Orders
CREATE TABLE orders(
	order_id SERIAL PRIMARY KEY,
	product_id INT NOT NULL REFERENCES products(product_id),
	order_date DATE NOT NULL,
	quantity INT NOT NULL,
	revenue INT NOT NULL
);

DROP TABLE cteprac1.orders;

COPY orders 
FROM 'C:\Users\Nikhil RK\Desktop\Data\SQL\Local Store Analysis\Dataset\orders.csv' 
DELIMITER ',' 
CSV HEADER;




-- OPTION 2: FOR PRACTICE ONLY
-- THE GIVEN DATA WAS ON PAPER and INSERT INTO DATABASE MANUALLY
-- PRODUCTS TABLE
INSERT INTO products (product_id, product_name, category, price)
VALUES
    (1, 'Laptop', 'Electronics', 60000),
    (2, 'Phone', 'Electronics', 30000),
    (3, 'Chair', 'Furniture', 8000),
    (4, 'Table', 'Furniture', 12000);

-- ORDERS TABLE
INSERT INTO orders (order_id, product_id,order_date, quantity, revenue)
VALUES  (101, 1, '2024-01-05', 1, 60000),
		(102, 2, '2024-01-06', 2, 60000),
		(103, 1, '2024-01-10', 1, 60000),
		(104, 3, '2024-01-12', 3, 24000),
		(105, 4, '2024-01-15', 1, 12000),
		(106, 2, '2024-01-18', 1, 30000);