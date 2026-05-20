-- Monthly and quarterly revenue with growth rates
WITH monthly_revenue AS (
    SELECT
        year,
        month,
        quarter,
        COUNT(DISTINCT invoice_no)              AS total_orders,
        COUNT(DISTINCT customer_id)             AS unique_customers,
        ROUND(SUM(revenue)::NUMERIC, 2)         AS total_revenue,
        ROUND(AVG(revenue)::NUMERIC, 2)         AS avg_order_value,
        SUM(quantity)                           AS total_units_sold
    FROM transactions
    GROUP BY 
		year, 
		month, 
		quarter
),
revenue_with_growth AS (
    SELECT *,
        LAG(total_revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
        ROUND((total_revenue - LAG(total_revenue)
            OVER (ORDER BY year, month)) * 100.0
            / NULLIF(LAG(total_revenue)
            OVER (ORDER BY year, month), 0) ::NUMERIC, 2) AS mom_growth_pct
    FROM monthly_revenue
)
SELECT *
FROM revenue_with_growth
ORDER BY 
	year, 
	month;