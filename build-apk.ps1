#!/usr/bin/env pwsh
# =============================================================================
# Athirai APK Release Builder
# Usage: .\build-apk.ps1
#
# - Reads current version from pubspec.yaml
# - Auto-increments the build number (+1 each run)
# - Builds a release APK
# - Renames it to: athirai-version-0.<buildNumber>.apk
# - Saves it to: releases/
# =============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Paths
$ROOT        = $PSScriptRoot
$FRONTEND    = Join-Path $ROOT "frontend"
$PUBSPEC     = Join-Path $FRONTEND "pubspec.yaml"
$RELEASES    = Join-Path $ROOT "releases"

# Read lines from pubspec.yaml
$lines       = Get-Content $PUBSPEC
$versionLine = $lines | Where-Object { $_ -match "^version:\s+[\d]" } | Select-Object -First 1

if (-not $versionLine) {
    Write-Error "Could not find 'version:' line in pubspec.yaml"
    exit 1
}

# Parse "version: 1.0.0+3"
if ($versionLine -match "version:\s+([\d\.]+)\+(\d+)") {
    $versionName  = $Matches[1]
    $buildNumber  = [int]$Matches[2]
} else {
    Write-Error "Version line format unexpected: '$versionLine'"
    exit 1
}

# Increment build number
$newBuildNumber  = $buildNumber + 1
$newVersionLine  = "version: $versionName+$newBuildNumber"
$apkName         = "athirai-version-0.$newBuildNumber.apk"

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  ATHIRAI APK Release Builder" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  Version name  : $versionName" -ForegroundColor White
Write-Host "  Old build no  : $buildNumber" -ForegroundColor Yellow
Write-Host "  New build no  : $newBuildNumber" -ForegroundColor Green
Write-Host "  APK name      : $apkName" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# [1/4] Update pubspec.yaml - replace just the version line
Write-Host "[1/4] Updating pubspec.yaml..." -ForegroundColor Cyan
$updatedLines = $lines | ForEach-Object {
    if ($_ -match "^version:\s+[\d]") { $newVersionLine } else { $_ }
}
Set-Content -Path $PUBSPEC -Value $updatedLines
Write-Host "      Updated => $newVersionLine" -ForegroundColor Green

# [2/4] flutter pub get
Write-Host ""
Write-Host "[2/4] Running flutter pub get..." -ForegroundColor Cyan
Push-Location $FRONTEND
try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }
} finally {
    Pop-Location
}

# [3/4] Build release APK
Write-Host ""
Write-Host "[3/4] Building release APK..." -ForegroundColor Cyan
Push-Location $FRONTEND
try {
    flutter build apk --release "--build-name=$versionName" "--build-number=$newBuildNumber"
    if ($LASTEXITCODE -ne 0) { throw "flutter build apk failed" }
} finally {
    Pop-Location
}

# [4/4] Copy & rename to releases/
Write-Host ""
Write-Host "[4/4] Copying APK to releases/..." -ForegroundColor Cyan

$builtApk    = Join-Path $FRONTEND "build\app\outputs\flutter-apk\app-release.apk"
$destination = Join-Path $RELEASES $apkName

if (-not (Test-Path $RELEASES)) {
    New-Item -ItemType Directory -Path $RELEASES | Out-Null
}

if (-not (Test-Path $builtApk)) {
    Write-Error "Built APK not found at: $builtApk"
    exit 1
}

Copy-Item -Path $builtApk -Destination $destination -Force

$sizeMB = [math]::Round((Get-Item $destination).Length / 1MB, 2)

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "  BUILD SUCCESSFUL" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host "  APK  : $apkName" -ForegroundColor White
Write-Host "  Size : $sizeMB MB" -ForegroundColor White
Write-Host "  Path : $destination" -ForegroundColor White
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""
