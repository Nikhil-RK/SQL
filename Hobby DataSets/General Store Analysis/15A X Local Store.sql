
-- STUDY THE DATA


SELECT * FROM orders;
SELECT * FROM products


-- Question 1: Total revenue by product
-- Approach: Calculating per product revenue using orders table
WITH product_Revenue AS
(
    -- Grouping the Revenue according to each product
	SELECT 
		p.product_id, 
		p.product_name, 
		SUM(revenue) AS prodrevenue
	FROM 
		orders AS o
	-- JOINING them with the MASTER table
	INNER JOIN 
		products AS p
	ON 
		o.product_id = p.product_id
	GROUP BY 
		p.product_id, p.product_name
)
-- Main Query: Query out the necessary details from the CTE
SELECT product_name, prodrevenue
FROM product_Revenue
ORDER BY prodrevenue DESC;



----------------- --------------------------------- ---------------------------- --------------------------------
-- Question 2: Category-wise revenue
-- Approach: GroupBy Category on its Revenue - Join them to Products Table on: product_id
WITH CategoryRevenue AS (
	SELECT 
		p.category,
		SUM(revenue) AS catwiseRevenue
	FROM orders AS o
	INNER JOIN products AS p
	ON o.product_id = p.product_id
	GROUP BY p.category
)
-- Main Query: 
SELECT category, catwiseRevenue
FROM CategoryRevenue
ORDER BY catwiseRevenue DESC;



----------------- --------------------------------- ---------------------------- --------------------------------
-- Question 3: Total quantity sold per product
-- Approach: SUM the 'quantity' adn group under 'product_id'
WITH qty_per_prod AS 
(
	SELECT 
		p.product_name, 
		SUM(quantity) AS prodSold
	FROM orders AS o
	INNER JOIN products AS p
	ON o.product_id = p.product_id
	GROUP BY p.product_name
)
-- Main Query: 
SELECT product_name, prodSold
FROM qty_per_prod
ORDER BY prodSold DESC;



----------------- --------------------------------- ---------------------------- --------------------------------
-- Question 4: Daily cumulative revenue
-- Approach: SUM of Revenue OVER () group by order_date column
WITH cumRevenue AS
(
	SELECT 
		order_date,
		Revenue,
		SUM(revenue) OVER(ORDER BY order_date) AS cum_Revenue
	FROM orders
)
-- Main Query: 
SELECT order_date, cum_Revenue
FROM cumRevenue



----------------- --------------------------------- ---------------------------- --------------------------------
-- Question 5: Cumulative revenue per category
-- Approach: SUM of Revenue OVER () group by category and order by order_date column
WITH cumRevperCategory AS 
(
SELECT 
	category,
	order_date,
	revenue,
	SUM(o.revenue) OVER (PARTITION BY p.category ORDER BY order_date) AS revenuePerCat
FROM orders AS o
INNER JOIN products AS p
ON o.product_id = p.product_id
)
-- Main Query: 
SELECT category, order_date,revenuePerCat
FROM cumRevperCategory



----------------- --------------------------------- ---------------------------- --------------------------------
-- Question 6: Top-selling product
-- Approach: sum of quantity and group by under product id as a Window Function.
--			 In MainQuery: OrderBy based of window function and Limit 1.
WITH topSelling AS
(
SELECT 
	p.product_name,
	SUM(revenue) AS prodRevenue
FROM orders AS o
INNER JOIN products AS p
ON o.product_id = p.product_id
GROUP BY p.product_id
)
-- Main Query: 
SELECT product_name, prodRevenue
FROM topSelling
ORDER BY prodRevenue DESC
LIMIT 1;


----------------- --------------------------------- ---------------------------- --------------------------------
-- Q7. Total revenue per category
-- Approach: Join Order and Product table for category - Window the value of revenue/category - Use it in Main Query
WITH revenuePerCategory AS
							(
							SELECT
								category,
								revenue,
								SUM(revenue) OVER (PARTITION BY category) AS revPerCategory
							FROM orders AS o
							INNER JOIN products AS p
								ON o.product_id = p.product_id
							)
