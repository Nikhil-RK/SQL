/* 
Question 1: Daily Driver Utilization by City
For each city and date:
1. total active drivers
2. drivers who completed ≥1 trip
3. utilization rate
Context: Uber’s operations team wants to measure how efficiently drivers are being used. 
A driver is considered utilized if they complete at least one trip in a day. 
This helps identify supply-demand imbalance. 
*/

WITH driver_Utilization AS (
    SELECT
        CAST(t.pickup_time AS DATE) AS date,                  -- trip date
        d.city_id,                                             -- city dimension
        COUNT(DISTINCT CASE WHEN d.is_active = TRUE 
              THEN d.driver_id END) AS total_active_drivers,  -- active drivers
        COUNT(CASE WHEN t.trip_status = 'completed' 
              THEN d.driver_id END) AS utilized_drivers       -- drivers completing trips
    FROM trips t
    INNER JOIN drivers d 
        ON t.driver_id = d.driver_id                          -- join driver metadata
    GROUP BY CAST(t.pickup_time AS DATE), d.city_id           -- aggregate per day + city
)
SELECT *,
       ROUND(utilized_drivers::numeric / 
             total_active_drivers::numeric, 3) AS utilization_rate -- utilization %
FROM driver_Utilization;





---------------------------------------------------------------------------------------------------------------------------------------
/* 
Question 2: Ride Request → Completion Funnel

Context: The growth analytics team wants to understand funnel drop-offs between ride requests 
and completed trips to improve marketplace reliability.

For each city and week:
1. total ride requests
2. requests with a driver assigned
3. completed trips
4. conversion rate = completed / total requests
*/

WITH countRequested AS (
    SELECT
        city_id,                                              -- city dimension
        DATE_TRUNC('week', request_time) AS week_start,       -- weekly bucket
        COUNT(*) AS total_requests,                           -- total ride requests
        COUNT(assigned_driver_id) AS assigned_requests        -- assigned requests
    FROM ride_requests
    GROUP BY city_id, DATE_TRUNC('week', request_time)
),
countCompleted AS (
    SELECT
        r.city_id,                                            -- city dimension
        DATE_TRUNC('week', request_time) AS week_start,       -- weekly bucket
        COUNT(*) AS completed_trips                           -- completed trips
    FROM trips t
    INNER JOIN ride_requests r 
        ON t.request_id = r.request_id                        -- link request to trip
    WHERE t.trip_status = 'completed'                         -- only completed trips
    GROUP BY r.city_id, DATE_TRUNC('week', request_time)
)
SELECT
    cr.week_start,
    cr.city_id,
    cr.total_requests,
    cr.assigned_requests,
    COALESCE(cc.completed_trips, 0) AS completed_trips,       -- handle missing values
    ROUND(1.0 * COALESCE(cc.completed_trips, 0) /
          cr.total_requests, 3) AS conversion_rate            -- funnel conversion %
FROM countRequested cr
LEFT JOIN countCompleted cc
    ON cr.city_id = cc.city_id
   AND cr.week_start = cc.week_start                          -- align weekly metrics
ORDER BY cr.week_start, cr.city_id;







-----------------------------------------------------------------------------------------------------------------
/* 
Question 3: Impact of Surge Pricing on Revenue

Context:
The pricing team wants to evaluate whether surge pricing improves revenue efficiency or hurts rider behavior.

Group completed trips into surge buckets:
1. No surge (≤1.0)
2. Moderate (1.1–1.5)
3. High (>1.5)
For each bucket compute: average fare per km and total completed trips
*/


WITH surgeBucket AS (
    SELECT
        t.trip_id,                                            -- trip identifier
        t.final_fare,                                         -- trip fare
        r.surge_multiplier,                                   -- surge value
        CASE
            WHEN r.surge_multiplier <= 1.5 THEN 'No Surge'
            WHEN r.surge_multiplier <= 2.0 THEN 'Moderate'
            ELSE 'High'
        END AS surge_bucket                                   -- surge category
    FROM trips t
    LEFT JOIN ride_requests r 
        ON t.request_id = r.request_id                        -- attach request data
    WHERE t.trip_status = 'completed'                         -- completed trips only
)
SELECT
    surge_bucket,
    COUNT(*) AS trip_count,                                   -- number of trips
    SUM(final_fare) AS total_revenue,                         -- total revenue
    ROUND(AVG(final_fare), 2) AS avg_revenue_per_trip         -- avg fare per trip
