# ============================================================================
# Script: Check if TrekVN App is ready for release
# Usage: .\scripts\check-release-ready.ps1
# ============================================================================

Write-Host "🔍 TrekVN - Release Readiness Checker" -ForegroundColor Cyan
Write-Host "======================================`n" -ForegroundColor Cyan

$issues = @()
$warnings = @()

# Check 1: Keystore exists
Write-Host "1️⃣  Checking keystore configuration..." -ForegroundColor Cyan
$keystorePath = "..\android\app\trekvn-upload-keystore.jks"
$keyPropertiesPath = "..\android\key.properties"

if (Test-Path $keystorePath) {
    Write-Host "   ✅ Keystore file found" -ForegroundColor Green
} else {
    $issues += "Keystore file not found at: $keystorePath"
    Write-Host "   ❌ Keystore file not found" -ForegroundColor Red
}

if (Test-Path $keyPropertiesPath) {
    Write-Host "   ✅ key.properties file found" -ForegroundColor Green
    
    # Validate key.properties content
    $keyProps = Get-Content $keyPropertiesPath -Raw
    if ($keyProps -match "YOUR_.*_PASSWORD") {
        $issues += "key.properties contains placeholder passwords"
        Write-Host "   ❌ key.properties has placeholder values" -ForegroundColor Red
    }
} else {
    $issues += "key.properties file not found"
    Write-Host "   ❌ key.properties file not found" -ForegroundColor Red
}

# Check 2: Application ID
Write-Host "`n2️⃣  Checking Application ID..." -ForegroundColor Cyan
$buildGradlePath = "..\android\app\build.gradle.kts"
$buildGradleContent = Get-Content $buildGradlePath -Raw

if ($buildGradleContent -match 'applicationId\s*=\s*"com\.example\.') {
    $issues += "Application ID still uses 'com.example.*' namespace"
    Write-Host "   ❌ Still using default 'com.example.*' package" -ForegroundColor Red
} elseif ($buildGradleContent -match 'applicationId\s*=\s*"([^"]+)"') {
    $appId = $matches[1]
    Write-Host "   ✅ Application ID: $appId" -ForegroundColor Green
} else {
    $issues += "Could not find Application ID in build.gradle.kts"
    Write-Host "   ❌ Could not find Application ID" -ForegroundColor Red
}

# Check 3: Version info
Write-Host "`n3️⃣  Checking version information..." -ForegroundColor Cyan
$pubspecPath = "..\pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw

if ($pubspecContent -match 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
    $versionName = $matches[1]
    $versionCode = $matches[2]
    Write-Host "   ✅ Version: $versionName (code: $versionCode)" -ForegroundColor Green
    
    if ($versionCode -eq "1" -and $versionName -eq "1.0.0") {
        Write-Host "   ℹ️  First release version" -ForegroundColor Gray
    }
} else {
    $warnings += "Version format may be incorrect in pubspec.yaml"
    Write-Host "   ⚠️  Version format issue" -ForegroundColor Yellow
}

# Check 4: Build configuration
Write-Host "`n4️⃣  Checking build configuration..." -ForegroundColor Cyan

if ($buildGradleContent -match 'minSdk\s*=\s*(\d+)') {
    $minSdk = $matches[1]
    if ([int]$minSdk -lt 21) {
        $warnings += "minSdk < 21 may limit device compatibility"
        Write-Host "   ⚠️  minSdk = $minSdk (recommended: >= 21)" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ minSdk = $minSdk" -ForegroundColor Green
    }
}

if ($buildGradleContent -match 'targetSdk') {
    Write-Host "   ✅ targetSdk configured" -ForegroundColor Green
} else {
    $warnings += "targetSdk not explicitly set"
    Write-Host "   ⚠️  targetSdk not explicitly set" -ForegroundColor Yellow
}

# Check 5: ProGuard rules
Write-Host "`n5️⃣  Checking ProGuard configuration..." -ForegroundColor Cyan
$proguardPath = "..\android\app\proguard-rules.pro"

