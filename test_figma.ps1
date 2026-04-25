$token = $env:FIGMA_TOKEN  # set via environment variable, never hardcode
$headers = @{"X-Figma-Token" = $token}

# Try to get team info
try {
    $response = Invoke-RestMethod -Uri "https://api.figma.com/v1/teams" -Headers $headers
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Teams error: $_"
    Write-Host $_.Exception.Response
}