FROM surgeBucket
GROUP BY surge_bucket
ORDER BY surge_bucket;







-----------------------------------------------------------------------------------------------------------------
/* 
Question 4: Top Riders by Monthly Spend. 
For each month and city, return the top 5 riders by total spend from completed trips.
Context:
Uber’s loyalty team wants to identify high-value riders for premium incentives and retention campaigns.
*/

WITH totalspending AS (
    SELECT
        DATE_TRUNC('month', t.pickup_time) AS month,          -- monthly bucket
        r.city_id,                                            -- city dimension
        r.rider_id,                                           -- rider identifier
        SUM(t.final_fare) AS total_spend                      -- rider monthly spend
    FROM riders r
    INNER JOIN trips t 
        ON r.rider_id = t.rider_id                            -- join trip history
    GROUP BY DATE_TRUNC('month', t.pickup_time),
             r.city_id,
             r.rider_id
),
ranked AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY month, city_id
               ORDER BY total_spend DESC
           ) AS spend_rank                                   -- rank riders by spend
    FROM totalspending
)
SELECT *
FROM ranked
WHERE spend_rank <= 3                                        -- top riders per segment
ORDER BY month, city_id, spend_rank;







-----------------------------------------------------------------------------------------------------------------
/* 
Question 5: Driver Performance Ranking
For each city, rank drivers by:
1. total completed trips
2. average fare per trip
Return the top 3 drivers per city.
Context:
Marketplace quality monitoring wants to 
rank drivers based on efficiency to identify top performers and underperformer
*/

WITH avgtotalperdriver AS (
    SELECT
        driver_id,                                           -- driver identifier
        COUNT(*) AS total_trips,                             -- completed trip count
        AVG(final_fare) AS avg_fare                          -- average fare
    FROM trips
    WHERE trip_status = 'completed'                          -- filter completed trips
    GROUP BY driver_id
),
ranked AS (
    SELECT
        d.city_id,                                           -- driver city
        a.driver_id,
        a.total_trips,
        a.avg_fare,
        DENSE_RANK() OVER (
            PARTITION BY d.city_id
            ORDER BY total_trips DESC, avg_fare DESC
        ) AS rnk                                             -- performance rank
    FROM avgtotalperdriver a
    INNER JOIN drivers d 
        ON a.driver_id = d.driver_id
)
SELECT *
FROM ranked
WHERE rnk <= 5;                                              -- top 5 drivers per city








-----------------------------------------------------------------------------------------------------------------
/* 
Question 6: Cancellation Behavior by ETA
Write a query to bucket ride requests by ETA ranges (0–5, 6–10, 11–15, 16+) and
calculate the cancellation rate for each bucket by city.

Context:
Operations suspects long ETAs increase rider cancellations and wants evidence.
*/

WITH cancellation_bucket AS (
    SELECT
        request_id,                                         -- request identifier
        city_id,                                            -- city dimension
        CASE
            WHEN estimated_eta_minutes BETWEEN 0 AND 5  THEN '0-5'
            WHEN estimated_eta_minutes BETWEEN 6 AND 10 THEN '6-10'
            WHEN estimated_eta_minutes BETWEEN 11 AND 15 THEN '11-15'
            ELSE '16+'
        END AS eta_bucket,                                  -- ETA bucket
        request_status                                      -- request outcome
    FROM ride_requests
),
calc AS (
    SELECT
        city_id,
        eta_bucket,
        COUNT(*) AS total_requests,                         -- total bucket requests
        COUNT(CASE WHEN request_status = 'cancelled' 
              THEN 1 END) AS cancelled_requests            -- cancelled requests
    FROM cancellation_bucket
    GROUP BY city_id, eta_bucket
)
SELECT
    city_id,
    eta_bucket,
    total_requests,
    cancelled_requests,
    cancelled_requests::numeric / total_requests AS cancellation_rate -- cancel %