if (Test-Path $proguardPath) {
    Write-Host "   ✅ ProGuard rules file exists" -ForegroundColor Green
} else {
    $warnings += "ProGuard rules file not found (optional but recommended)"
    Write-Host "   ⚠️  ProGuard rules file not found" -ForegroundColor Yellow
}

# Check 6: Icons and assets
Write-Host "`n6️⃣  Checking app assets..." -ForegroundColor Cyan

$iconPaths = @(
    "..\android\app\src\main\res\mipmap-hdpi\ic_launcher.png",
    "..\android\app\src\main\res\mipmap-xhdpi\ic_launcher.png",
    "..\android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png",
    "..\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"
)

$iconsExist = $false
foreach ($iconPath in $iconPaths) {
    if (Test-Path $iconPath) {
        $iconsExist = $true
        break
    }
}

if ($iconsExist) {
    Write-Host "   ✅ App icons found" -ForegroundColor Green
} else {
    $warnings += "Custom app icons may not be configured"
    Write-Host "   ⚠️  Using default Flutter icons" -ForegroundColor Yellow
}

# Check 7: Permissions
Write-Host "`n7️⃣  Checking AndroidManifest permissions..." -ForegroundColor Cyan
$manifestPath = "..\android\app\src\main\AndroidManifest.xml"

if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    Write-Host "   ✅ AndroidManifest.xml found" -ForegroundColor Green
    
    # Check for internet permission (required for most apps)
    if ($manifestContent -match 'android.permission.INTERNET') {
        Write-Host "   ✅ INTERNET permission declared" -ForegroundColor Green
    } else {
        $warnings += "INTERNET permission not found (may be needed)"
        Write-Host "   ⚠️  INTERNET permission not explicitly declared" -ForegroundColor Yellow
    }
} else {
    $issues += "AndroidManifest.xml not found"
    Write-Host "   ❌ AndroidManifest.xml not found" -ForegroundColor Red
}

# Check 8: Git status
Write-Host "`n8️⃣  Checking Git status..." -ForegroundColor Cyan
Set-Location ..

try {
    $gitStatus = git status --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        if ([string]::IsNullOrWhiteSpace($gitStatus)) {
            Write-Host "   ✅ Working directory clean" -ForegroundColor Green
        } else {
            $warnings += "Uncommitted changes in working directory"
            Write-Host "   ⚠️  Uncommitted changes detected" -ForegroundColor Yellow
        }
        
        # Check if keystore is in gitignore
        $gitignoreContent = Get-Content "android\.gitignore" -Raw -ErrorAction SilentlyContinue
        if ($gitignoreContent -match '\.jks|keystore|key\.properties') {
            Write-Host "   ✅ Keystore files in .gitignore" -ForegroundColor Green
        } else {
            $issues += "Keystore files may not be in .gitignore!"
            Write-Host "   ❌ Keystore files not in .gitignore" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ℹ️  Git not initialized or not available" -ForegroundColor Gray
}

# Summary
Write-Host "`n" -NoNewline
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 SUMMARY" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "✅ All checks passed! App is ready for release." -ForegroundColor Green
    Write-Host "`n🚀 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Run: .\scripts\build-release.ps1" -ForegroundColor Gray
    Write-Host "   2. Test APK on real device" -ForegroundColor Gray
    Write-Host "   3. Upload AAB to Google Play Console`n" -ForegroundColor Gray
    exit 0
}

if ($issues.Count -gt 0) {
    Write-Host "❌ CRITICAL ISSUES ($($issues.Count)):" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "   • $issue" -ForegroundColor Red
    }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "⚠️  WARNINGS ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "   • $warning" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($issues.Count -gt 0) {
    Write-Host "❌ Please fix critical issues before building release.`n" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ No critical issues. You can proceed with caution.`n" -ForegroundColor Green
    exit 0
}
