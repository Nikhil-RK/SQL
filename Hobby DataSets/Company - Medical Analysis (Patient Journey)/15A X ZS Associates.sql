/*------------------------------------------------------------*/
-- Question 1: Top 3 patients by claim cost within each region
/*------------------------------------------------------------*/

WITH patient_cost AS (
    SELECT p.region,
           c.patient_id,
           SUM(c.cost) AS total_cost,
           DENSE_RANK() OVER (
               PARTITION BY p.region
               ORDER BY SUM(c.cost) DESC
           ) AS rnk
    FROM patients p
    JOIN claims c
      ON p.patient_id = c.patient_id
    GROUP BY p.region, c.patient_id
)

SELECT *
FROM patient_cost
WHERE rnk <= 3;


/*------------------------------------------------------------*/
-- Question 2: Month-over-month revenue growth
/*------------------------------------------------------------*/

WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', service_date) AS month,
           SUM(cost) AS revenue
    FROM claims
    GROUP BY month
)

SELECT month,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
       ROUND(
           ((revenue - LAG(revenue) OVER (ORDER BY month))
            * 100.0 /
            LAG(revenue) OVER (ORDER BY month)),2
       ) AS mom_growth_pct
FROM monthly_revenue;


/*------------------------------------------------------------*/
-- Question 3: Patients with continuously increasing claims
/*------------------------------------------------------------*/

WITH ordered_claims AS (
    SELECT patient_id,
           service_date,
           cost,
           LAG(cost,1) OVER(PARTITION BY patient_id ORDER BY service_date) AS prev1,
           LAG(cost,2) OVER(PARTITION BY patient_id ORDER BY service_date) AS prev2
    FROM claims
)

SELECT DISTINCT patient_id
FROM ordered_claims
WHERE cost > prev1
  AND prev1 > prev2;


/*------------------------------------------------------------*/
-- Question 4: Second most prescribed drug in each region
/*------------------------------------------------------------*/

WITH drug_rank AS (
    SELECT p.region,
           t.drug_name,
           COUNT(*) AS drug_count,
           DENSE_RANK() OVER(
               PARTITION BY p.region
               ORDER BY COUNT(*) DESC
           ) AS rnk
    FROM patients p
    JOIN treatments t
      ON p.patient_id = t.patient_id
    GROUP BY p.region, t.drug_name
)

SELECT *
FROM drug_rank
WHERE rnk = 2;


/*------------------------------------------------------------*/
-- Question 5: Rolling 3-month average claim cost
/*------------------------------------------------------------*/

WITH monthly_cost AS (
    SELECT DATE_TRUNC('month', service_date) AS month,
           SUM(cost) AS total_cost
    FROM claims
    GROUP BY month
)

