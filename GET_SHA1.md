# Lấy SHA-1 Fingerprint cho Google Sign-In

## Lỗi hiện tại
```
Failed to get ID Token from Google
```

**Nguyên nhân**: Chưa add SHA-1 fingerprint vào Google Cloud Console

## Cách lấy SHA-1

### Option 1: Sử dụng Gradle (Recommended)

```bash
cd Frontend-TrekVN/android
./gradlew signingReport
```

**Hoặc trên Windows:**
```powershell
cd Frontend-TrekVN/android
.\gradlew.bat signingReport
```

**Output sẽ hiện:**
```
Variant: debug
Config: debug
Store: C:\Users\Admin\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD
SHA-256: XX:XX:XX:...
Valid until: ...
```

**→ Copy SHA1 line (20 bytes, cách nhau bởi dấu `:`)**

### Option 2: Sử dụng keytool

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Trên Windows:**
```powershell
keytool -list -v -keystore "C:\Users\Admin\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

## Thêm SHA-1 vào Google Cloud Console

1. **Truy cập Google Cloud Console**:
   - URL: https://console.cloud.google.com/
   - Chọn project của bạn

2. **Vào Credentials**:
   - Menu bên trái: **APIs & Services** → **Credentials**

3. **Chỉnh sửa Android Client ID**:
   - Tìm OAuth 2.0 Client ID có type **Android**
   - Client ID: `820891588608-djlgclvp8dc4cdbk86i49g2guras4fib`
   - Click vào để edit

4. **Thêm SHA-1**:
   - Trong mục **SHA-1 certificate fingerprint**
   - Click **+ ADD FINGERPRINT**
   - Paste SHA-1 vừa copy (format: `AA:BB:CC:...`)
   - Click **SAVE**

5. **Verify thông tin**:
   ```
   Package name: com.example.vietnam_trekking_mobile
   SHA-1: [SHA-1 bạn vừa thêm]
   ```

## Sau khi thêm SHA-1

1. **Chờ vài phút** để Google propagate changes (thường 1-5 phút)

2. **Restart app**:
   ```bash
   # Stop app
   # Xóa app khỏi device/emulator
   # Run lại
   flutter run
   ```

3. **Test lại Google Sign-In**

## Troubleshooting

### Vẫn báo lỗi sau khi thêm SHA-1?

1. **Check package name khớp:**
   - File: `android/app/build.gradle.kts`
   - Tìm: `applicationId = "com.example.vietnam_trekking_mobile"`
   - Phải khớp 100% với Google Console

2. **Check Client ID trong code:**
   - File: `lib/features/auth/services/google_signin_service.dart`
   - Web Client ID: `820891588608-v1b063lrgcal4beea71ad9qdlsg5hf4c.apps.googleusercontent.com`

3. **Clean và rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Check Google+ API enabled:**
   - Vào: APIs & Services → Library
   - Search: "Google+ API"
   - Status phải là: **ENABLED**

5. **Check network connection:**
   - Emulator/Device phải có internet
   - Không block bởi firewall

### SHA-1 cho Release Build

Nếu build release APK, cần thêm SHA-1 của release keystore:

```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias
```

Sau đó thêm SHA-1 này vào Google Console (cùng Client ID)

## Verify cấu hình

### Check trong code:

1. **google_signin_service.dart** có `serverClientId`:
   ```dart
   final GoogleSignIn _googleSignIn = GoogleSignIn(
     serverClientId: '820891588608-v1b063lrgcal4beea71ad9qdlsg5hf4c.apps.googleusercontent.com',
     scopes: ['email', 'profile'],
   );
   ```

2. **Backend .env** có GOOGLE_CLIENT_ID:
   ```
   GOOGLE_CLIENT_ID=820891588608-djlgclvp8dc4cdbk86i49g2guras4fib.apps.googleusercontent.com
   ```

### Expected flow sau khi fix:

```
Tap Button → Google Sign-In UI → Select Account → 
Get ID Token ✅ → Send to Backend → Login Success ✅
```

## Quick Test

Sau khi cấu hình, log sẽ hiện:

**Before (Error):**
```
[GoogleSignInService] Error during sign-in: Exception: Failed to get ID Token from Google
```

**After (Success):**
```
[GoogleSignInService] Successfully got ID Token
[GoogleSignInService] ID Token: eyJhbGciOiJSUzI1NiIs...
```

---

**TL;DR:**
1. Chạy: `cd android && ./gradlew signingReport`
2. Copy SHA-1
3. Vào Google Console → Credentials → Edit Android Client ID
4. Add SHA-1
5. Save
6. Chờ 2-3 phút
7. Restart app và test lại
