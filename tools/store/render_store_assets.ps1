# Renders the Google Play store images from the HTML sources beside this script.
# Requires Google Chrome or Microsoft Edge. Outputs 24-bit PNGs into assets/store.
# Usage: powershell -ExecutionPolicy Bypass -File tools/store/render_store_assets.ps1
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Resolve-Path (Join-Path $here "..\..")
$out = Join-Path $root "assets\store"
New-Item -ItemType Directory -Force $out | Out-Null
$browser = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw "Chrome or Edge is required to render the store assets." }
$profile = Join-Path $env:TEMP "ashfall-store-render-profile"
function Render($html, $png, $w, $h) {
    $uri = "file:///" + ((Join-Path $here $html).Replace('\', '/'))
    $target = Join-Path $out $png
    $args = @("--headless=new", "--disable-gpu", "--hide-scrollbars", "--allow-file-access-from-files", "--no-first-run",
        "--user-data-dir=`"$profile`"", "--window-size=$w,$h", "--virtual-time-budget=4000",
        "--screenshot=`"$target`"", "`"$uri`"")
    # Start-Process avoids Windows PowerShell 5.1 turning Chrome's informational stderr into an error.
    Start-Process -FilePath $browser -ArgumentList $args -Wait -NoNewWindow
    if (-not (Test-Path $target)) { throw "Render failed: $png" }
    Write-Host "Rendered $png ($w x $h)"
}
Render "icon.html" "icon_512.png" 512 512
Render "feature_graphic.html" "feature_graphic_1024x500.png" 1024 500
