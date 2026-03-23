param(
  [Parameter(Mandatory=$true)]
  [string]$QueryFile
)

$ErrorActionPreference = "Stop"

$TrinoContainer = "lab-trino"
$ContainerQueryPath = "/tmp/trino_query.sql"

if (!(Test-Path $QueryFile)) {
  Write-Host "FAIL: query file not found: $QueryFile"
  exit 1
}

$running = docker ps --format "{{.Names}}" | Select-String -Pattern "^$TrinoContainer$" -Quiet
if (-not $running) {
  Write-Host "FAIL: Trino container is not running: $TrinoContainer"
  exit 3
}

Write-Host "INFO: Running query file:"
Write-Host $QueryFile
Write-Host "INFO: Target container:"
Write-Host $TrinoContainer

# Copy query file into container to avoid PowerShell/native stdin encoding issues.
$copyCmd = @("docker", "cp", $QueryFile, "${TrinoContainer}:${ContainerQueryPath}")
Write-Host "INFO: Copying query into container"
Write-Host ("  " + ($copyCmd -join " "))
& $copyCmd[0] $copyCmd[1..($copyCmd.Length-1)] | Out-Host
$copyRc = $LASTEXITCODE

if ($copyRc -ne 0) {
  Write-Host "FAIL: could not copy query file into container (container=$TrinoContainer, exit=$copyRc)"
  exit 4
}

$execCmd = @(
  "docker", "exec", "-i", $TrinoContainer,
  "trino",
  "--file", $ContainerQueryPath
)

Write-Host "INFO: Executing query via Trino --file"
Write-Host ("  " + ($execCmd -join " "))
& $execCmd[0] $execCmd[1..($execCmd.Length-1)] | Out-Host
$rc = $LASTEXITCODE

if ($rc -ne 0) {
  Write-Host "FAIL: query execution failed (container=$TrinoContainer, exit=$rc)"
  exit 2
}

Write-Host "OK: query executed successfully"
exit 0