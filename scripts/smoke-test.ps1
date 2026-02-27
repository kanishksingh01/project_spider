Param(
  [string]$ComposeFile = "docker-compose.yml"
)

$ErrorActionPreference = "Stop"

docker info | Out-Null
if ($LASTEXITCODE -ne 0) {
  throw "Docker daemon is not reachable. Start Docker Desktop (or Docker Engine) and retry."
}

function Wait-ForEndpoint {
  Param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [int]$TimeoutSeconds = 60
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    try {
      $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 2
      if ($response.StatusCode -eq 200) {
        return $response
      }
    } catch {
      Start-Sleep -Seconds 2
    }
  }

  throw "Timed out waiting for endpoint: $Url"
}

docker compose -f $ComposeFile up --build -d
if ($LASTEXITCODE -ne 0) {
  throw "docker compose up failed."
}

try {
  $health = Wait-ForEndpoint -Url "http://localhost:8080/healthz" -TimeoutSeconds 90
  Write-Host "Health endpoint OK ($($health.StatusCode))"

  $root = Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing -TimeoutSec 5
  Write-Host "Root endpoint OK ($($root.StatusCode))"
  Write-Host $root.Content
} finally {
  docker compose -f $ComposeFile down --remove-orphans
}
