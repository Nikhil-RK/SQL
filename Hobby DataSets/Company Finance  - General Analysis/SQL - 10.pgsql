-- 1. Write a query to join the customers and orders tables and calculate total sales, average order value, 
-- and order count for each customer. [Ref: orders, customers: customer_id, customer_name, sales]
SELECT	c.customer_id,			                                           
        SUM(o.saleprice) AS totalSales,      		        
        ROUND(AVG(o.saleprice), 2) AS averageOrderValue,    
        COUNT(*) AS orderCount           			        
FROM customers AS c                   				        
INNER JOIN orders AS o                				        
ON c.customer_id = o.customer_id  				            
GROUP BY c.customer_id
ORDER BY totalSales DESC, averageordervalue DESC, orderCount DESC;                                    



--2. Write a query to join the products and orders tables and find the top N=4 
-- categories based on total revenue and order count. [Ref: orders, products: category, sales]
SELECT  p.category,	
        SUM(o.saleprice) AS totalRevenue,
        -- TO_CHAR(SUM(o.saleprice), '99,99,99,999.00') AS totalRevenue,      		        
        COUNT(*) AS orderCount           			        
FROM products AS p
INNER JOIN orders AS o  
ON p.prod_id = o.prod_id
GROUP BY p.category
ORDER BY totalRevenue DESC
LIMIT 4;



-- 3. Write a query to join the employees and departments tables and calculate department-wise
--  average, minimum, and maximum salary. 
-- [Ref: employee, department: dept_id, department, salary]
SELECT  d.dept_id, d.dept_name,
        ROUND(AVG(e.salary), 2) AS averageSalary,
        MIN(e.salary) AS minimumSalary,
        MAX(e.salary) AS maximumSalary 
        -- '₹ ' || TO_CHAR(MAX(e.salary), '99,99,99,999.00') AS maximumSalary
FROM employees AS e
INNER JOIN departments AS d
ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;



--4. Write a query to join the orders and products tables and retrieve the top N=1 products based on total sales amount. 
--  [Ref: orders, products: product_id, product_name, sales]
WITH ranking AS (
SELECT  p.prod_id, p.prod_name, 
        SUM(o.saleprice) AS totalSales,
        ROW_NUMBER() OVER (ORDER BY SUM(o.saleprice) DESC) AS rank
FROM orders AS o
INNER JOIN products AS p
ON o.prod_id = p.prod_id
GROUP BY p.prod_id, p.prod_name)

SELECT  prod_id, prod_name, totalSales
FROM ranking
WHERE rank < 2;



-- 5. Write a query to find customers whose total spending exceeds the average spending of customers in their region.
-- [Ref: customers, orders: customer_id, customer_name, region, sales]
WITH totalspending AS (
        SELECT  c.customer_id, c.region,
                SUM(o.saleprice) AS totalSpendings
        FROM customers As c 
        INNER JOIN orders As o  
        ON c.customer_id = o.customer_id
        GROUP BY c.customer_id, c.region),

custavgspending AS (
        SELECT  region,
                ROUND(AVG(totalSpendings),2) AS avgSpending
        FROM totalspending
        GROUP BY region)

SELECT  ts.customer_id, ts.region, ts.totalSpendings, ca.avgSpending
FROM totalspending AS ts
INNER JOIN custavgspending AS ca
ON ts.region = ca.region
WHERE ts.totalSpendings > ca.avgSpending
ORDER BY ts.region, ts.totalSpendings DESC;



-- 6.	Write a query to find employee whose average salary exceeds the department average salary of employees 
-- [Ref: employees, departments: dept_id, department, salary]
WITH deptAvg AS (
        SELECT  d.dept_id, d.dept_name,
                ROUND(AVG(e.salary), 2) AS deptAvgSalary
        FROM employees AS e
        INNER JOIN departments AS d
        ON e.dept_id = d.dept_id
        GROUP BY d.dept_id, d.dept_name)

SELECT e.emp_id, e.emp_name, d.dept_name, e.salary, d.deptAvgSalary
FROM employees AS e
INNER JOIN deptAvg AS d                 
ON e.dept_id = d.dept_id
WHERE e.salary > d.deptAvgSalary
ORDER BY d.deptAvgSalary DESC;



-- 7.	Write a query to calculate cumulative (running) revenue by month.
-- [Ref: orders: order_date, sales]
WITH monthlyrevenue AS (
        SELECT  DATE_TRUNC('month', order_date) AS mnt,
                SUM(saleprice) AS monthlyRevenue
        FROM orders
        GROUP BY DATE_TRUNC('month',order_date))

SELECT mnt, monthlyRevenue, SUM(monthlyRevenue) OVER (ORDER BY mnt) AS cumulativeRevenue
FROM monthlyrevenue;




-- 8.	Calculate the rolling average revenue over the previous N=3 months.
-- [Ref : orders: order_date, sales]
WITH monthlyrevenue AS (
        SELECT  DATE_TRUNC('month', order_date) AS mnt,
                SUM(saleprice) AS monthlyRevenue
        FROM orders
        GROUP BY DATE_TRUNC('month',order_date))

SELECT mnt, monthlyRevenue, 
        ROUND(AVG(monthlyRevenue) OVER (ORDER BY mnt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) ,2) AS rollingAverage
FROM monthlyrevenue;



-- 9. Retrieve the top N=2 products within each category based on revenue
-- [Ref: orders, products: category, product_id, product_name, sales]
SELECT category, prod_id, prod_name, totalRev
FROM (SELECT  p.category, p.prod_id, p.prod_name,
        SUM(o.saleprice) AS totalRev,
        ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY SUM(o.saleprice) DESC) AS rnk
FROM orders AS o 
INNER JOIN products AS p
ON o.prod_id = p.prod_id
GROUP BY p.category, p.prod_id, p.prod_name) AS rnked
WHERE rnk < 3;



-- 10.	Identify duplicate records in the transactions table and retain only the latest transaction for 
-- each customer-product combination. [Ref: transactions: transaction_id, customer_id, product_id, transaction_date]
WITH duplicates AS (
        SELECT  transaction_id, customer_id, prod_id, transaction_date,
                ROW_NUMBER() OVER (PARTITION BY customer_id, prod_id ORDER BY transaction_date DESC) AS rn
        FROM transactions
)
SELECT transaction_id, customer_id, prod_id, transaction_date
FROM duplicates
WHERE rn = 1;
