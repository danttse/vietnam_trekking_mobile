# 📜 TrekVN Scripts

Scripts tự động hóa cho việc build và release ứng dụng TrekVN.

## 📋 Danh sách Scripts

### 1. 🔐 generate-keystore.ps1
**Mục đích:** Tạo keystore file để ký app Android

**Khi nào dùng:** Chỉ chạy 1 lần duy nhất, trước lần đầu release

**Cách dùng:**
```powershell
cd Frontend-TrekVN\scripts
.\generate-keystore.ps1
```

**Output:**
- `android/app/trekvn-upload-keystore.jks` - File keystore
- `android/key.properties` - File cấu hình chứa passwords

**⚠️ Quan trọng:**
- Backup file `.jks` vào nơi an toàn
- Lưu passwords trong password manager
- KHÔNG commit `.jks` và `key.properties` lên Git
- Mất keystore = không thể update app trên Play Store!

---

### 2. 🔨 build-release.ps1
**Mục đích:** Build AAB/APK file cho release

**Khi nào dùng:** Mỗi khi cần build version mới để test hoặc upload

**Cách dùng:**
```powershell
cd Frontend-TrekVN\scripts
.\build-release.ps1
```

**Options:**
1. Build AAB (Android App Bundle) - Dùng để upload lên Play Store
2. Build APK - Dùng để test trên điện thoại
3. Build cả AAB và APK

**Output:**
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

**Features:**
- ✅ Tự động clean build
- ✅ Tự động get dependencies
- ✅ Hiển thị file size
- ✅ Option để mở folder output

---

### 3. 🔍 check-release-ready.ps1
**Mục đích:** Kiểm tra xem app có sẵn sàng để release chưa

**Khi nào dùng:** Trước khi build release, để đảm bảo config đúng

**Cách dùng:**
```powershell
cd Frontend-TrekVN\scripts
.\check-release-ready.ps1
```

**Checks:**
1. ✅ Keystore configuration
2. ✅ Application ID (không còn `com.example.*`)
3. ✅ Version information
4. ✅ Build configuration (minSdk, targetSdk)
5. ✅ ProGuard rules
6. ✅ App icons
7. ✅ AndroidManifest permissions
8. ✅ Git status (.gitignore cho keystore)

**Exit codes:**
- `0` - All checks passed hoặc chỉ có warnings
- `1` - Có critical issues cần fix

---

### 4. 📱 update-version.ps1
**Mục đích:** Tự động update version number trong pubspec.yaml

**Khi nào dùng:** Trước khi build version mới

**Cách dùng:**
```powershell
cd Frontend-TrekVN\scripts
.\update-version.ps1
```

**Update types:**
1. **Patch** (1.0.0 → 1.0.1) - Bug fixes
2. **Minor** (1.0.0 → 1.1.0) - New features
3. **Major** (1.0.0 → 2.0.0) - Breaking changes
4. **Build only** (1.0.0+1 → 1.0.0+2) - Rebuild same version
5. **Custom** - Nhập version tùy chỉnh

**Features:**
- ✅ Hiển thị current version
- ✅ Preview new version trước khi update
- ✅ Auto tăng build number
- ✅ Tạo release notes template (optional)

---

## 🔄 Workflow Chuẩn

### Lần đầu release:

```powershell
# Bước 1: Tạo keystore (chỉ 1 lần)
.\generate-keystore.ps1

# Bước 2: Kiểm tra sẵn sàng
.\check-release-ready.ps1

# Bước 3: Build AAB
.\build-release.ps1
# → Chọn option 1 (AAB)

# Bước 4: Upload lên Google Play Console
# (Làm thủ công trên web)
```

### Update version tiếp theo:

```powershell
# Bước 1: Update version
.\update-version.ps1
# → Chọn update type

# Bước 2: Kiểm tra
.\check-release-ready.ps1

# Bước 3: Build
.\build-release.ps1

# Bước 4: Upload
# (Làm thủ công trên web)
```

---

## 🛠️ Troubleshooting

### Script không chạy được

**Error:** "cannot be loaded because running scripts is disabled"

**Fix:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Keystore script báo lỗi keytool not found

**Error:** "keytool not found"

**Fix:** 
- Install Java JDK: https://www.oracle.com/java/technologies/downloads/
- Hoặc dùng Java có sẵn với Android Studio

### Build script báo Flutter not found

**Error:** "Flutter not found"

**Fix:**
- Install Flutter: https://flutter.dev/docs/get-started/install
- Thêm Flutter vào PATH

### Build failed với signing error

**Error:** "Keystore file not found" hoặc "Wrong password"

**Fix:**
1. Kiểm tra file `android/key.properties` tồn tại
2. Kiểm tra file `.jks` tồn tại
3. Kiểm tra password đúng trong `key.properties`
4. Nếu mất keystore, phải chạy lại `generate-keystore.ps1` (sẽ tạo app mới trên Play Store)

---

## 📚 Additional Resources

- [Quick Start Guide](../QUICK_START_RELEASE.md) - Hướng dẫn nhanh
- [Release Checklist](../RELEASE_CHECKLIST.md) - Checklist đầy đủ
- [Flutter Deployment Docs](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

---

## ⚙️ Script Requirements

**PowerShell:** Version 5.1 or higher (built-in on Windows 10+)

**External tools:**
- Flutter SDK
- Java JDK (cho keytool)
- Git (optional, cho version control checks)

---

## 🔒 Security Notes

**NEVER commit these files to Git:**
- `*.jks` - Keystore files
- `key.properties` - Contains passwords
- Any files with passwords or credentials

**These are already in .gitignore:**
```
key.properties
**/*.keystore
**/*.jks
```

**Always backup:**
- Keystore file (`.jks`)
- Passwords in password manager (1Password, Bitwarden, etc.)
- `key.properties` (encrypted backup)

---

## 📞 Support

Nếu gặp vấn đề:
1. Đọc lại output của script (thường có hướng dẫn fix)
2. Check file log trong `build/` directory
3. Google error message
4. Check Flutter docs: https://docs.flutter.dev

---

**Happy building! 🚀**
