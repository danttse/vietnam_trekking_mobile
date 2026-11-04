#!/usr/bin/env pwsh
# Script test màn Promote Screen cho Windows
# Chạy: .\test-promote.ps1

Write-Host "🎉 Vietnam Trekking - Promote Screen Test Tool" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Menu
Write-Host "Chọn phương pháp test:" -ForegroundColor Yellow
Write-Host "  1. Chạy file test riêng (Khuyến nghị - Dễ nhất)" -ForegroundColor Green
Write-Host "  2. Xóa dữ liệu app Android và chạy" -ForegroundColor Yellow
Write-Host "  3. Chỉ xóa dữ liệu app (không chạy)" -ForegroundColor Yellow
Write-Host "  4. Chạy app bình thường" -ForegroundColor Gray
Write-Host "  5. Clean và chạy app" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Nhập lựa chọn (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "▶️  Chạy file test riêng..." -ForegroundColor Cyan
        Write-Host "   Màn Promote sẽ hiển thị trực tiếp" -ForegroundColor Gray
        Write-Host ""
        flutter run -t lib/test_promote_screen.dart
    }
    
    "2" {
        Write-Host ""
        Write-Host "🗑️  Xóa dữ liệu app Android..." -ForegroundColor Yellow
        
        # Lấy package name từ pubspec.yaml hoặc dùng default
        $packageName = "com.example.vietnam_trekking_mobile"
        
        # Check xem có device không
        $devices = adb devices | Select-String -Pattern "device$"
        if ($devices.Count -eq 0) {
            Write-Host "❌ Không tìm thấy device Android nào!" -ForegroundColor Red
            Write-Host "   Vui lòng kết nối device hoặc khởi động emulator" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "   Package: $packageName" -ForegroundColor Gray
        adb shell pm clear $packageName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Đã xóa dữ liệu app" -ForegroundColor Green
            Write-Host ""
            Write-Host "▶️  Chạy app..." -ForegroundColor Cyan
            flutter run
        } else {
            Write-Host "❌ Không thể xóa dữ liệu. App có thể chưa được cài đặt." -ForegroundColor Red
            Write-Host "   Đang chạy app..." -ForegroundColor Yellow
            flutter run
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "🗑️  Xóa dữ liệu app..." -ForegroundColor Yellow
        
        $packageName = "com.example.vietnam_trekking_mobile"
        
        $devices = adb devices | Select-String -Pattern "device$"
        if ($devices.Count -eq 0) {
            Write-Host "❌ Không tìm thấy device Android!" -ForegroundColor Red
            exit 1
        }
        
        adb shell pm clear $packageName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Đã xóa dữ liệu app" -ForegroundColor Green
            Write-Host "   Bây giờ chạy: flutter run" -ForegroundColor Cyan
        } else {
            Write-Host "❌ Lỗi khi xóa dữ liệu" -ForegroundColor Red
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "▶️  Chạy app bình thường..." -ForegroundColor Cyan
        flutter run
    }
    
    "5" {
        Write-Host ""
        Write-Host "🧹 Cleaning..." -ForegroundColor Cyan
        flutter clean
        
        Write-Host "📦 Getting dependencies..." -ForegroundColor Cyan
        flutter pub get
        
        Write-Host "▶️  Chạy app..." -ForegroundColor Cyan
        flutter run
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Lựa chọn không hợp lệ" -ForegroundColor Red
        exit 1
    }
}
