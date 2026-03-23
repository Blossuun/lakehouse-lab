SELECT
    dt,
    view_events,
    add_to_cart_events,
    purchase_events,
    view_to_cart_rate,
    cart_to_purchase_rate,
    view_to_purchase_rate
FROM iceberg.gold.daily_conversion_metrics
ORDER BY dt;