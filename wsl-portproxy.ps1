param (
    [switch]$ResetOnly
)

$listenAddress = "0.0.0.0"
$fireWallDisplayName = "WSL Docker Inbound Dynamic"

Write-Host "`n🧹 Cleanup existing forwardings..." -ForegroundColor Yellow

$entries = netsh interface portproxy show v4tov4 2>&1 |
    Where-Object { $_ -match '^\s*(\d{1,3}\.){3}\d{1,3}\s+\d+\s+(\d{1,3}\.){3}\d{1,3}\s+\d+\s*$' } |
    ForEach-Object {
        $columns = ($_ -split '\s+')
        [PSCustomObject]@{
            ListenAddress = $columns[0]
            ListenPort    = $columns[1]
        }
    }

foreach ($match in $entries) {
    netsh interface portproxy delete v4tov4 listenport=$($match.ListenPort) listenaddress=$($match.ListenAddress) > $null
    Write-Host "❌ Entfernt: $($match.ListenAddress):$($match.ListenPort)" -ForegroundColor Cyan
}

if (Get-NetFirewallRule -DisplayName $fireWallDisplayName -ErrorAction SilentlyContinue) {
    Remove-NetFirewallRule -DisplayName $fireWallDisplayName
    Write-Host "🛡️ deleted firewall rule: $fireWallDisplayName" -ForegroundColor Cyan
}

if ($ResetOnly) {
    Write-Host "`n✅ reset done." -ForegroundColor Green
    exit
}

$wslAddress = (wsl hostname -I).Trim().Split(" ")[0]
if ($wslAddress -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
    Write-Host "❌ error: invalid wsl ip-address." -ForegroundColor Red
    exit
}

$dockerPortsRaw = wsl docker ps --format '{{.Ports}}'
$ports = @()

foreach ($entry in $dockerPortsRaw) {
    if ($entry -match ':(\d+)->') {
        $matches = [regex]::Matches($entry, ':(\d+)->')
        foreach ($match in $matches) {
            $ports += $match.Groups[1].Value
        }
    }
}

$ports = $ports | Sort-Object -Unique

if ($ports.Count -eq 0) {
    Write-Host "⚠️ no running containers with forwarded ports found." -ForegroundColor Yellow
    exit
}

Write-Host "`n🌐 wsl-ip: $wslAddress" -ForegroundColor Green
Write-Host "📡 ports: $($ports -join ', ')" -ForegroundColor Green

foreach ($port in $ports) {
    netsh interface portproxy add v4tov4 listenport=$port listenaddress=$listenAddress connectport=$port connectaddress=$wslAddress > $null
    Write-Host "🔁 add forwarding: ${listenAddress}:$port → ${wslAddress}:$port" -ForegroundColor Cyan
}

# Firewall-Regel hinzufügen
New-NetFirewallRule -DisplayName $fireWallDisplayName `
    -Direction Inbound `
    -LocalPort ($ports | ForEach-Object { [int]$_ }) `
    -Action Allow `
    -Protocol TCP | Out-Null

Write-Host "`n✅ forwardings + firewall rule successfully configured" -ForegroundColor Green
