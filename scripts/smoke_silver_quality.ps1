param(
  [string]$Date = "2026-02-27"
)

$ErrorActionPreference = "Stop"

$ICEBERG_VERSION = "1.6.0"
$HADOOP_AWS_VERSION = "3.3.4"

Write-Host "INFO: Using pinned versions ICEBERG=$ICEBERG_VERSION, HADOOP_AWS=$HADOOP_AWS_VERSION"

$PACKAGES = "org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:$ICEBERG_VERSION,org.apache.hadoop:hadoop-aws:$HADOOP_AWS_VERSION"

$ReportOut = "s3a://datalake/audit/quality_checks/dt=$Date"

$cmd = @(
  "docker", "exec", "-it", "lab-spark",
  "/opt/spark/bin/spark-submit",
  "--conf", "spark.jars.ivy=/tmp/.ivy2",
  "--packages", $PACKAGES,
  "/opt/lab/jobs/spark/check_silver_quality.py",
  "--date", $Date,
  "--report-out", $ReportOut
)

Write-Host "INFO: Running quality gate"
Write-Host ("  " + ($cmd -join " "))

& $cmd[0] $cmd[1..($cmd.Length-1)]
$rc = $LASTEXITCODE

if ($rc -ne 0) {
  Write-Host "FAIL: silver quality gate failed (exit=$rc)"
  exit 10
}

Write-Host "OK: silver quality gate passed"
Write-Host "INFO: report written to $ReportOut"
exit 0