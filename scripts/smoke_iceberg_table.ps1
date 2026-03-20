param(
  [string]$Date = "2026-02-27"
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot/lib/spark_smoke_common.ps1"

Write-SparkSmokeVersions
Initialize-SparkIvyCache

$rc = Invoke-SparkSubmit @(
  "/opt/lab/jobs/spark/silver_to_iceberg.py",
  "--date", $Date
)

if ($rc -ne 0) {
  Write-Host "FAIL: spark-submit failed (exit=$rc)"
  exit 2
}

Write-Host "OK: smoke_iceberg_table completed"
exit 0