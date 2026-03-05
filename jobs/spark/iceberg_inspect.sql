-- Iceberg metadata inspection
-- Table: local.lakehouse.silver_events

-- 1) Snapshots
SELECT
  snapshot_id,
  parent_id,
  committed_at,
  operation,
  summary
FROM local.lakehouse.silver_events.snapshots
ORDER BY committed_at DESC;

-- 2) History (snapshot lineage)
SELECT
  made_current_at,
  snapshot_id,
  parent_id,
  is_current_ancestor
FROM local.lakehouse.silver_events.history
ORDER BY made_current_at DESC;