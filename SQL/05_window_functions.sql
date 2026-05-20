-- RFM (Recency, Frequency, Monetary) Analysis
-- RFM is the industry standard customer segmentation model
WITH rfm_base AS (
    SELECT
        customer_id,
        country,
        MAX(invoice_date::DATE)                 AS last_purchase_date,
        ('2011-12-31'::DATE -
            MAX(invoice_date::DATE))            AS recency_days,
        COUNT(DISTINCT invoice_no)              AS frequency,
        ROUND(SUM(revenue)::NUMERIC, 2)         AS monetary
    FROM transactions
    GROUP BY 
		customer_id, 
		country
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT *,
        recency_score + frequency_score + monetary_score AS rfm_total,
        CASE
            WHEN recency_score >= 4
             AND frequency_score >= 4 THEN 'Champions'
            WHEN recency_score >= 3
             AND frequency_score >= 3 THEN 'Loyal Customers'
            WHEN recency_score >= 4
             AND frequency_score <= 2 THEN 'Recent Customers'
            WHEN recency_score <= 2
             AND frequency_score >= 3 THEN 'At Risk'
            WHEN recency_score <= 2
             AND frequency_score <= 2 THEN 'Lost Customers'
            ELSE 'Potential Loyalists'
        END AS rfm_segment
    FROM rfm_scored
)
SELECT *,
    RANK() OVER (ORDER BY rfm_total DESC) AS rfm_rank
FROM rfm_segmented
ORDER BY rfm_rank;