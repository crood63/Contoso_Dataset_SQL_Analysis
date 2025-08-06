WITH customer_last_purchase AS (
	SELECT
		customerkey,
		full_name,
		orderdate,
		first_order_year, 
		ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS order_recency,
		first_order_date 
	FROM cohort_analysis ca 
), churned_customers AS (
	SELECT
		customerkey,
		full_name,
		first_order_year,
		orderdate AS last_order_date,
		first_order_date,
		CASE
			WHEN orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'
			ELSE 'Active'
		END AS customer_status
	FROM customer_last_purchase  
	WHERE
		order_recency = 1
		AND first_order_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)

SELECT
	first_order_year,
	customer_status,
	COUNT(*) AS num_customers,
	SUM(COUNT(*)) OVER(PARTITION BY first_order_year) AS total_customers,
	ROUND(COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY first_order_year) * 100, 2) AS customer_percentage
FROM churned_customers
GROUP BY
	first_order_year,
	customer_status
	