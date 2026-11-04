# ============================================================================
# Script: Update Version for TrekVN App
# Usage: .\scripts\update-version.ps1
# ============================================================================

Write-Host "📱 TrekVN - Version Updater" -ForegroundColor Cyan
Write-Host "============================`n" -ForegroundColor Cyan

# Read current version from pubspec.yaml
$pubspecPath = "..\pubspec.yaml"

if (-not (Test-Path $pubspecPath)) {
    Write-Host "❌ ERROR: pubspec.yaml not found!" -ForegroundColor Red
    exit 1
}

$pubspecContent = Get-Content $pubspecPath -Raw

if ($pubspecContent -match 'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)') {
    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    $patch = [int]$matches[3]
    $build = [int]$matches[4]
    
    $currentVersion = "$major.$minor.$patch+$build"
    
    Write-Host "📋 Current version: $currentVersion" -ForegroundColor Green
    Write-Host "   Version name: $major.$minor.$patch" -ForegroundColor Gray
    Write-Host "   Build number: $build`n" -ForegroundColor Gray
} else {
    Write-Host "❌ ERROR: Could not parse version from pubspec.yaml" -ForegroundColor Red
    exit 1
}

# Version update options
Write-Host "🎯 Update type:" -ForegroundColor Cyan
Write-Host "   1. Patch (Bug fixes) - $major.$minor.$($patch+1)+$($build+1)" -ForegroundColor Gray
Write-Host "   2. Minor (New features) - $major.$($minor+1).0+$($build+1)" -ForegroundColor Gray
Write-Host "   3. Major (Breaking changes) - $($major+1).0.0+$($build+1)" -ForegroundColor Gray
Write-Host "   4. Build only (Same version) - $major.$minor.$patch+$($build+1)" -ForegroundColor Gray
Write-Host "   5. Custom version`n" -ForegroundColor Gray

$updateType = Read-Host "Select update type (1-5)"

switch ($updateType) {
    "1" {
        $newMajor = $major
        $newMinor = $minor
        $newPatch = $patch + 1
        $newBuild = $build + 1
    }
    "2" {
        $newMajor = $major
        $newMinor = $minor + 1
        $newPatch = 0
        $newBuild = $build + 1
    }
    "3" {
        $newMajor = $major + 1
        $newMinor = 0
        $newPatch = 0
        $newBuild = $build + 1
    }
    "4" {
        $newMajor = $major
        $newMinor = $minor
        $newPatch = $patch
        $newBuild = $build + 1
    }
    "5" {
        Write-Host "`n📝 Enter custom version:" -ForegroundColor Cyan
        $newMajor = Read-Host "Major version"
        $newMinor = Read-Host "Minor version"
        $newPatch = Read-Host "Patch version"
        $newBuild = Read-Host "Build number"
        
        # Validate input
        try {
            $newMajor = [int]$newMajor
            $newMinor = [int]$newMinor
            $newPatch = [int]$newPatch
            $newBuild = [int]$newBuild
            
            if ($newBuild -le $build) {
                Write-Host "⚠️  WARNING: Build number should be greater than current ($build)" -ForegroundColor Yellow
                $continue = Read-Host "Continue anyway? (yes/no)"
                if ($continue -ne "yes") {
                    Write-Host "❌ Cancelled" -ForegroundColor Red
                    exit 0
                }
            }
        } catch {
            Write-Host "❌ ERROR: Invalid version numbers" -ForegroundColor Red
            exit 1
        }
    }
    default {
        Write-Host "❌ Invalid option" -ForegroundColor Red
        exit 1
    }
}

$newVersion = "$newMajor.$newMinor.$newPatch+$newBuild"

Write-Host "`n📋 Version update:" -ForegroundColor Cyan
Write-Host "   Old: $currentVersion" -ForegroundColor Red
Write-Host "   New: $newVersion" -ForegroundColor Green

$confirm = Read-Host "`nProceed with update? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "❌ Cancelled" -ForegroundColor Yellow
    exit 0
}

# Update pubspec.yaml
Write-Host "`n🔨 Updating pubspec.yaml..." -ForegroundColor Cyan

$oldVersionLine = "version: $currentVersion"
$newVersionLine = "version: $newVersion"

$updatedContent = $pubspecContent -replace [regex]::Escape($oldVersionLine), $newVersionLine

Set-Content -Path $pubspecPath -Value $updatedContent

Write-Host "✅ Version updated successfully!`n" -ForegroundColor Green

# Ask for release notes
Write-Host "📝 Do you want to create release notes? (yes/no)" -ForegroundColor Cyan
$createNotes = Read-Host

if ($createNotes -eq "yes") {
    $notesPath = "..\RELEASE_NOTES_v$newVersion.md"
    
    $notesTemplate = @"
# Release Notes - Version $newVersion

**Release Date:** $(Get-Date -Format "yyyy-MM-dd")

## 🎯 Summary
Brief summary of this release...

## ✨ New Features
- Feature 1
- Feature 2

## 🐛 Bug Fixes
- Fix 1
- Fix 2

## 🔧 Improvements
- Improvement 1
- Improvement 2

## 📱 Compatibility
- Minimum Android version: 5.0 (API 21)
- Target Android version: Latest

## 📋 Testing
- [ ] Tested on emulator
- [ ] Tested on real device
- [ ] All features working
- [ ] No crashes

## 📦 Build Info
- Version name: $newMajor.$newMinor.$newPatch
- Version code: $newBuild
- Build type: Release
- Signed: Yes

---

## 🇻🇳 Release Notes (Vietnamese)

### Tóm tắt
Tóm tắt ngắn gọn về phiên bản này...

### Tính năng mới
- Tính năng 1
- Tính năng 2

### Sửa lỗi
- Lỗi 1
- Lỗi 2

### Cải thiện
- Cải thiện 1
- Cải thiện 2

---

**Previous version:** $currentVersion
**New version:** $newVersion
"@

    Set-Content -Path $notesPath -Value $notesTemplate
    Write-Host "✅ Release notes template created: $notesPath" -ForegroundColor Green
    Write-Host "   Please edit the file to add details`n" -ForegroundColor Gray
}

# Next steps
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Review the version change in pubspec.yaml" -ForegroundColor Gray
Write-Host "   2. Edit release notes (if created)" -ForegroundColor Gray
Write-Host "   3. Commit changes: git add . && git commit -m 'Bump version to $newVersion'" -ForegroundColor Gray
Write-Host "   4. Build release: .\scripts\build-release.ps1" -ForegroundColor Gray
Write-Host "   5. Upload to Google Play Console`n" -ForegroundColor Gray

Write-Host "✅ Done!`n" -ForegroundColor Green