SELECT month,
       total_cost,
       AVG(total_cost) OVER(
           ORDER BY month
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS rolling_avg
FROM monthly_cost;


/*------------------------------------------------------------*/
-- Question 6: Providers above overall average
/*------------------------------------------------------------*/

WITH provider_avg AS (
    SELECT v.provider_id,
           AVG(c.cost) AS provider_avg_cost
    FROM visits v
    JOIN claims c
      ON v.patient_id = c.patient_id
    GROUP BY v.provider_id
)

SELECT *
FROM provider_avg
WHERE provider_avg_cost >
(
    SELECT AVG(cost)
    FROM claims
);


/*------------------------------------------------------------*/
-- Question 7: Patient retention month-over-month
/*------------------------------------------------------------*/

WITH monthly_users AS (
    SELECT DISTINCT
           patient_id,
           DATE_TRUNC('month', visit_date) AS month
    FROM visits
),

retention AS (
    SELECT curr.month,
           COUNT(DISTINCT curr.patient_id) AS retained_users
    FROM monthly_users curr
    JOIN monthly_users prev
      ON curr.patient_id = prev.patient_id
     AND curr.month = prev.month + INTERVAL '1 month'
    GROUP BY curr.month
)

SELECT *
FROM retention;


/*------------------------------------------------------------*/
-- Question 8: Detect duplicate claims within 7 days
/*------------------------------------------------------------*/

WITH ordered_claims AS (
    SELECT patient_id,
           service_date,
           cost,
           LAG(service_date) OVER(
               PARTITION BY patient_id, cost
               ORDER BY service_date
           ) AS prev_date
    FROM claims
)

SELECT *
FROM ordered_claims
WHERE service_date - prev_date <= 7;


/*------------------------------------------------------------*/
-- Question 9: Adherence drop detection
/*------------------------------------------------------------*/

WITH adherence_data AS (
    SELECT patient_id,
           month,
           adherence_rate,
           LAG(adherence_rate) OVER(
               PARTITION BY patient_id
               ORDER BY month
           ) AS prev_rate
    FROM adherence
)

SELECT *
FROM adherence_data
WHERE adherence_rate < prev_rate;


/*------------------------------------------------------------*/
-- Question 10: Quartile segmentation
/*------------------------------------------------------------*/

WITH patient_cost AS (
    SELECT patient_id,
           SUM(cost) AS total_cost
    FROM claims
    GROUP BY patient_id
)

SELECT *,
       NTILE(4) OVER(ORDER BY total_cost DESC) AS quartile
FROM patient_cost;


/*------------------------------------------------------------*/
-- Question 11: Pareto analysis
/*------------------------------------------------------------*/

WITH provider_revenue AS (
    SELECT v.provider_id,
           SUM(c.cost) AS revenue
    FROM visits v
    JOIN claims c
      ON v.patient_id = c.patient_id
    GROUP BY v.provider_id
),

pareto AS (
    SELECT *,
           SUM(revenue) OVER(ORDER BY revenue DESC) AS cumulative_revenue,
           SUM(revenue) OVER() AS total_revenue
    FROM provider_revenue
)

SELECT *
FROM pareto
WHERE cumulative_revenue <= total_revenue * 0.8;


/*------------------------------------------------------------*/
-- Question 12: Patient funnel analysis
/*------------------------------------------------------------*/

SELECT
    COUNT(DISTINCT p.patient_id) AS registered,
    COUNT(DISTINCT v.patient_id) AS visited,
    COUNT(DISTINCT t.patient_id) AS treated,
    COUNT(DISTINCT c.patient_id) AS claimed
FROM patients p
LEFT JOIN visits v
       ON p.patient_id = v.patient_id
LEFT JOIN treatments t
       ON p.patient_id = t.patient_id
LEFT JOIN claims c
       ON p.patient_id = c.patient_id;


/*------------------------------------------------------------*/
-- Question 13: Longest consecutive visit streak
/*------------------------------------------------------------*/

WITH visit_groups AS (
    SELECT patient_id,
           visit_date,
           visit_date - INTERVAL '1 day' *
           ROW_NUMBER() OVER(
               PARTITION BY patient_id
               ORDER BY visit_date
           ) AS grp
    FROM visits
)

SELECT patient_id,
       COUNT(*) AS streak
FROM visit_groups
GROUP BY patient_id, grp
ORDER BY streak DESC;


/*------------------------------------------------------------*/
-- Question 14: Increasing treatment duration trend
/*------------------------------------------------------------*/

WITH monthly_duration AS (
    SELECT DATE_TRUNC('month', start_date) AS month,
           p.region,
           AVG(end_date - start_date) AS avg_duration
    FROM treatments t
    JOIN patients p
      ON t.patient_id = p.patient_id
    GROUP BY month, p.region
)

SELECT *,
       LAG(avg_duration) OVER(
           PARTITION BY region
           ORDER BY month
       ) AS prev_duration
FROM monthly_duration;


/*------------------------------------------------------------*/
-- Question 15: High-risk patients
/*------------------------------------------------------------*/

WITH patient_metrics AS (
    SELECT p.patient_id,
           SUM(c.cost) AS total_cost,
           AVG(a.days_taken * 1.0 / a.days_supply) AS adherence_rate,
           COUNT(v.visit_id) AS visit_count
    FROM patients p
    LEFT JOIN claims c
           ON p.patient_id = c.patient_id
    LEFT JOIN adherence a
           ON p.patient_id = a.patient_id
    LEFT JOIN visits v
           ON p.patient_id = v.patient_id
    GROUP BY p.patient_id
)

SELECT *
FROM patient_metrics
ORDER BY total_cost DESC,
         adherence_rate ASC,
         visit_count DESC
LIMIT 5;