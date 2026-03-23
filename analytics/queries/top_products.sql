SELECT
    product_id,
    COUNT(*) AS purchase_count,
    SUM(total_amount) AS revenue
FROM iceberg.lakehouse.silver_events
WHERE event_type = 'purchase'
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10;