FROM calc
ORDER BY city_id, eta_bucket;







-----------------------------------------------------------------------------------------------------------------
/* 
Question 7: First Trip Revenue Cohort
Write a query to compute total revenue generated 
in the first 30 days after signup for each rider cohort grouped by signup month.
Context:
Finance wants to understand revenue generated from new rider cohorts after signup.
*/

WITH riderCo AS (
    SELECT
        rider_id,                                          -- rider identifier
        signup_date,                                       -- signup timestamp
        DATE_TRUNC('month', signup_date) AS signup_month   -- cohort month
    FROM riders
),
revenue30D AS (
    SELECT
        r.rider_id,
        r.signup_month,
        SUM(t.final_fare) AS rev30                         -- revenue within 30 days
    FROM riderCo r
    LEFT JOIN trips t
        ON r.rider_id = t.rider_id
       AND t.trip_status = 'completed'
       AND t.pickup_time >= r.signup_date
       AND t.pickup_time <  r.signup_date + INTERVAL '30 days' -- 30-day window
    GROUP BY r.signup_month, r.rider_id
)
SELECT
    signup_month,
    COUNT(DISTINCT rider_id) AS cohort_size,              -- riders in cohort
    COALESCE(SUM(rev30), 0) AS revenue_30d                -- total cohort revenue
FROM revenue30D
GROUP BY signup_month
ORDER BY signup_month;







-----------------------------------------------------------------------------------------------------------------
/* 
Question 8: Driver Idle Time Analysis
Write a query to calculate the average idle time between consecutive
completed trips per driver and return the city-level average idle time.
Context:
Marketplace efficiency teams want to reduce driver idle time between trips.
*/

WITH Base AS (
    SELECT
        t.driver_id,                                      -- driver identifier
        d.city_id,                                        -- driver city
        LAG(t.dropoff_time) OVER (
            PARTITION BY t.driver_id
            ORDER BY t.pickup_time
        ) AS last_drop,                                   -- previous trip end
        t.pickup_time
    FROM trips t
    INNER JOIN drivers d 
        ON t.driver_id = d.driver_id
    WHERE t.trip_status = 'completed'                     -- completed trips only
),
idleCalc AS (
    SELECT
        city_id,
        EXTRACT(EPOCH FROM (pickup_time - last_drop)) 
        / 60 AS idle_minutes                              -- gap between trips
    FROM Base
    WHERE last_drop IS NOT NULL                           -- ignore first trip
)
SELECT
    city_id,
    AVG(idle_minutes) AS avg_idle_minutes                 -- city-level idle avg
FROM idleCalc
GROUP BY city_id
ORDER BY city_id;







-----------------------------------------------------------------------------------------------------------------
/* 
Question 9: Surge vs Completion Rate
Write a query to compare completion rates across surge multiplier buckets (≤1.0, 1.1–1.5, >1.5) for each city.
Context:
Pricing wants to validate whether high surge reduces trip completion probability.
*/

WITH Base AS (
    SELECT
        r.city_id,                                        -- city dimension
        CASE
            WHEN surge_multiplier <= 1.0 THEN '≤1.0'
            WHEN surge_multiplier BETWEEN 1.1 AND 1.5 THEN '1.1-1.5'
            ELSE '>1.5'
        END AS surge_bucket,                              -- surge bucket
        COUNT(*) AS total_requests,                       -- total requests
        SUM(CASE WHEN t.trip_status = 'completed' 
            THEN 1 ELSE 0 END) AS completed_trips        -- completed trips
    FROM ride_requests r
    LEFT JOIN trips t 
        ON r.request_id = t.request_id
    GROUP BY r.city_id, surge_bucket
)
SELECT
    city_id,
    surge_bucket,
    total_requests,
    completed_trips,
    completed_trips::numeric / total_requests AS completion_rate -- completion %
FROM Base
ORDER BY city_id, surge_bucket;






