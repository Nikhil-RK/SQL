-- 11.	Identify customers who purchased the same product more than 2 times.
-- [Ref: orders: customer_id, product_id, product_name, sales]
SELECT customer_id, prod_id, COUNT(*) AS purchaseCount
FROM orders
GROUP BY customer_id, prod_id
HAVING COUNT(*) > 2;


-- 12.	Calculate the percentage contribution of each category to overall revenue.
-- [Ref: products: category; orders: prod_id, saleprice]
WITH RevenueCalculations AS (
        SELECT  p.category, SUM(o.saleprice) AS CatRev
	FROM products AS p
	INNER JOIN orders AS o
	ON p.prod_id = o.prod_id
        GROUP BY p.category)

SELECT 	category, CatRev, SUM(CatRev) OVER () AS TotRev, 
        (CatRev *100.0/ SUM(CatRev) OVER ()) AS PercentContribution
FROM RevenueCalculations;


-- 13.	Write a query using ROW_NUMBER(), RANK(), and DENSE_RANK() to rank salary of each employee and 
-- compare how ties are handled. [Ref: orders: customer_id, saleprice]
WITH customertotal AS (
    SELECT  customer_id, 
            SUM(saleprice) AS total_spending
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id, total_spending,
       ROW_NUMBER() OVER (ORDER BY total_spending DESC) AS row_num,
       RANK() OVER (ORDER BY total_spending DESC) AS rank_num,
       DENSE_RANK() OVER (ORDER BY total_spending DESC) AS dense_rank_num
FROM customertotal;


-- 14.	Write a query to identify the latest order placed by each customer 
-- [Ref: orders: customer_id, order_date]
SELECT customer_id, order_date
FROM (
SELECT customer_id, order_date, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS row_num
FROM orders)
WHERE row_num = 1;


-- 15.	Write a query to calculate cumulative sales and cumulative average sales for each customer over time.
-- [Ref: orders: customer_id, order_date, saleprice]
SELECT	customer_id, order_date,
        SUM(saleprice) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumSales,
        AVG(saleprice) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS AvgCumSales	
FROM orders
ORDER BY customer_id, order_date;


-- 16. Using the events table, calculate (DAU), (WAU) and (MAU)
-- [Ref: events: user_id, event_date]
SELECT  DATE_TRUNC('day', event_date) AS Daily, 
        COUNT(*) AS DAU
FROM events
GROUP BY DATE_TRUNC('day', event_date)
ORDER BY Daily;

SELECT  DATE_TRUNC('Week', event_date) AS Weekly, 
        COUNT(*) AS WAU
FROM events
GROUP BY DATE_TRUNC('Week', event_date)
ORDER BY Weekly;

SELECT  DATE_TRUNC('Month', event_date) AS Monthly, 
        COUNT(*) AS MAU
FROM events
GROUP BY DATE_TRUNC('Month', event_date)
ORDER BY Monthly;


-- 17. Using the events table, identify users with consecutive daily, consecutive weekly, and monthly activity.
-- [Ref: events: user_id, event_date]
WITH userActivity AS ( 
    SELECT DISTINCT user_id, 
                    DATE(event_date) AS event_date, 
                    LAG(DATE(event_date)) OVER (PARTITION BY user_id ORDER BY DATE(event_date)) AS prev_event 
    FROM events ) 
SELECT user_id, event_date, prev_event 
FROM userActivity 
WHERE event_date = prev_event + INTERVAL '1 day'

ORDER BY user_id;

WITH userActivity AS ( 
    SELECT DISTINCT user_id, 
                    DATE_TRUNC('week', event_date) AS event_week, 
                    LAG(DATE_TRUNC('week', event_date)) OVER (PARTITION BY user_id ORDER BY DATE_TRUNC('week', event_date) ) AS prev_event 
    FROM events ) 
SELECT user_id, event_week, prev_event 
FROM userActivity 
WHERE event_week = prev_event + INTERVAL '1 week'
ORDER BY user_id;

WITH userActivity AS ( 
    SELECT DISTINCT user_id, 
                    DATE_TRUNC('month', event_date) AS event_month, 
                    LAG(DATE_TRUNC('month', event_date)) OVER (PARTITION BY user_id ORDER BY DATE_TRUNC('month', event_date) ) AS prev_event 
    FROM events ) 
SELECT user_id, event_month, prev_event 
FROM userActivity 
WHERE event_month = prev_event + INTERVAL '1 month'
ORDER BY user_id;


-- 18.	Calculate the average gap between consecutive events for each user.
-- [Ref: events: user_id, event_date]
WITH eventGap AS (
    SELECT user_id, event_date, 
           LAG(event_date) OVER (PARTITION BY user_id  ORDER BY event_date ) AS prevEvent
    FROM events)

SELECT	user_id, ROUND(AVG(event_date - prevEvent), 2) AS avgGap 
FROM eventGap
WHERE prevEvent IS NOT NULL 
GROUP BY user_id; 


-- 19. Calculate the duration between a user’s first activity and first purchase.
-- [Ref: events: user_id, event_date, orders: customer_id, order_date]
WITH firstActivity AS (                                        
        SELECT 	user_id, MIN(event_date) AS firstActivityDate                   
        FROM events
        GROUP BY user_id),

firstPurchase AS (
        SELECT 	customer_id AS user_id, MIN(order_date) AS firstPurchaseDate                  
        FROM orders
        GROUP BY customer_id)

SELECT 	fa.user_id, firstActivityDate,  firstPurchaseDate,                                         
               	(firstPurchaseDate - firstActivityDate) AS daysToPurchase    
FROM firstActivity AS fa
INNER JOIN firstPurchase AS fp
ON fa.user_id = fp.user_id;


-- 20.	Using the events table, perform new versus returning user analysis for each month.
-- [events: user_id, event_date]
WITH firstVisit AS (
    SELECT 	user_id, 
            DATE_TRUNC('month', MIN(event_date)) AS firstMonth 
    FROM events 
    GROUP BY user_id)

SELECT 	DATE_TRUNC('month', e.event_date) AS activityMonth, 
        COUNT(DISTINCT CASE WHEN DATE_TRUNC('month', e.event_date) = f.firstMonth THEN e.user_id END) AS NewUsers,
        COUNT(DISTINCT CASE WHEN DATE_TRUNC('month', e.event_date) > f.firstMonth THEN e.user_id END) AS ReturningUsers
FROM events AS e 
INNER JOIN firstVisit AS f 
ON e.user_id = f.user_id
GROUP BY DATE_TRUNC('month', e.event_date) ;


