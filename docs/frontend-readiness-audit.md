# Kiểm tra app mobile ngày 12/10/2026

Mã frontend và bộ kiểm thử đạt các kiểm tra dưới đây. Chưa thể xác nhận toàn
bộ ứng dụng sẵn sàng: một gói bản đồ được API công bố không hợp lệ và chưa có
phiên đăng nhập để kiểm tra đồng bộ tài khoản thật. Chưa tạo Git commit vì yêu
cầu là chỉ commit khi mọi thứ ổn. Nội dung commit dự kiến được lưu riêng trong
`frontend-commit-message.txt`.

## Kết quả xác nhận

| Kiểm tra | Kết quả |
| --- | --- |
| `flutter test --no-pub --reporter expanded` | 147 tests đạt |
| `flutter analyze --no-pub --no-fatal-infos` | 0 errors, 0 warnings; còn 108 lint infos |
| APK Android debug | Build thành công, cài cập nhật bằng `adb install -r` thành công |
| Khởi động Android | Tiến trình app chạy; log Flutter được kiểm tra không có RenderFlex/Unhandled/EXCEPTION |
| SQLite trên điện thoại | Đọc header DB thực: `user_version = 4` |
| Migration schema v1/v2/v3 thực | Đạt; giữ user, journey PENDING, idempotency key, đủ cột/index như DB mới và không lỗi khóa ngoại |
| Offline/retry | Kiểm thử SQLite thật, mở lại DB, thứ tự create/start/check-in/complete, ID server, GPS/thời gian gốc, retry không trùng |
| Đổi tài khoản | Cache/outbox riêng theo tài khoản; request cũ không refresh hoặc xóa phiên tài khoản mới |
| UI | Kiểm thử màn 320/390 px và chữ lớn cho các luồng đã có; thêm đăng nhập/đăng ký/quên mật khẩu tiếng Việt/Anh |

Các kiểm thử đồng bộ dùng HTTP fixtures, không chứng minh request của tài
khoản thật đã đến backend. SQLite FFI không thay thế việc đo GPS ngoài thực địa.
Điện thoại không có binary sqlite3; kiểm tra header chỉ xác nhận phiên bản DB,
không phải integrity/foreign-key audit trên DB của thiết bị.

## Lỗi sửa trong lượt kiểm tra này

- Chia sẻ một refresh request giữa các API client dùng cùng refresh token;
  dùng token mới cho phản hồi 401 đến muộn và bảo vệ phiên khi đổi tài khoản.
- Lỗi nghiệp vụ 422 sau refresh không còn đăng xuất hoặc bị đổi thành lỗi 401.
- Sửa tràn chữ ở footer đăng nhập/đăng ký/quên mật khẩu và nhãn input mật khẩu.
- Nối các nút điều khoản/chính sách ở đăng ký vào màn có sẵn; nối đăng ký Google
  vào luồng Google auth có sẵn, thay callback rỗng. Chưa xác nhận Google auth thật.
- Gỡ đúng listener theme/language; dừng timer đồng bộ khi app ra nền và khởi
  động lại khi resume.
- Tạo lại index sau nâng cấp SQLite, thêm kiểm thử schema cũ thiếu cột thật.
- Dọn các cảnh báo analyzer và whitespace; bỏ log một phần Google ID token.
- Theo dõi `pubspec.lock` để giữ dependency của app nhất quán; bỏ qua ảnh/DB
  QA local trong Git.

Các thay đổi API, GPS, offline storage, bản đồ, rank và UI lớn đã có trong
working tree trước lượt này cũng được chạy lại qua bộ tests/build nói trên.

## Kiểm tra gói đang công bố trên API thật

API đọc: `http://127.0.0.1:3003/api/v1`. Audit tải ZIP tạm, so sánh size/checksum,
chạy chính `OfflinePackageInstaller`, kiểm tra manifest/version/file checksums,
SQLite MBTiles có tiles và tọa độ địa điểm nằm trong vùng gói. Không sửa backend.

| Địa điểm | Gói | Kết quả |
| --- | --- | --- |
| ĐHQG | v1 | Hợp lệ |
| Núi Bà Đen | v3 | Hợp lệ; thông tin gói v2 sai vùng trong báo cáo cũ không còn phản ánh API hiện tại |
| Núi Chứa Chan | v1, 700 bytes | **Lỗi**: `FormatException: Manifest bản đồ không hợp lệ hoặc sai phiên bản.` |

ID Chứa Chan: `6ac604e085a8ecf3251bb7bf`.
Object key: `maps/nui-chua-chan/v1/nui-chua-chan-v1-flutter.zip`.
API vẫn báo `available: true` nhưng installer của app từ chối gói. Cần tạo/duyệt
và công bố gói đúng qua luồng quản trị. Không nới validator để chấp nhận gói lỗi.

Chạy lại audit độc lập, có sử dụng mạng thật:

```powershell
flutter test --no-pub tool/check_live_offline_packages_test.dart --reporter expanded
```

Đổi server bằng `--dart-define=AUDIT_TREKKING_URL=<URL>/api/v1`.
Audit này nằm trong `tool/`, không chạy cùng unit/widget tests mặc định.

## Chưa xác nhận / chưa hoàn tất

- Đồng bộ end-to-end bằng tài khoản thật: tạo offline → khởi động lại → bật
  mạng → kiểm tra dữ liệu backend/admin và số bản ghi. Điện thoại ở màn đăng
  nhập lúc kiểm tra; chưa có tài khoản test được cung cấp.
- Community/posts/comments vẫn dùng dữ liệu mẫu vì repository chưa có backend
  Community. Không thể coi toàn bộ các màn đã được đồng bộ với server.
- GPS ngoài thực địa, MapLibre bằng bản đồ của tài khoản thật, upload media
  thật, Google sign-in thật và iOS chưa được xác nhận trong lượt này.
- Build vẫn có cảnh báo hỗ trợ Gradle 8.14/AGP 8.11.1 trong tương lai. APK debug
  build được; chưa đổi toolchain hoặc kiểm tra iOS trên Windows.

APK kiểm tra dùng API loopback qua USB reverse (ports 3000/3002/3003). Khi
chạy trên thiết bị qua Wi-Fi hoặc build để phân phối cần truyền đúng API URL.

## Điều kiện chốt commit

Sửa gói Chứa Chan rồi chạy lại live package audit; kiểm tra đồng bộ tài khoản
thật với API mong muốn. Phân biệt rõ Community demo với phạm vi tính năng đã
hoàn tất. Chỉ sau khi xác nhận các mục này mới chốt commit theo yêu cầu.
