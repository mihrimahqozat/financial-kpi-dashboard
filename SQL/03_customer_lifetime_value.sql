-- Customer lifetime value and segmentation
WITH customer_metrics AS (
    SELECT
        customer_id,
        country,
        COUNT(DISTINCT invoice_no)              AS total_orders,
        SUM(quantity)                           AS total_units,
        ROUND(SUM(revenue)::NUMERIC, 2)         AS total_revenue,
        ROUND(AVG(revenue)::NUMERIC, 2)         AS avg_order_value,
        MIN(invoice_date::DATE)                 AS first_purchase,
        MAX(invoice_date::DATE)                 AS last_purchase,
        MAX(invoice_date::DATE) -
            MIN(invoice_date::DATE)             AS customer_lifespan_days
    FROM transactions
    GROUP BY 
		customer_id, 
		country
),
clv_scored AS (
    SELECT *,
        CASE
            WHEN total_revenue >= 10000 THEN 'Platinum'
            WHEN total_revenue >= 5000  THEN 'Gold'
            WHEN total_revenue >= 1000  THEN 'Silver'
            ELSE 'Bronze'
        END                                     AS clv_tier,
        ROUND(total_revenue /
            NULLIF(customer_lifespan_days, 0)
            * 365::NUMERIC, 2)                  AS annual_clv
    FROM customer_metrics
)
SELECT *,
    RANK() OVER (ORDER BY total_revenue DESC)   AS revenue_rank,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile,
    ROUND(total_revenue * 100.0 /
        SUM(total_revenue) OVER (), 4)          AS pct_of_total_revenue
FROM clv_scored
ORDER BY total_revenue DESC;