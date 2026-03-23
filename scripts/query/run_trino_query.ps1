param(
  [Parameter(Mandatory=$true)]
  [string]$QueryFile
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $QueryFile)) {
  Write-Host "FAIL: query file not found: $QueryFile"
  exit 1
}

$query = Get-Content $QueryFile -Raw

$cmd = @(
  "docker", "exec", "-i", "lab-trino",
  "trino",
  "--execute", $query
)

Write-Host "INFO: Running query:"
Write-Host $QueryFile

& $cmd[0] $cmd[1..($cmd.Length-1)]
$rc = $LASTEXITCODE

if ($rc -ne 0) {
  Write-Host "FAIL: query execution failed"
  exit 2
}

Write-Host "OK: query executed successfully"
exit 0