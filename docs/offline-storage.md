# Kiểm tra offline: hành trình, bản đồ và SQLite

> Báo cáo lịch sử của lượt nâng cấp trước. Trạng thái API/gói bản đồ và kết quả
> kiểm tra mới nhất ngày 12/10/2026 nằm trong [frontend-readiness-audit.md](frontend-readiness-audit.md).

## Lỗi tải bản đồ đã sửa

Agent lưu ZIP trong bucket bản đồ. Trekking service trước đây tạo URL bằng domain
bucket media, vì vậy API có metadata nhưng tải file nhận 404. Cấu hình mới
`MAP_R2_PUBLIC_BASE_URL` dành cho bucket bản đồ; `R2_PUBLIC_BASE_URL` vẫn dành cho media.
Khi triển khai trekking service phải cung cấp domain của đúng bucket agent.

Route chưa có gói riêng dùng gói của place. Metadata cũ được sao chép từ cùng
họ object key của place cũng theo phiên bản mới của place. API trả `scope` và
`entityId` để Flutter lưu gói PLACE dùng chung cho các route trong địa điểm.

Flutter tải ZIP vào file tạm, kiểm tra SHA256, giải nén vào thư mục mới, kiểm tra
manifest/version/checksum của từng payload và mở kiểm tra từng SQLite MBTiles.
Chỉ sau khi hợp lệ mới ghi `downloaded_maps.status = READY`; ZIP không còn bị đổi
tên thành `.mbtiles`. Gói lỗi không thay thế bản đã cài. Gói cũ thiếu manifest
được đánh dấu OUTDATED khi tra cứu để tải lại.

Màn Xem bản đồ dùng style của gói đã cài và tile/glyph từ máy qua
`127.0.0.1:<port>`. Không còn style demotiles online hoặc GeoJSON Bà Đen mẫu cho
gói tải về. Có thể mở bản đồ từ cung đường hoặc chi tiết hành trình. Khi gói
không phủ tọa độ cung đường, màn hình báo sai vùng thay vì hiển thị nhầm núi.

## SQLite v4

| Dữ liệu | Lưu trữ và đồng bộ |
| --- | --- |
| Địa điểm, route, milestones | Snapshot JSON đầy đủ và các bảng cache; đọc lại khi lỗi mạng/5xx |
| Hành trình | `local_journeys` và snapshot theo tài khoản; giữ ghi chú, số người, ngày dự kiến, thống kê và track |
| Check-in | GPS, độ chính xác và thời gian gốc trong `offline_checkins`; snapshot phản hồi xác minh của backend |
| Marker | `local_journey_markers`, `local_marker_media`; tạo/sửa/xóa theo ID local rồi ánh xạ ID server |
| Bản đồ | Payload trên filesystem; phiên bản, checksum, BBOX và đường dẫn trong `downloaded_maps` |
| 34 tỉnh | Snapshot theo tài khoản và `visited_provinces` với khóa `(ownerId, provinceId)`; giữ cả code và ID backend |
| Đóng góp route/place | `local_contributions` và outbox; xử lý lại đóng góp route trong hàng đợi cũ khi xác định được chủ sở hữu |
| Tác vụ chờ gửi | `offline_outbox`: ghi cùng transaction với dữ liệu local, theo tài khoản và thứ tự tạo |

Upsert cache cập nhật tại chỗ, tránh INSERT OR REPLACE xóa bản ghi cha và làm mất
hành trình/check-in hoặc vi phạm khóa ngoại. Migration kiểm tra cột đã tồn tại;
không xóa DB khi nâng phiên bản. Milestone đổi thứ tự không làm mất check-in cũ.

Outbox gửi tạo hành trình trước các thao tác start/check-in/marker/complete,
sau đó dùng ID server. Các ID client giữ nguyên khi retry. Khi mất phản hồi
chuyển trạng thái, worker kiểm tra trạng thái trên server trước khi gửi lại.
Lỗi mạng/5xx giữ PENDING; lỗi nghiệp vụ giữ FAILED để người dùng sửa, không báo
thành công giả. Worker chạy khi mở app, app resume và mỗi 30 giây khi app hoạt động.

Check-in offline hiển thị chờ đồng bộ/xác minh. Chỉ phản hồi VERIFIED của backend
mới tính là đã xác minh. Đánh dấu tỉnh thủ công là SELF_REPORTED; không tự đổi
thành VERIFIED và không hạ trạng thái VERIFIED khi bỏ đánh dấu thủ công.

