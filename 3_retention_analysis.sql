WITH customer_last_purchase AS (
	SELECT
		customerkey,
		full_name,
		orderdate,
		ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS order_recency,
		first_order_date 
	FROM cohort_analysis ca 
)

SELECT
	customerkey,
	full_name,
	orderdate,
	first_order_date
FROM customer_last_purchase  
WHERE
	order_recency = 1
	