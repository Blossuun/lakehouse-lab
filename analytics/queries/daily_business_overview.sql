SELECT
    e.dt,
    e.total_events,
    e.purchase_events,
    e.refund_events,
    r.gross_revenue,
    r.refund_amount,
    r.net_revenue
FROM iceberg.gold.daily_event_metrics e
JOIN iceberg.gold.daily_revenue_metrics r
    ON e.dt = r.dt
ORDER BY e.dt;