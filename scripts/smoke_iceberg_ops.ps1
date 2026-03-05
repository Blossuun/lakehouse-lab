param(
  [string]$Date = "2026-02-27"
)

$ICEBERG_VERSION = "1.6.0"

# Detect Hadoop version from Spark container jars (best-effort)
$hadoopCommonJar = docker exec lab-spark bash -lc "ls /opt/spark/jars | grep -E '^hadoop-common-[0-9]+\.[0-9]+\.[0-9]+\.jar$' | head -n 1"
if (-not $hadoopCommonJar) {
  Write-Host "FAIL: could not detect hadoop-common jar version in container"
  exit 2
}

$match = [regex]::Match($hadoopCommonJar, 'hadoop-common-([0-9]+\.[0-9]+\.[0-9]+)\.jar')
if (-not $match.Success) {
  Write-Host "FAIL: could not parse hadoop version from: $hadoopCommonJar"
  exit 3
}
$HADOOP_AWS_VERSION = $match.Groups[1].Value

Write-Host "INFO: Detected Hadoop version = $HADOOP_AWS_VERSION"

$PACKAGES = @(
  "org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:$ICEBERG_VERSION",
  "org.apache.hadoop:hadoop-aws:$HADOOP_AWS_VERSION"
) -join ","

function Run-SparkSubmit($argsArray) {
  $cmd = @(
    "/opt/spark/bin/spark-submit",
    "--conf", "spark.jars.ivy=/tmp/ivy",
    "--packages", $PACKAGES
  ) + $argsArray

  docker exec -it lab-spark bash -lc ($cmd -join " ")
  return $LASTEXITCODE
}

Write-Host "INFO: 1) Inspect snapshots/history"
$rc = Run-SparkSubmit @("/opt/lab/jobs/spark/iceberg_inspect.py")
if ($rc -ne 0) { Write-Host "FAIL: inspect job failed"; exit 10 }

Write-Host "INFO: 2) Schema evolution (add column + verify)"
$rc = Run-SparkSubmit @("/opt/lab/jobs/spark/iceberg_schema_evolution.py", "--date", $Date)
if ($rc -ne 0) { Write-Host "FAIL: schema evolution failed"; exit 11 }

Write-Host "INFO: 3) Time travel demo"
$rc = Run-SparkSubmit @("/opt/lab/jobs/spark/iceberg_time_travel.py", "--date", $Date)
if ($rc -ne 0) { Write-Host "FAIL: time travel failed"; exit 12 }

Write-Host "OK: smoke_iceberg_ops completed"
exit 0