CREATE OR REPLACE VIEW cohort_analysis AS
WITH customer_revenue AS (
     SELECT s.customerkey,
        s.orderdate,
        sum(s.netprice * s.quantity::double precision * s.exchangerate) AS total_net_revenue,
        count(s.orderkey) AS order_count,
        c.countryfull,
        c.age,
        c.givenname,
        c.surname
       FROM sales s
         LEFT JOIN customer c ON s.customerkey = c.customerkey
      GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
    )
SELECT customerkey,
    orderdate,
    total_net_revenue,
    order_count,
    countryfull,
    age,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS first_order_year,
    (min(orderdate) OVER (PARTITION BY customerkey))::DATE AS first_order_date,
    CONCAT(TRIM(givenname), ' ', TRIM(surname)) AS full_name
FROM customer_revenue cr;





