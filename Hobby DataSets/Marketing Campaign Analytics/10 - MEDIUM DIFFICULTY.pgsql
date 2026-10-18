/*1. Calculate conversion rate by marketing channel
Formula Hint: Conversion Rate = (Total Conversions / Total Clicks) × 100
Columns:
    campaigns: campaign_id, channel
    events: campaign_id, clicks, conversions*/
SELECT c.channel,    
    SUM(e.clicks) AS total_clicks,
    SUM(e.conversions) AS total_conversions,
    ROUND(SUM(e.conversions) * 100.0 / NULLIF(SUM(e.clicks), 0), 2) AS conversion_rate
FROM events AS e
JOIN campaigns AS c 
ON e.campaign_id = c.campaign_id
GROUP BY c.channel;




/*2. Find the campaign with the highest ROI
Formula Hint: ROI = ((Total Revenue - Total Spend) / Total Spend) × 100
Columns:
    campaigns: campaign_id, campaign_name
    events: campaign_id, revenue, spend */
SELECT c.campaign_id, c.campaign_name,
    SUM(e.spend) AS total_spend,
    SUM(e.revenue) AS total_revenue,
    ROUND(((SUM(e.revenue) - SUM(e.spend)) / NULLIF(SUM(e.spend), 0)) * 100, 2) AS ROI
FROM events AS e
JOIN campaigns AS c 
ON e.campaign_id = c.campaign_id
GROUP BY c.campaign_id, c.campaign_name;





/*3. Identify customers who clicked but didn't purchase
Columns: events - customer_id, clicks, conversions*/
SELECT
    customer_id
FROM public.events
WHERE clicks > 0
  AND conversions = 0;





/*4. Calculate monthly customer retention rate
Formula Hint: Retention Rate = (Customers active in both current and previous month
                        /Customers active in previous month) × 100
Columns:
    events: event_date, customer_id*/
WITH monthly_activity AS (
    SELECT DISTINCT customer_id,
        DATE_TRUNC('month', event_date) AS mnt
    FROM public.events),

customer_history AS (
    SELECT customer_id, mnt,
        LAG(mnt) OVER (PARTITION BY customer_id ORDER BY mnt) AS previous_month
    FROM monthly_activity),

monthly_metrics AS (
    SELECT mnt, COUNT(*) AS active_customers,
        COUNT(CASE WHEN previous_month = mnt - INTERVAL '1 month' THEN customer_id END) AS retained_customers
    FROM customer_history
    GROUP BY mnt)

SELECT mnt, active_customers, retained_customers,
    ROUND(retained_customers * 100.0 / LAG(active_customers) OVER (ORDER BY mnt),2) AS retention_rate
FROM monthly_metrics
ORDER BY mnt;





/*5. Find repeat customers
Formula Hint: A repeat customer has conversions/purchases in more than one event.
Condition Hint: Count of conversion events per customer > 1
Columns:
    events: customer_id, event_id, conversions*/
SELECT
    customer_id
FROM public.events
WHERE conversions > 0
GROUP BY customer_id
HAVING COUNT(DISTINCT event_id) > 1;





/*6. Rank campaigns by total revenue
Columns:
    campaigns: campaign_id, campaign_name
    events: campaign_id, revenue*/
WITH revenue AS (
SELECT c.campaign_id, c.campaign_name, SUM(e.revenue) AS total_revenue
FROM campaigns AS c 
INNER JOIN events AS e 
ON c.campaign_id = e.campaign_id
GROUP BY c.campaign_id, c.campaign_name)

SELECT campaign_id, campaign_name, total_revenue,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS rnk
FROM revenue
ORDER BY rnk;





/*7. Calculate the 7-day rolling conversion rate
Columns:
    events: event_date, clicks, conversions*/

WITH conversionRate AS (
    SELECT event_date, 
        SUM(clicks) AS total_clicks, 
        SUM(conversions) AS total_conversions,
        ROUND(SUM(conversions) * 100.0 / NULLIF(SUM(clicks), 0), 2) AS conversion_rate
    FROM events
GROUP BY event_date)

SELECT 
    event_date, total_clicks, total_conversions, conversion_rate,
    SUM(conversion_rate) OVER (ORDER BY event_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_conversion_rate
FROM conversionRate;






/*8. Compare this month's campaign performance with last month
Columns:
    campaigns: campaign_id, campaign_name
    events: campaign_id, event_date, revenue, conversions*/

WITH monthly_performance AS (
    SELECT  c.campaign_id, c.campaign_name,
            DATE_TRUNC('month', e.event_date) AS event_month,
            SUM(e.revenue) AS total_revenue,
            SUM(e.conversions) AS total_conversions
    FROM campaigns AS c
    JOIN events AS e
        ON c.campaign_id = e.campaign_id
    WHERE e.event_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
        AND e.event_date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
    GROUP BY c.campaign_id, c.campaign_name, DATE_TRUNC('month', e.event_date)),

comparison AS (
    SELECT  campaign_id, campaign_name, event_month, total_revenue,total_conversions,
            LAG(total_revenue) OVER (PARTITION BY campaign_id ORDER BY event_month) AS prev_month_revenue,
            LAG(total_conversions) OVER (PARTITION BY campaign_id ORDER BY event_month) AS prev_month_conversions
    FROM monthly_performance)

SELECT
    campaign_id, campaign_name, event_month, total_revenue, total_conversions, prev_month_revenue, prev_month_conversions,
    ROUND((total_revenue - prev_month_revenue) * 100.0 / NULLIF(prev_month_revenue, 0),2) AS revenue_change_percentage,
    ROUND((total_conversions - prev_month_conversions) * 100.0 / NULLIF(prev_month_conversions, 0),2) AS conversions_change_percentage
FROM comparison
WHERE event_month = DATE_TRUNC('month', CURRENT_DATE)
ORDER BY campaign_id;






/*9. Identify the channel with the highest conversion rate and highest total revenue
Formula Hint: Conversion Rate = (Total Conversions / Total Clicks) × 100
             Total Revenue = SUM(Revenue)
Approach Hint: Calculate metrics for each channel → Compare/rank channels.
Columns:
    campaigns: campaign_id, channel
    events: campaign_id, clicks, conversions, revenue*/
WITH channel_metrics AS (
    SELECT 
        c.channel,    
        SUM(e.clicks) AS total_clicks,
        SUM(e.conversions) AS total_conversions,
        ROUND(SUM(e.conversions) * 100.0 / NULLIF(SUM(e.clicks), 0), 2) AS conversion_rate,
        SUM(e.revenue) AS total_revenue
    FROM events AS e
    JOIN campaigns AS c
    ON c.campaign_id = e.campaign_id
    GROUP BY c.channel),

ranking AS (
SELECT channel, total_clicks, total_conversions, conversion_rate, total_revenue,
    DENSE_RANK() OVER (ORDER BY conversion_rate DESC) AS conversion_rate_rank,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS total_revenue_rank
FROM channel_metrics)

SELECT *
FROM ranking
WHERE conversion_rate_rank = 1 OR total_revenue_rank = 1
ORDER BY conversion_rate_rank, total_revenue_rank;