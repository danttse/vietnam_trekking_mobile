#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Lấy SHA-1 fingerprint cho Google Sign-In configuration

.DESCRIPTION
    Script này tự động lấy SHA-1 fingerprint từ debug keystore
    để cấu hình Google Sign-In trong Google Cloud Console
#>

Write-Host "🔍 Đang lấy SHA-1 fingerprint cho Google Sign-In..." -ForegroundColor Cyan
Write-Host ""

# Check if keytool exists
$keytool = Get-Command keytool -ErrorAction SilentlyContinue

if (-not $keytool) {
    Write-Host "❌ Không tìm thấy keytool" -ForegroundColor Red
    Write-Host "   Đảm bảo Java JDK đã được cài đặt và thêm vào PATH" -ForegroundColor Yellow
    exit 1
}

# Debug keystore path
$keystorePath = "$env:USERPROFILE\.android\debug.keystore"

if (-not (Test-Path $keystorePath)) {
    Write-Host "❌ Không tìm thấy debug keystore tại: $keystorePath" -ForegroundColor Red
    Write-Host "   Chạy app ít nhất 1 lần để tạo debug keystore" -ForegroundColor Yellow
    exit 1
}

Write-Host "📂 Debug keystore: $keystorePath" -ForegroundColor Green
Write-Host ""

# Get keystore info
try {
    $output = keytool -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android 2>&1
    
    # Extract SHA-1
    $sha1Line = $output | Select-String -Pattern "SHA1:" | Select-Object -First 1
    
    if ($sha1Line) {
        $sha1 = $sha1Line.ToString().Split(":")[1].Trim()
        
        Write-Host "✅ SHA-1 Fingerprint:" -ForegroundColor Green
        Write-Host ""
        Write-Host "   $sha1" -ForegroundColor Cyan
        Write-Host ""
        
        # Copy to clipboard if possible
        try {
            Set-Clipboard -Value $sha1
            Write-Host "📋 SHA-1 đã được copy vào clipboard!" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Không thể copy vào clipboard tự động" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host ""
        Write-Host "📌 Các bước tiếp theo:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1. Truy cập Google Cloud Console:" -ForegroundColor White
        Write-Host "   https://console.cloud.google.com/" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "2. Vào: APIs & Services → Credentials" -ForegroundColor White
        Write-Host ""
        Write-Host "3. Chọn Android OAuth 2.0 Client ID:" -ForegroundColor White
        Write-Host "   820891588608-djlgclvp8dc4cdbk86i49g2guras4fib" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "4. Click 'Add Fingerprint' và paste SHA-1:" -ForegroundColor White
        Write-Host "   $sha1" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "5. Verify package name:" -ForegroundColor White
        Write-Host "   com.example.vietnam_trekking_mobile" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "6. Click SAVE" -ForegroundColor White
        Write-Host ""
        Write-Host "7. Chờ 2-3 phút để Google propagate changes" -ForegroundColor White
        Write-Host ""
        Write-Host "8. Restart app và test lại Google Sign-In" -ForegroundColor White
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        
    } else {
        Write-Host "❌ Không tìm thấy SHA-1 trong output" -ForegroundColor Red
        Write-Host ""
        Write-Host "Output từ keytool:" -ForegroundColor Yellow
        Write-Host $output
    }
    
} catch {
    Write-Host "❌ Lỗi khi chạy keytool:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
