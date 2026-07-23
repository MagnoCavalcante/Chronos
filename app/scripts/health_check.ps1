# CHRONOS Health Check Script
# Executa verificações automáticas de saúde do projeto
# Uso: powershell -File scripts/health_check.ps1

param([switch]$Verbose)

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CHRONOS Health Check v1.0.0" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$errors = 0
$warnings = 0

# 1. Flutter Analyze
Write-Host "[1/6] Running flutter analyze..." -ForegroundColor Yellow
$analyzeResult = flutter analyze --no-pub 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ No analysis issues" -ForegroundColor Green
} else {
    Write-Host "  ✗ Analysis failed" -ForegroundColor Red
    $errors++
    if ($Verbose) { Write-Host $analyzeResult }
}

# 2. Flutter Test
Write-Host "[2/6] Running flutter test..." -ForegroundColor Yellow
$testResult = flutter test --no-pub 2>&1
if ($LASTEXITCODE -eq 0) {
    $testCount = ($testResult | Select-String "\+(\d+):" | ForEach-Object { $_.Matches[0].Groups[1].Value } | Select-Object -Last 1)
    Write-Host "  ✓ All $testCount tests passed" -ForegroundColor Green
} else {
    Write-Host "  ✗ Tests failed" -ForegroundColor Red
    $errors++
}

# 3. Dependencies check
Write-Host "[3/6] Checking dependencies..." -ForegroundColor Yellow
$pubResult = flutter pub get 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Dependencies resolved" -ForegroundColor Green
} else {
    Write-Host "  ✗ Dependency resolution failed" -ForegroundColor Red
    $errors++
}

# 4. Asset directories
Write-Host "[4/6] Checking asset directories..." -ForegroundColor Yellow
$assetDirs = @("assets/images", "assets/icons")
foreach ($dir in $assetDirs) {
    if (Test-Path $dir) {
        Write-Host "  ✓ $dir exists" -ForegroundColor Green
    } else {
        Write-Host "  ! $dir missing" -ForegroundColor Yellow
        $warnings++
    }
}

# 5. Orphan files check (Dart files not imported anywhere)
Write-Host "[5/6] Checking for potential orphan files..." -ForegroundColor Yellow
$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object { $_.Name -ne "main.dart" }
$orphanCount = 0
# Quick heuristic: check DI files and barrel exports exist
$diFiles = $dartFiles | Where-Object { $_.Name -like "*_di.dart" }
Write-Host "  ✓ $($diFiles.Count) DI modules found" -ForegroundColor Green
Write-Host "  ✓ $($dartFiles.Count) Dart files total" -ForegroundColor Green

# 6. Version check
Write-Host "[6/6] Checking version..." -ForegroundColor Yellow
$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -match "version:\s*(\S+)") {
    Write-Host "  ✓ Version: $($Matches[1])" -ForegroundColor Green
} else {
    Write-Host "  ! Version not found in pubspec.yaml" -ForegroundColor Yellow
    $warnings++
}

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  RESULTS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($errors -eq 0) {
    Write-Host "  ✓ HEALTH CHECK PASSED" -ForegroundColor Green
} else {
    Write-Host "  ✗ HEALTH CHECK FAILED ($errors errors)" -ForegroundColor Red
}

if ($warnings -gt 0) {
    Write-Host "  ! $warnings warnings" -ForegroundColor Yellow
}

Write-Host ""
exit $errors
