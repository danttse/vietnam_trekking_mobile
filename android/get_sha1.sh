#!/bin/bash

# Script để lấy SHA-1 fingerprint cho Google Sign-In

echo "🔍 Đang lấy SHA-1 fingerprint cho Google Sign-In..."
echo ""

# Check if keytool exists
if ! command -v keytool &> /dev/null; then
    echo "❌ Không tìm thấy keytool"
    echo "   Đảm bảo Java JDK đã được cài đặt và thêm vào PATH"
    exit 1
fi

# Debug keystore path
KEYSTORE_PATH="$HOME/.android/debug.keystore"

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Không tìm thấy debug keystore tại: $KEYSTORE_PATH"
    echo "   Chạy app ít nhất 1 lần để tạo debug keystore"
    exit 1
fi

echo "📂 Debug keystore: $KEYSTORE_PATH"
echo ""

# Get SHA-1
SHA1=$(keytool -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>&1 | grep "SHA1:" | head -1 | cut -d' ' -f3)

if [ -z "$SHA1" ]; then
    echo "❌ Không tìm thấy SHA-1 trong output"
    exit 1
fi

echo "✅ SHA-1 Fingerprint:"
echo ""
echo "   $SHA1"
echo ""

# Try to copy to clipboard
if command -v pbcopy &> /dev/null; then
    echo "$SHA1" | pbcopy
    echo "📋 SHA-1 đã được copy vào clipboard! (macOS)"
elif command -v xclip &> /dev/null; then
    echo "$SHA1" | xclip -selection clipboard
    echo "📋 SHA-1 đã được copy vào clipboard! (Linux)"
else
    echo "⚠️  Clipboard tool không có sẵn (pbcopy/xclip)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📌 Các bước tiếp theo:"
echo ""
echo "1. Truy cập Google Cloud Console:"
echo "   https://console.cloud.google.com/"
echo ""
echo "2. Vào: APIs & Services → Credentials"
echo ""
echo "3. Chọn Android OAuth 2.0 Client ID:"
echo "   820891588608-djlgclvp8dc4cdbk86i49g2guras4fib"
echo ""
echo "4. Click 'Add Fingerprint' và paste SHA-1:"
echo "   $SHA1"
echo ""
echo "5. Verify package name:"
echo "   com.example.vietnam_trekking_mobile"
echo ""
echo "6. Click SAVE"
echo ""
echo "7. Chờ 2-3 phút để Google propagate changes"
echo ""
echo "8. Restart app và test lại Google Sign-In"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