-- Main Query: 				
SELECT DISTINCT category,revPerCategory FROM revenuePerCategory
ORDER BY revPerCategory;




-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q8. Each order with category total revenue
-- Approach:  - Join Order and Product table for category 
--			  - Window the value of revenue partitioned over category and ordered along with order_date column
WITH cateRevenue AS 
					(
					SELECT
						order_date,
						category,
						SUM(revenue) OVER (PARTITION BY category ORDER BY order_date) AS Revenue
					FROM orders AS o
					INNER JOIN products AS p
						ON o.product_id=p.product_id
					)
-- Main Query: 						
SELECT * FROM cateRevenue;




-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q9. Running total revenue (overall)
-- Approach: - Window the value of revenue ordered over order_date column and choosing rows between top and current
WITH runningTotal AS
					(
					SELECT 
						order_date,
						revenue,
						SUM(revenue) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS runnningRev
					FROM orders
					)
-- Main Query: 						
SELECT * FROM runningTotal;




-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q10. Running total revenue per category
-- Approach:  - Join Order and Product table for category 
--			  - Window the value of revenue partitioned over category and ordered along with order_date column 
--            - Choosing rows between top and current
WITH runningTotalPERCategory AS
								(
								SELECT
									order_date,
									category,
									revenue,
									SUM(revenue) OVER (PARTITION BY category ORDER BY order_date ROWS BETWEEN 
									UNBOUNDED PRECEDING AND CURRENT ROW) AS runningTotalonCAT
								FROM orders AS o
								INNER JOIN products AS p
									ON o.product_id = p.product_id
								)
-- Main Query: 
SELECT * FROM runningTotalPERCategory;




-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q11. Previous order revenue using LAG
-- Approach:   
WITH lagRevenue AS 
					(
					SELECT 
						order_date,
						revenue,
						LAG(revenue) OVER (ORDER BY order_date) AS lagRev
					FROM orders
					)
SELECT * FROM lagRevenue;



-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q12. Next order revenue using LEAD
-- Approach: 
SELECT
	order_date,
	revenue,
	LEAD(revenue) OVER (ORDER BY order_date) AS leadRev
FROM orders;



-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q7. Assign row number to orders per category
-- Approach: 
SELECT 
	order_id,
	order_date,
	category,
	ROW_NUMBER() OVER (PARTITION BY category ORDER BY order_date) AS rnOrdCate
FROM orders AS o
INNER JOIN products AS p
ON o.product_id = p.product_id;



-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q13. Rank products by total revenue
-- Extra INFO HERE!!
WITH Cte AS 
			(
			SELECT
				product_id,
				revenue,
				SUM(revenue) OVER (PARTITION BY product_id) AS totRev
			FROM orders
)
SELECT DISTINCT product_id,
	   totRev,
	   ROW_NUMBER() OVER (ORDER BY totRev DESC) AS rowRNK,
	   DENSE_RANK() OVER (ORDER BY totRev DESC) AS densRNK,
	   RANK() OVER (ORDER BY totRev DESC) AS RNK
FROM Cte
ORDER BY densRNK;



-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q14. First order and Recent date per product
WITH Cte AS 
			(
			SELECT
				product_id,
				MIN(order_date) OVER (PARTITION BY product_id) AS FirstOrder,
				MAX(order_date) OVER (PARTITION BY product_id) AS LatestOrder
			FROM orders
			)
SELECT DISTINCT product_id,
	   LatestOrder,
	   FirstOrder
	   --(LatestOrder - FirstOrder) AS buyingDays
FROM Cte
ORDER BY product_id;



-- ------------------------------------ ----------------------------------- -----------------------------------------------
-- Q15. FORM A QUESTION AND ANSWER IT - Ref:GPT










