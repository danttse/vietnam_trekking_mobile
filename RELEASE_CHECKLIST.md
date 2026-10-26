# 📋 TrekVN Release Checklist

Sử dụng checklist này trước khi release app lên Google Play Store.

## 🔐 Signing & Security

- [ ] Keystore đã được tạo (`trekvn-upload-keystore.jks`)
- [ ] File `key.properties` đã được cấu hình đúng
- [ ] Keystore đã được backup vào nơi an toàn (Google Drive, 1Password, etc.)
- [ ] Passwords đã được lưu trong password manager
- [ ] File `.jks` và `key.properties` đã được thêm vào `.gitignore`
- [ ] Không commit passwords hoặc keystore lên Git

## 🏷️ Application Configuration

- [ ] Application ID đã đổi từ `com.example.*` sang package name riêng
  - Current: `_____________________`
- [ ] Version name đã cập nhật trong `pubspec.yaml`
  - Current: `_____________________`
- [ ] Version code đã tăng (số sau dấu `+`)
  - Current: `_____________________`
- [ ] minSdkVersion >= 21 (Android 5.0)
- [ ] targetSdkVersion là version mới nhất

## 📱 Build Configuration

- [ ] ProGuard rules đã được cấu hình (`proguard-rules.pro`)
- [ ] Signing config đã được thêm vào `build.gradle.kts`
- [ ] Multi-dex được enable nếu cần
- [ ] Minification và resource shrinking được enable cho release

## 🎨 Assets & Resources

- [ ] App icon đã được thay thế (không dùng icon mặc định)
- [ ] App name đã được cập nhật trong `AndroidManifest.xml`
- [ ] Splash screen đã được customized
- [ ] Tất cả assets cần thiết đã được thêm vào `pubspec.yaml`

## 🧪 Testing

- [ ] App đã test trên Android Emulator
- [ ] App đã test trên thiết bị thật (Android phone)
- [ ] Test trên nhiều Android versions khác nhau
- [ ] Test offline map functionality
- [ ] Test Google Sign-In
- [ ] Test location permissions
- [ ] Test camera/image picker
- [ ] Không có crash khi chạy
- [ ] Performance ổn định (không lag)

## 🔨 Build Process

- [ ] Chạy `flutter clean` trước khi build
- [ ] Chạy `flutter pub get` để update dependencies
- [ ] Build AAB thành công: `flutter build appbundle --release`
- [ ] File AAB kích thước hợp lý (< 100MB)
- [ ] Chạy script check: `.\scripts\check-release-ready.ps1`

## 📄 Google Play Console

### Store Listing
- [ ] App name (max 50 characters): `_____________________`
- [ ] Short description (max 80 characters)
- [ ] Full description (max 4000 characters)
- [ ] App icon: 512x512px PNG, 32-bit
- [ ] Feature graphic: 1024x500px PNG/JPEG
- [ ] Phone screenshots: ít nhất 2 ảnh, 16:9 hoặc 9:16
- [ ] Tablet screenshots (optional)
- [ ] Category được chọn
- [ ] Email liên hệ
- [ ] Privacy policy URL (nếu cần)

### App Content
- [ ] Content rating questionnaire đã hoàn thành
- [ ] Target audience đã được chọn
- [ ] App access (toàn bộ hoặc có giới hạn)
- [ ] Ads declaration (có quảng cáo hay không)
- [ ] Data safety form đã điền
  - [ ] Data collection practices
  - [ ] Data sharing practices
  - [ ] Security practices

### Technical Details
- [ ] Countries/regions để release đã được chọn
- [ ] Pricing: Free/Paid đã được chọn
- [ ] Distributed as Android App (not Android Instant App)

## 🚀 Release Process

- [ ] AAB file đã được upload lên Google Play Console
- [ ] Release name đã được đặt (e.g., "Version 1.0.0")
- [ ] Release notes đã được viết (Vietnamese + English)
- [ ] Release track được chọn:
  - [ ] Internal testing
  - [ ] Closed testing
  - [ ] Open testing
  - [ ] Production
- [ ] Rollout percentage đã được chọn (nếu cần)

## 📋 Release Notes Template

### Vietnamese
```
Phiên bản 1.0.0
- Tính năng bản đồ offline cho khu vực Bà Đen
- Hệ thống check-in tại các điểm du lịch
- Đăng nhập với Google
- Theo dõi hành trình leo núi
- Thống kê và thành tích cá nhân
```

### English
```
Version 1.0.0
- Offline map support for Ba Den region
- Check-in system at tourist destinations
- Google Sign-In integration
- Trekking journey tracking
- Personal statistics and achievements
```

## 🔍 Pre-Submit Verification

- [ ] Tất cả các mục trong checklist này đã hoàn thành
- [ ] App đã được test kỹ lưỡng
- [ ] Không có warning hoặc error nghiêm trọng
- [ ] Team members đã review
- [ ] Backup keystore đã được xác nhận

## 📧 Post-Release

- [ ] Theo dõi Google Play Console dashboard
- [ ] Check crash reports
- [ ] Đọc user reviews và ratings
- [ ] Trả lời user feedback
- [ ] Monitor app performance metrics
- [ ] Setup Firebase Analytics/Crashlytics (nếu có)

---

## 🆘 Emergency Contacts

- **Google Play Support:** https://support.google.com/googleplay/android-developer
- **Firebase Support:** https://firebase.google.com/support
- **Flutter Documentation:** https://docs.flutter.dev

## 📝 Notes

Ghi chú thêm cho lần release này:

```
_______________________________________________
_______________________________________________
_______________________________________________
```

---

**Last Updated:** `_____________________`  
**Reviewed By:** `_____________________`  
**Release Version:** `_____________________`
