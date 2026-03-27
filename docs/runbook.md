# Runbook

## 1. Start infra

task infra:up

## 2. Run pipeline

task raw
task silver
task iceberg
task quality
task gold

## 3. Run query

powershell -ExecutionPolicy Bypass -File .\scripts\query\run_trino_query.ps1 -QueryFile .\analytics\queries\daily_business_overview.sql

## 4. Run dashboard

powershell -ExecutionPolicy Bypass -File .\scripts\dashboard\run_analysis_dashboard.ps1

## 5. Run API

powershell -ExecutionPolicy Bypass -File .\scripts\api\run_api_server.ps1

## 6. Full validation

task validate:all