# ============================================================================
# Script: Build Android Release AAB for TrekVN App
# Usage: .\scripts\build-release.ps1
# ============================================================================

Write-Host "🚀 TrekVN - Android Release Builder" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# Check Flutter installation
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter not found"
    }
    Write-Host "✅ Flutter detected" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR: Flutter not found!" -ForegroundColor Red
    Write-Host "   Please install Flutter first: https://flutter.dev/docs/get-started/install`n" -ForegroundColor Yellow
    exit 1
}

# Check if key.properties exists
$keyPropertiesPath = "..\android\key.properties"
if (-not (Test-Path $keyPropertiesPath)) {
    Write-Host "⚠️  WARNING: key.properties not found!" -ForegroundColor Yellow
    Write-Host "   The app will be signed with debug keys." -ForegroundColor Yellow
    Write-Host "   For production release, run: .\scripts\generate-keystore.ps1`n" -ForegroundColor Yellow
    
    $continue = Read-Host "Continue with debug signing? (yes/no)"
    if ($continue -ne "yes") {
        Write-Host "❌ Build cancelled." -ForegroundColor Red
        exit 0
    }
}

# Read current version from pubspec.yaml
Write-Host "📋 Reading version from pubspec.yaml..." -ForegroundColor Cyan
$pubspecPath = "..\pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw
if ($pubspecContent -match 'version:\s*(\S+)') {
    $currentVersion = $matches[1]
    Write-Host "   Current version: $currentVersion`n" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Could not read version from pubspec.yaml" -ForegroundColor Yellow
    $currentVersion = "unknown"
}

# Build options
Write-Host "🎯 Build Options:" -ForegroundColor Cyan
Write-Host "   1. Build AAB (Android App Bundle) - For Google Play Store" -ForegroundColor Gray
Write-Host "   2. Build APK - For direct installation" -ForegroundColor Gray
Write-Host "   3. Build both AAB and APK`n" -ForegroundColor Gray

$buildOption = Read-Host "Select option (1-3)"

# Clean build
Write-Host "`n🧹 Cleaning previous build..." -ForegroundColor Cyan
Set-Location ..
flutter clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Cyan
flutter pub get

# Build based on selection
$success = $false

switch ($buildOption) {
    "1" {
        Write-Host "`n🔨 Building Android App Bundle (AAB)..." -ForegroundColor Green
        flutter build appbundle --release
        if ($LASTEXITCODE -eq 0) {
            $aabPath = "build\app\outputs\bundle\release\app-release.aab"
            if (Test-Path $aabPath) {
                $aabSize = (Get-Item $aabPath).Length / 1MB
                Write-Host "`n✅ AAB built successfully!" -ForegroundColor Green
                Write-Host "   Location: $aabPath" -ForegroundColor Gray
                Write-Host "   Size: $([math]::Round($aabSize, 2)) MB`n" -ForegroundColor Gray
                $success = $true
            }
        }
    }
    "2" {
        Write-Host "`n🔨 Building APK..." -ForegroundColor Green
        flutter build apk --release
        if ($LASTEXITCODE -eq 0) {
            $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
            if (Test-Path $apkPath) {
                $apkSize = (Get-Item $apkPath).Length / 1MB
                Write-Host "`n✅ APK built successfully!" -ForegroundColor Green
                Write-Host "   Location: $apkPath" -ForegroundColor Gray
                Write-Host "   Size: $([math]::Round($apkSize, 2)) MB`n" -ForegroundColor Gray
                $success = $true
            }
        }
    }
    "3" {
        Write-Host "`n🔨 Building APK..." -ForegroundColor Green
        flutter build apk --release
        $apkSuccess = ($LASTEXITCODE -eq 0)
        
        Write-Host "`n🔨 Building Android App Bundle (AAB)..." -ForegroundColor Green
        flutter build appbundle --release
        $aabSuccess = ($LASTEXITCODE -eq 0)
        
        if ($apkSuccess -and $aabSuccess) {
            Write-Host "`n✅ Both builds completed successfully!" -ForegroundColor Green
            
            $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
            $aabPath = "build\app\outputs\bundle\release\app-release.aab"
            
            if (Test-Path $apkPath) {
                $apkSize = (Get-Item $apkPath).Length / 1MB
                Write-Host "   APK: $apkPath ($([math]::Round($apkSize, 2)) MB)" -ForegroundColor Gray
            }
            
            if (Test-Path $aabPath) {
                $aabSize = (Get-Item $aabPath).Length / 1MB
                Write-Host "   AAB: $aabPath ($([math]::Round($aabSize, 2)) MB)`n" -ForegroundColor Gray
            }
            
            $success = $true
        }
    }
    default {
        Write-Host "❌ Invalid option selected" -ForegroundColor Red
        exit 1
    }
}

if ($success) {
    Write-Host "📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Test the APK on a real device" -ForegroundColor Gray
    Write-Host "   2. Upload AAB to Google Play Console" -ForegroundColor Gray
    Write-Host "   3. Complete Store Listing if first time" -ForegroundColor Gray
    Write-Host "   4. Submit for review`n" -ForegroundColor Gray
    
    # Open output folder option
    $openFolder = Read-Host "Open output folder? (yes/no)"
    if ($openFolder -eq "yes") {
        if ($buildOption -eq "1" -or $buildOption -eq "3") {
            explorer "build\app\outputs\bundle\release"
        } else {
            explorer "build\app\outputs\flutter-apk"
        }
    }
} else {
    Write-Host "`n❌ Build failed! Check the error messages above." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Done!`n" -ForegroundColor Green