Phiên lưu trong secure storage cho phép mở lại app khi mất mạng. Lỗi mạng/5xx
lúc refresh token giữ phiên; refresh token bị backend từ chối vẫn yêu cầu đăng
nhập lại. Các yêu cầu đồng bộ kiểm tra tài khoản hiện tại trước khi gửi.

## Chọn cung đường

Màn tạo hành trình hiển thị danh sách địa điểm trước. Chạm một địa điểm mới tải
và hiển thị các route thuộc địa điểm đó. Có quay lại đổi địa điểm, tìm kiếm,
trạng thái tải/trống/thử lại. Người dùng phải chọn route rõ ràng; không tự chọn
route đầu tiên. Ngày kết thúc và số thành viên được kiểm tra trước khi lưu.

## Kết quả kiểm tra và giới hạn

Kiểm thử dùng SQLite FFI thật trên Windows, mở lại DB và kiểm tra khóa ngoại;
dùng ZIP v2 thật để giải nén, đếm 70 tile, và yêu cầu tile qua HTTP localhost rồi
đối chiếu bytes với MBTiles. Các kiểm thử giao diện xác nhận địa điểm xuất hiện
trước route. Kiểm thử backend dùng MongoDB kiểm thử riêng.

Kết quả cuối: 52 kiểm thử Flutter, 43 kiểm thử trekking-service và 54 kiểm thử
checkin-service đạt. Analyzer không có lỗi; vẫn còn cảnh báo/lint trong dự án.
APK debug build thành công tại `build/app/outputs/flutter-apk/app-debug.apk`.
Kiểm thử mở rộng còn phát hiện và sửa API duyệt marker đóng góp: đồng nhất
action/decision giữa WebAdmin, validator và service; hỗ trợ POST/PATCH và kiểm
tra milestone được liên kết thuộc đúng route. Khai báo quyền GPS Android và
mô tả quyền vị trí iOS đã được bổ sung cho check-in/marker; chưa build iOS trên Windows.

ZIP `nui-ba-den-v2-flutter.zip` tải từ URL API đã khớp checksum:
`520d3b2a8cb4719b7edfadd655f8cc42775ed68c467ded58c7dfda0500556330`.
Tuy nhiên BBOX của nó là `[107.3514, 10.9161, 107.4032, 10.964]`, thuộc vùng
Núi Chứa Chan, ngoài tọa độ địa điểm Bà Đen `[106.17, 11.3823]`.
Đây là lỗi dữ liệu đầu vào; sửa trình tải không biến vùng này thành Bà Đen.

Gói Bà Đen v3 dùng BBOX `[106.13943, 11.36157, 106.19162, 11.41239]` đã được cắt
từ file mẫu bằng workflow, thêm style và kiểm tra hợp lệ, tại:
`Backend-TrekVN/services/agent-service/artifacts/manual-review/ba-den-correct-v3-validated/nui-ba-den-v3-flutter.zip`.
Gói này là artifact local, chưa upload/publish vào API. Cần tạo/duyệt gói đúng BBOX
trong màn quản trị để ứng dụng tải bản chính thức đúng địa điểm.

Dữ liệu tỉnh của DB v3 không có thông tin tài khoản được giữ với owner rỗng,
không tự gán cho tài khoản đăng nhập sau nâng cấp. Các hàng đợi cũ không xác định
được chủ sở hữu không được tự gửi. Người dùng vẫn phải tải catalog/gói bản đồ
một lần trước khi dùng offline. Worker không chạy khi hệ điều hành đã tắt app.

Form marker hiện còn placeholder chọn ảnh; công việc này kiểm tra lưu/đọc metadata
media trong SQLite, chưa bổ sung luồng chọn, sao chép và upload ảnh offline.
Chưa chạy tương tác GPS/MapLibre trên điện thoại thật; APK debug được build để
kiểm tra tiếp trên thiết bị. Các kiểm thử không thay thế việc đo GPS thực tế.

## Chạy lại

```powershell
flutter test test/trekking
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build apk --debug
```

Chạy lại app hoặc cài APK mới để áp dụng migration và giao diện; hot reload đơn
thuần không đủ cho thay đổi khởi động ứng dụng. Không cần xóa dữ liệu app.
