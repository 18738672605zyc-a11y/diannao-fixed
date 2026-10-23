# Bring up Tailscale and get IP
$tsExe = "$env:ProgramFiles\Tailscale\tailscale.exe"

# Wait for Tailscale service to finish starting after MSI install
Write-Host "Waiting for Tailscale service to initialize..."
Start-Sleep -Seconds 10

$tsIP = $null
$retries = 0
$maxRetries = 15

while (-not $tsIP -and $retries -lt $maxRetries) {
  Write-Host "Tailscale connection attempt $($retries+1)/$maxRetries"
  # Retry tailscale up in case service isn't ready on first run
  & $tsExe up --authkey=$env:TAILSCALE_AUTH_KEY --hostname=gh-runner-$env:GITHUB_RUN_ID 2>&1 | Write-Host
  Start-Sleep -Seconds 5
  $tsIP = & $tsExe ip -4 2>$null
  $retries++
}

if (-not $tsIP) { 
  Write-Host "=== Tailscale debug status on failure ==="
  & $tsExe status 2>&1 | Write-Host
  throw "Tailscale IP not assigned after $maxRetries attempts. Please verify your TAILSCALE_AUTH_KEY secret is valid and not expired." 
}

echo "TAILSCALE_IP=$tsIP" >> $env:GITHUB_ENV
Write-Host "Successfully connected to Tailscale, IPv4 address: $tsIP"
