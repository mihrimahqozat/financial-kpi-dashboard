-- Top products by revenue, volume and margin proxy
WITH product_stats AS (
    SELECT
        stock_code,
        description,
        COUNT(DISTINCT invoice_no)              AS total_orders,
        SUM(quantity)                           AS total_units_sold,
        ROUND(AVG(unit_price)::NUMERIC, 2)      AS avg_unit_price,
        ROUND(SUM(revenue)::NUMERIC, 2)         AS total_revenue,
        COUNT(DISTINCT customer_id)             AS unique_customers
    FROM transactions
    WHERE description IS NOT NULL
    GROUP BY 
		stock_code,
		description
    HAVING SUM(quantity) > 100
)
SELECT *,
    RANK() OVER (ORDER BY total_revenue DESC)   AS revenue_rank,
    RANK() OVER (ORDER BY total_units_sold DESC) AS volume_rank,
    ROUND(total_revenue * 100.0 /
        SUM(total_revenue) OVER (), 4)          AS pct_of_total_revenue,
    ROUND(SUM(total_revenue) OVER (
        ORDER BY total_revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW) * 100.0 /
        SUM(total_revenue) OVER (), 2)          AS cumulative_revenue_pct
FROM product_stats
ORDER BY revenue_rank
LIMIT 50;