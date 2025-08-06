WITH customer_ltv AS (
	SELECT
		ca.customerkey,
		ca.full_name,
		SUM(ca.total_net_revenue) AS total_ltv
	FROM cohort_analysis ca 
	GROUP BY
		ca.customerkey,
		ca.full_name
), ltv_percentiles AS (
	SELECT
		PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_ltv) AS ltv_25th_percentile,
		PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_ltv) AS ltv_75th_percentile
	FROM
		customer_ltv
), customer_values AS (
	SELECT
		c.*,
		CASE
			WHEN c.total_ltv <= l.ltv_25th_percentile THEN '1 - Low-Value'
			WHEN c.total_ltv >= l.ltv_75th_percentile THEN '3 - High Value'
			ELSE '2 - Medium-Value'
		END AS customer_segment
	FROM customer_ltv c, ltv_percentiles l
)

SELECT 
	customer_segment,
	SUM(total_ltv),
	COUNT(*) AS customer_count,
	SUM(total_ltv) / COUNT(*) AS average_customer_value
FROM customer_values
GROUP BY
	customer_segment 





