-- 21. Perform cohort analysis and calculate customer retention rates over time based on customers' 
-- first purchase month. [Ref: orders: customer_id, order_date]
WITH customerCohort AS (                                        
    SELECT	customer_id,                                            
            DATE_TRUNC('month', MIN(order_date)) AS cohortMonth     
    FROM orders                                                 
    GROUP BY customer_id)

SELECT 	c.cohortMonth,
DATE_TRUNC('month', o.order_date) AS activityMonth,         
COUNT(DISTINCT o.customer_id) AS retainedCustomers          
FROM orders AS o
INNER JOIN customerCohort AS c
ON o.customer_id = c.customer_id
GROUP BY c.cohortMonth, DATE_TRUNC('month', o.order_date)
ORDER BY cohortMonth, activityMonth;



-- 22. Using the transactions table, reconstruct the latest purchase quantity and amount for each customer-product 
-- combination. [Ref: transactions: customer_id, prod_id, quantity, amount, transaction_date]
WITH latestPurchase AS (                                     	
    SELECT	customer_id, prod_id, quantity, amount, transaction_date,                                       
            ROW_NUMBER() OVER (PARTITION BY customer_id, prod_id ORDER BY transaction_date DESC) AS latestPurc
    FROM transactions)
SELECT	customer_id, prod_id, quantity, amount, transaction_date                                            
FROM latestPurchase
WHERE latestPurc = 1;                                           



-- 23.	Determine peak activity hours, days, weeks, or months using the events or orders table. 
-- [Ref: events/orders: event_date/order_date]
WITH activitySummary AS (
    SELECT	EXTRACT(HOUR FROM event_date) AS activityHour,
            COUNT(*) AS activityCount
    FROM events
    GROUP BY EXTRACT(HOUR FROM event_date))

SELECT 	activityHour, activityCount
FROM activitySummary
ORDER BY activityCount DESC
LIMIT 1;



-- 24.	Identify products whose monthly revenue increased continuously over the last N months. 
-- [Ref: orders: prod_id, order_date, sales]
WITH currentMonthRev AS (
    SELECT  prod_id, 
            DATE_TRUNC('month', order_date) AS mnt, 
            SUM(saleprice) AS monthlyRevenue 
    FROM orders 
    GROUP BY prod_id, DATE_TRUNC('month', order_date)),

prevMonthRev AS (
    SELECT	prod_id,  mnt, monthlyRevenue, 
            LAG(monthlyRevenue) OVER (PARTITION BY prod_id ORDER BY mnt) AS prevRevenue
    FROM currentMonthRev)

SELECT  prod_id, mnt, monthlyRevenue, prevRevenue
FROM prevMonthRev
GROUP BY prod_id
HAVING COUNT(*) = COUNT(CASE WHEN monthlyRevenue > prevRevenue OR prevRevenue IS NULL THEN 1 END);



-- 25.	Write a query to calculate Month-over-Month (MoM) and Year-over-Year (YoY) growth. 
-- [Ref: orders: prod_id, order_date, sales]




-- 26.	Identify the top-performing entities based on growth rate. 
-- [Ref: orders: prod_id, order_date, sales]




-- 27. Gap & Island Pattern (Longest Consecutive Login Streak): How many consecutive days a user continuously 
-- logged in? [Ref: events: user_id, event_date]
WITH loginSequence AS (
    SELECT DISTINCT
            user_id, event_date, 
            event_date - ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_date) * INTERVAL '1 day' AS grp
    FROM events)

SELECT	user_id, COUNT(*) AS consecutiveDays 
FROM loginSequence
GROUP BY user_id, grp
HAVING COUNT(*) > 2
ORDER BY user_id, consecutiveDays DESC;

-- 28.	Write a query to calculate the customer retention rate between two consecutive months. [Ref: orders: customer_id, order_date]