-----------------------------------------------------------------------------------------------------------------
/* 
Question 10: First vs Latest Trip Comparison
Write a query to return each rider’s first trip distance and latest trip distance 
and calculate the percentage change between them.
Context:
Product wants to understand how rider behavior changes between their first and most recent trip.
*/

WITH BASE AS (
    SELECT
        rider_id,
        FIRST_VALUE(trip_distance_km) OVER (
            PARTITION BY rider_id
            ORDER BY pickup_time
        ) AS first_distance,
        FIRST_VALUE(trip_distance_km) OVER (
            PARTITION BY rider_id
            ORDER BY pickup_time DESC
        ) AS latest_distance
    FROM trips
    WHERE trip_status = 'completed'
)

SELECT DISTINCT
    rider_id,
    first_distance,
    latest_distance,
    (latest_distance - first_distance)::numeric
        / NULLIF(first_distance, 0) AS percent_change
FROM BASE;




-----------------------------------------------------------------------------------------------------------------
/* 
Question 11: Consecutive Trip Streaks
Write a query to find the longest streak of consecutive days each rider completed at least one trip.
Context:
Retention analytics wants to identify riders with strong usage streaks.
*/

WITH Base AS (
	SELECT 
		rider_id,
		DATE(pickup_time) AS trip_date
	FROM trips
	WHERE trip_status = 'completed' 
),
streak AS (
	SELECT rider_id, trip_date,
		   trip_date - INTERVAL '1 Day' * ROW_NUMBER() OVER (PARTITION BY rider_id ORDER BY trip_date) AS grp
	FROM Base
),
streakLength AS (
	    SELECT
        rider_id,
        COUNT(*) AS streak_days
    FROM streak
    GROUP BY rider_id, grp
)
SELECT rider_id,
	MAX(streak_days) AS longestStreak
FROM streakLength
GROUP BY rider_id
ORDER BY longestStreak DESC;




-----------------------------------------------------------------------------------------------------------------
/* 
Question 12: Driver Peak Hour Contribution
Write a query to calculate what percentage of each driver’s total 
earnings comes from trips taken between 6pm–10pm.
Context:
Operations wants to measure how much driver earnings depend on peak hours.
*/

WITH totalRev AS (
	SELECT driver_id, SUM(final_fare) AS totRev
	FROM Trips
	WHERE trip_status = 'completed'
	GROUP BY driver_id
),
timedRev AS (
	SELECT driver_id, SUM(final_fare) AS timeRev
	FROM Trips
	WHERE trip_status = 'completed' AND pickup_time::time BETWEEN TIME '18:00:00' AND TIME '22:00:00'
	GROUP BY driver_id
)
SELECT DISTINCT t.driver_id, totRev, timeRev,
	(timeRev/totRev) AS peak_hour_earnings_pct
FROM totalRev AS r
INNER JOIN timedRev AS t
ON r.driver_id = t.driver_id
GROUP BY t.driver_id, totRev, timeRev
ORDER BY t.driver_id






-----------------------------------------------------------------------------------------------------------------
/* 
Question 13: Driver Trip Time Efficiency
Write a query to compute average minutes per km for 
each driver and return drivers above the city 90th percentile.
Context:
Marketplace wants to identify drivers with unusually long trip durations relative to distance.
*/

WITH CALC AS (
	SELECT t.driver_id, d.city_id,
		AVG(t.trip_duration_minutes * 1.0 / NULLIF(t.trip_distance_km, 0))
            AS avg_minutes_per_km
	FROM trips AS t
	INNER JOIN drivers AS d
	ON t.driver_id = d.driver_id
	WHERE t.trip_status = 'completed'
	GROUP BY d.city_id, t.driver_id
),
Percentile90 AS (
	SELECT driver_id, city_id ,avg_minutes_per_km,
		NTILE(10) OVER (PARTITION BY city_id ORDER BY avg_minutes_per_km DESC) AS decile
	FROM CALC
)
SELECT driver_id, avg_minutes_per_km
FROM Percentile90
WHERE decile = 1
ORDER BY avg_minutes_per_km DESC;
