# Fix: Failed to get ID Token from Google

## ❌ Lỗi
```
[GoogleSignInService] Error during sign-in: Exception: Failed to get ID Token from Google
```

## ✅ Giải pháp (2 bước)

### Bước 1: Lấy SHA-1 fingerprint

**Trên Windows (PowerShell):**
```powershell
cd android
.\get_sha1.ps1
```

**Trên Linux/Mac (Bash):**
```bash
cd android
chmod +x get_sha1.sh
./get_sha1.sh
```

**Hoặc dùng Gradle:**
```bash
cd android
./gradlew signingReport
```

→ **Copy SHA-1 fingerprint** (format: `AA:BB:CC:DD:...`)

### Bước 2: Thêm SHA-1 vào Google Cloud Console

1. Truy cập: https://console.cloud.google.com/
2. Vào: **APIs & Services** → **Credentials**
3. Tìm Android OAuth 2.0 Client ID: `820891588608-djlgclvp8dc4cdbk86i49g2guras4fib`
4. Click để edit
5. **Add Fingerprint** → Paste SHA-1
6. Verify package name: `com.example.vietnam_trekking_mobile`
7. **Save**
8. Chờ **2-3 phút**

### Bước 3: Test lại

```bash
# Stop app
# Xóa app khỏi device/emulator (optional)
flutter clean
flutter pub get
flutter run
```

## ✅ Sau khi fix

Log sẽ hiện:
```
[GoogleSignInService] Successfully got ID Token
```

Thay vì:
```
[GoogleSignInService] Error during sign-in: Exception: Failed to get ID Token from Google
```

---

**Chi tiết đầy đủ**: Xem file `GET_SHA1.md`
