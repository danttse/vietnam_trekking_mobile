# Hướng dẫn cấu hình Google Sign-In cho TrekVN

## Thông tin Client IDs đã được cấp:

- **Android Client ID**: `820891588608-djlgclvp8dc4cdbk86i49g2guras4fib.apps.googleusercontent.com`
- **Web Client ID**: `820891588608-v1b063lrgcal4beea71ad9qdlsg5hf4c.apps.googleusercontent.com`

## Bước 1: Cài đặt dependencies

Dependencies đã được thêm vào `pubspec.yaml`:
```yaml
google_sign_in: ^6.2.2
```

Chạy lệnh:
```bash
flutter pub get
```

## Bước 2: Cấu hình Android

### 2.1. Lấy SHA-1 fingerprint

Chạy lệnh sau để lấy SHA-1 fingerprint của debug keystore:

```bash
cd android
./gradlew signingReport
```

Hoặc sử dụng keytool:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy SHA-1 fingerprint và thêm vào Google Cloud Console cho Client ID Android đã có.

### 2.2. Thêm dependency vào build.gradle.kts

Mở file `android/app/build.gradle.kts` và đảm bảo có các cấu hình sau:

```kotlin
android {
    // ... existing config ...
    
    defaultConfig {
        applicationId = "com.example.vietnam_trekking_mobile"
        // ... other configs ...
    }
}

dependencies {
    // Google Sign-In sẽ được tự động thêm bởi flutter plugin
}
```

### 2.3. Cập nhật AndroidManifest.xml (Optional)

File `android/app/src/main/AndroidManifest.xml` không cần thay đổi gì thêm vì `google_sign_in` plugin sẽ tự động xử lý.

## Bước 3: Cấu hình iOS (nếu cần)

### 3.1. Mở Xcode
```bash
open ios/Runner.xcworkspace
```

### 3.2. Thêm URL Schemes

1. Mở file `ios/Runner/Info.plist`
2. Thêm code sau (hoặc chỉnh sửa trong Xcode):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reversed Client ID từ GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.820891588608-djlgclvp8dc4cdbk86i49g2guras4fib</string>
        </array>
    </dict>
</array>
```

### 3.3. Tải GoogleService-Info.plist (Optional)

Nếu muốn sử dụng đầy đủ Firebase features:
1. Tải `GoogleService-Info.plist` từ Firebase Console
2. Thêm vào `ios/Runner/` trong Xcode

## Bước 4: Kiểm tra cấu hình trong Google Cloud Console

### 4.1. Truy cập Google Cloud Console
https://console.cloud.google.com/

### 4.2. Kiểm tra OAuth 2.0 Client IDs

Vào **APIs & Services** → **Credentials** và xác nhận:

1. **Android Client ID** (`820891588608-djlgclvp8dc4cdbk86i49g2guras4fib.apps.googleusercontent.com`):
   - Package name: `com.example.vietnam_trekking_mobile`
   - SHA-1 fingerprints: (Thêm SHA-1 của debug và release keystore)

2. **Web Client ID** (`820891588608-v1b063lrgcal4beea71ad9qdlsg5hf4c.apps.googleusercontent.com`):
   - Authorized JavaScript origins: Domain của web app
   - Authorized redirect URIs: Callback URLs

### 4.3. Bật Google+ API (nếu chưa bật)

Vào **APIs & Services** → **Library** và search "Google+ API", sau đó enable nó.

## Bước 5: Test trên thiết bị

### 5.1. Chạy app trên Android

```bash
flutter run
```

### 5.2. Test Google Sign-In

1. Nhấn nút "Đăng nhập bằng Google"
2. Chọn tài khoản Google
3. Cho phép quyền truy cập
4. App sẽ nhận ID Token và gửi đến backend
5. Backend verify token và trả về access token + refresh token của TrekVN

## Bước 6: Release Build

Khi build release APK/AAB, cần:

1. Tạo release keystore (nếu chưa có)
2. Lấy SHA-1 của release keystore
3. Thêm SHA-1 vào Google Cloud Console cho Android Client ID
4. Cấu hình signing trong `android/app/build.gradle.kts`

## Troubleshooting

### Lỗi: "DEVELOPER_ERROR"
- Kiểm tra SHA-1 fingerprint đã được thêm vào Google Console
- Kiểm tra package name khớp với Google Console
- Clean và rebuild project: `flutter clean && flutter pub get`

### Lỗi: "SIGN_IN_FAILED"
- Kiểm tra kết nối internet
- Kiểm tra Google+ API đã được enable
- Kiểm tra Client ID trong code

### Lỗi backend: "Google ID Token không hợp lệ"
- Kiểm tra GOOGLE_CLIENT_ID trong backend `.env` khớp với Android Client ID
- Đảm bảo token chưa hết hạn (thường 1 giờ)

## Backend Configuration

Backend đã được cấu hình với:
- File: `services/auth-service/.env`
- Variables:
  ```env
  GOOGLE_CLIENT_ID=820891588608-djlgclvp8dc4cdbk86i49g2guras4fib.apps.googleusercontent.com
  GOOGLE_CLIENT_ID_WEB=820891588608-v1b063lrgcal4beea71ad9qdlsg5hf4c.apps.googleusercontent.com
  ```

Backend sử dụng `google-auth-library` để verify ID Token.

## Flow tổng quan

1. **User nhấn "Đăng nhập bằng Google"**
2. **Flutter app**: Gọi Google Sign-In SDK
3. **Google**: Hiển thị màn hình chọn tài khoản
4. **User**: Chọn tài khoản và cho phép quyền
5. **Google**: Trả về ID Token cho app
6. **Flutter app**: Gửi ID Token đến backend (`POST /auth/google`)
7. **Backend**: Verify ID Token với Google
8. **Backend**: Tạo/cập nhật user và trả về access token + refresh token
9. **Flutter app**: Lưu tokens và điều hướng đến màn hình chính

## Files đã được tạo/cập nhật

### Backend:
- `services/auth-service/.env` - Thêm GOOGLE_CLIENT_ID
- `services/auth-service/src/services/googleAuth.service.js` - Service xử lý Google Sign-In
- `services/auth-service/src/controllers/auth.controller.js` - Controller có sẵn method googleSignIn
- `services/auth-service/src/routes/auth.routes.js` - Route POST /auth/google

### Frontend:
- `pubspec.yaml` - Thêm google_sign_in dependency
- `lib/features/auth/data/models/requests/google_signin_request.dart` - Request model
- `lib/features/auth/services/google_signin_service.dart` - Service wrapper cho Google Sign-In
- `lib/features/auth/repository/auth_repository.dart` - Thêm method googleSignIn
- `lib/features/auth/repository/auth_repository_impl.dart` - Implementation của googleSignIn
- `lib/features/auth/view_models/login_viewmodel.dart` - Thêm method signInWithGoogle
- `lib/features/auth/views/login_screen.dart` - Update UI với Google Sign-In button

## Next Steps

1. Chạy `flutter pub get` để tải dependencies
2. Lấy SHA-1 fingerprint và cập nhật vào Google Cloud Console
3. Test trên Android emulator hoặc physical device
4. Nếu cần iOS, cấu hình thêm theo Bước 3
