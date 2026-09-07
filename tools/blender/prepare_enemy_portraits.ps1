param(
    [string]$Godot = 'C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe',
    [switch]$Install
)
$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$sourceRoot = Join-Path $projectRoot 'art_sources/blender'
$manifestPath = Join-Path $sourceRoot 'manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$portraitRoot = Join-Path $sourceRoot 'portraits'
New-Item -ItemType Directory -Path $portraitRoot -Force | Out-Null

# Normalize every render before changing any runtime asset.
foreach ($entry in $manifest.PSObject.Properties) {
    $enemyId = $entry.Name
    if ($enemyId -notmatch '^enemy_[a-z]+$') { throw "Unsafe asset ID: $enemyId" }
    $sourcePath = Join-Path $sourceRoot $entry.Value.render
    $outputPath = Join-Path $portraitRoot ($enemyId + '.png')
    & $Godot --headless --path $projectRoot --script res://tools/blender/normalize_portrait.gd -- $sourcePath $outputPath
    if ($LASTEXITCODE -ne 0) { throw "Normalization failed: $enemyId" }
}
if (-not $Install) { return }

$runtimeRoot = Join-Path $projectRoot 'assets/portraits'
$backupRoot = Join-Path $sourceRoot 'previous_runtime'
$receiptPath = Join-Path $sourceRoot 'installation.json'
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$receipt = @{}
if (Test-Path -LiteralPath $receiptPath) {
    $existingReceipt = Get-Content -LiteralPath $receiptPath -Raw | ConvertFrom-Json
    foreach ($entry in $existingReceipt.PSObject.Properties) { $receipt[$entry.Name] = $entry.Value }
}
# Preflight the entire set. Never silently replace artwork edited after our install.
foreach ($entry in $manifest.PSObject.Properties) {
    $enemyId = $entry.Name
    $targetPath = Join-Path $runtimeRoot ($enemyId + '.png')
    if ($receipt.ContainsKey($enemyId) -and (Test-Path -LiteralPath $targetPath)) {
        if ((Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash -ne $receipt[$enemyId].installed_sha256) {
            throw "Runtime portrait changed since the last Blender install: $enemyId. Preserve that edit before reinstalling."
        }
    }
}
foreach ($entry in $manifest.PSObject.Properties) {
    $enemyId = $entry.Name
    $targetPath = Join-Path $runtimeRoot ($enemyId + '.png')
    $preparedPath = Join-Path $portraitRoot ($enemyId + '.png')
    if (-not $receipt.ContainsKey($enemyId)) {
        $hadOriginal = Test-Path -LiteralPath $targetPath
        if ($hadOriginal) {
            Copy-Item -LiteralPath $targetPath -Destination (Join-Path $backupRoot ($enemyId + '.png'))
        }
        $receipt[$enemyId] = [pscustomobject]@{
            had_original = $hadOriginal
            original_sha256 = $(if ($hadOriginal) { (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash } else { $null })
            installed_sha256 = ''
        }
    }
    Copy-Item -LiteralPath $preparedPath -Destination $targetPath -Force
    $receipt[$enemyId].installed_sha256 = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash
    # Persist after each file so an interrupted install still has a usable receipt.
    $receipt | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $receiptPath -Encoding UTF8
    Write-Output "Installed $enemyId; original preserved where present."
}
