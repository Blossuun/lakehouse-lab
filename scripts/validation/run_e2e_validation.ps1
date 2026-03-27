$ErrorActionPreference = "Stop"

Write-Host "INFO: Starting full system validation"

task raw
task silver
task iceberg
task iceberg:ops
task quality
task gold

powershell -ExecutionPolicy Bypass -File .\scripts\query\run_trino_query.ps1 -QueryFile .\analytics\queries\daily_business_overview.sql

$response = Invoke-RestMethod -Uri "http://localhost:8000/metrics/overview?date=2026-02-27"

if (-not $response) {
  Write-Host "FAIL: API check failed"
  exit 1
}

Write-Host "OK: full system validation passed"