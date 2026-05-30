# ============================================
# SRE Agent Demo - Error Injection Script
# ============================================

$appName = "sre-agent-demo-pierrer"
$resourceGroup = "rg-sre-agent-app"
$appUrl = "sre-agent-demo-pierrer.azurewebsites.net"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " SRE Agent Demo - Error Injection" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Step 1 - Enable error injection
Write-Host "`n[1/4] Enabling INJECT_ERROR..." -ForegroundColor Yellow
az webapp config appsettings set --% --name "sre-agent-demo-pierrer" --resource-group "rg-sre-agent-app" --settings "INJECT_ERROR=1" | Out-Null
Write-Host "✅ INJECT_ERROR=1 set" -ForegroundColor Green

# Step 2 - Wait for app to restart
Write-Host "`n[2/4] Waiting 15s for app to restart..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Step 3 - Generate normal traffic first
Write-Host "`n[3/4] Generating normal traffic (baseline)..." -ForegroundColor Yellow
1..10 | ForEach-Object {
  try {
    Invoke-WebRequest -Uri "https://$appUrl" -UseBasicParsing | Out-Null
    Write-Host "  Request $_ succeeded" -ForegroundColor Green
  } catch {
    Write-Host "  Request $_ failed: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
  }
  Start-Sleep -Milliseconds 500
}

# Step 4 - Trigger 500 errors (simulate 6 clicks on Refresh)
Write-Host "`n[4/4] Triggering HTTP 500 errors..." -ForegroundColor Yellow
1..20 | ForEach-Object {
  try {
    Invoke-WebRequest -Uri "https://$appUrl/counter/increment" -Method POST -UseBasicParsing | Out-Null
    Write-Host "  Request $_ succeeded" -ForegroundColor Green
  } catch {
    Write-Host "  Request $_ failed: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
  }
  Start-Sleep -Milliseconds 300
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host " Error injection complete!" -ForegroundColor Cyan
Write-Host " Wait 3 minutes then run the SRE Agent investigation." -ForegroundColor Cyan
Write-Host " Agent prompt:" -ForegroundColor Cyan
Write-Host " 'We are seeing HTTP 500 errors on sre-agent-demo-pierrer." -ForegroundColor White
Write-Host "  Users started reporting issues a few minutes ago." -ForegroundColor White
Write-Host "  Can you investigate the root cause?'" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan