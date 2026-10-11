# Check-in, bản đồ và cột mốc — 11/10/2026

Các màn check-in, thành công, đánh giá và cột mốc đã có trong frontend.
Bản sửa hoàn thiện luồng đang dùng trong journey, giữ theme, font và các
component của app; hình tham khảo dùng để đối chiếu bố cục và thao tác.

## Luồng và API

| Thao tác | API / hành vi |
| --- | --- |
| Check-in cột mốc | `POST /checkins` ở checkin-service, gửi journey ID, milestone ID, GPS, sai số và thời gian UTC gốc. Chỉ `VERIFIED` mở màn thành công. |
| Check-in offline | Lưu outbox; giữ tọa độ/thời gian gốc để gửi lại. Hiển thị chờ xác minh, không tăng số cột mốc đã chinh phục. |
| Đánh giá | `POST /places/:placeId/reviews`, gồm `point`, `content`, `imagesUrl`, `isAnonymous`. Backend cập nhật đánh giá hiện có của cùng tài khoản/địa điểm. |
| Xem đánh giá khác | `GET /places/:placeId/reviews`, phân trang, kéo làm mới, xử lý lỗi và danh sách rỗng. |
| Lưu cột mốc | Outbox rồi `POST /journeys/:journeyId/markers`; sửa qua `PUT /journeys/:journeyId/markers/:markerId`. |
| Ảnh cột mốc | Sao chép vào storage bền vững, lấy chữ ký `POST /uploads/presign` với purpose `JOURNEY_MARKER`, tải ảnh rồi gửi URL. Retry giữ URL ảnh đã tải thành công. |
| Gửi admin | Dùng màn đóng góp và API hiện có sau khi journey `COMPLETED`; chọn trước các cột mốc, kể cả cột mốc đang chờ đồng bộ. |

Khởi động lại trekking-service để sử dụng trường `isAnonymous` mới. Danh sách
đánh giá công khai loại bỏ user ID/avatar khi ẩn danh; API riêng của người viết
vẫn giữ quyền sở hữu. Huy hiệu chỉ hiện khi có dữ liệu đã được cấp, không tạo
huy hiệu từ ảnh tham khảo. Backend hiện cấp huy hiệu khi hoàn thành journey.

## Vị trí và bản đồ

- Khi mở app, hệ điều hành xin quyền vị trí nếu chưa quyết định. Từ chối vẫn
  vào app được; map/check-in có thao tác cấp lại quyền hoặc mở cài đặt.
- GPS chung lấy vị trí đầu tiên, chỉ duy trì cập nhật khi có màn đang cần;
  dừng stream khi app vào nền. Tọa độ cũ bị xóa khi quyền/GPS bị tắt.
- Map dùng gói offline đã tải, đường đi màu xanh, nhãn tên/cao độ cột mốc,
  màu trạng thái check-in, cột mốc cá nhân và lớp vị trí hiện tại MapLibre.
  Nút định vị đưa camera đến GPS thực; nút cung đường đưa về toàn tuyến.
- Mở map cần gói offline phù hợp địa điểm. Vị trí ngoài vùng gói có thể không
  có nền bản đồ tại vị trí đó. Không thay GPS bằng tọa độ tâm gói.
- Android đã bỏ cấu hình loại `play-services-location` của bản prototype để
  Geolocator và lớp vị trí MapLibre sử dụng thư viện native.

## Kiểm tra trên thiết bị

- Cung đường chưa có mốc chính thức: màn journey hiển thị lý do và nút tải
  lại. Bấm Check In sẽ tải lại rồi báo thiếu mốc, không thoát im lặng. Admin
  thêm mốc ở Cột mốc → Thêm cột mốc, chọn đúng cung đường và tọa độ thực.
  Mốc cá nhân đánh dấu trên map không thay thế mốc check-in chính thức.
- Lỗi tải cột mốc hiển thị riêng, không coi là cung đường có 0 mốc. Khi đang
  tải, nút check-in có trạng thái chờ; tải lại thành công mở mốc chưa check-in.

1. Cài APK cập nhật, mở app với quyền vị trí chưa quyết định; thử cho phép,
   từ chối, từ chối vĩnh viễn và cấp lại trong cài đặt. Android chọn vị trí gần
   đúng cần hiển thị sai số và chặn check-in nếu sai số quá 50 m.
2. Mở map của journey ACTIVE với gói offline đã tải. Xem vị trí hiện tại,
   toàn tuyến, nhãn cột mốc; thử zoom, định vị, toàn màn hình và tắt mạng.
3. Check-in trong/ngoài bán kính cấu hình của milestone; chỉ ACTIVE và GPS
   chính xác được gửi. Thành công → tiếp tục phải cập nhật màn journey.
4. Check-in offline phải báo chờ. Bật mạng, mở lại journey để xem kết quả
   xác minh đã đồng bộ, không gửi trùng để nhân đôi thành tích.
5. Mở sheet đánh dấu từ map: vẫn nhìn được map phía trên, bàn phím không che
   form, tên bắt buộc. Chọn ảnh, lưu offline, khởi động lại và đồng bộ. Chạm
   cột mốc để sửa tên/ghi chú/ảnh, kể cả xóa ghi chú hoặc ảnh đã lưu.
6. Đánh giá từ màn thành công; gửi sao, nội dung, ảnh và ẩn danh. Kiểm tra
   danh sách công khai và hai nút xem đánh giá/quay về trang chủ.
7. Hoàn thành journey rồi gửi cung đường/cột mốc cho admin.

## Kiểm thử tự động

- 8 kiểm tra bổ sung cho nút check-in: tải dữ liệu, thiếu mốc, lỗi API, tải lại
  sau khi thêm mốc, chọn mốc chưa check-in, cache cung đường bị vô hiệu hóa
  và bố cục 320/390 px.
- 8 kiểm tra web admin: tạo mốc đúng GeoJSON và loại mốc backend, danh sách
  phân trang, sửa mốc đang có và xóa ghi chú. Form sửa tải đúng ID, không tạo
  một mốc mới; các tùy chọn trạng thái không được backend hỗ trợ đã được ẩn
  khi dùng API thật.

- 39 tests: check-in/GPS, widget 320/390 px, lifecycle vị trí, offline store,
  ảnh đồng bộ lại và style bản đồ.
- 18 tests hồi quy: journey history, hợp đồng API, tích hợp frontend và phiên
  offline; 7 tests tích hợp review backend.
- Dart analyze các file thay đổi: không có error/warning, còn gợi ý lint về
  dấu ngoặc của câu `if`. ESLint bốn file review backend đạt.
- `flutter build apk --debug --no-pub` đạt. Gradle/AGP hiện tại có cảnh báo
  hỗ trợ phiên bản trong tương lai; không nâng cấp toolchain trong bản sửa này.
- Android 14 emulator: đã kiểm tra hộp thoại quyền vị trí, native MapLibre
  với gói offline, đường đi/nhãn cột mốc/chấm GPS (sai số giả lập ±5 m) và
  mở/kéo sheet đánh dấu. Kiểm tra GPS ngoài thực địa và iOS cần thiết bị tương
  ứng; test GPS ở đây sử dụng tọa độ do emulator cung cấp.

Ảnh widget kiểm tra tại `.journey-checkin-qa/`. Có thể tái tạo bằng
`flutter test --no-pub test/trekking/journey_checkin_flow_test.dart --dart-define=UPDATE_JOURNEY_PREVIEWS=true`.
Entry point `tool/preview_journey_map.dart` chỉ dùng để kiểm tra native map
với fixture riêng, không phải entry point của APK app chính.

Để chạy entry point QA trên Android debug, chép fixture
`test/fixtures/offline_maps/generated-v2.zip` vào
`files/journey-map-qa.zip` của app bằng `adb push` tới `/data/local/tmp/`, sau
đó `adb shell run-as com.example.vietnam_trekking_mobile cp ...`. Fixture dùng
catalog lookup riêng và không ghi hành trình/cột mốc vào database của app.
GPS giả lập trong gói: kinh độ `107.377`, vĩ độ `10.941`.
