# Community: Bài viết – Tin nhắn – Cá nhân

Backend contract và triển khai nằm trong `Backend-TrekVN/backend/docs/community-social-api.md`; Swagger trực tiếp community-service `/api-docs`. App dùng cùng Gateway và cơ chế refresh token của Community hiện tại.

- `community_people.dart`: tìm exact email/QR, scanner, hồ sơ chủ/người khác, QR và cấp lại, giới thiệu, bài theo quyền, nút nhắn tin.
- `community_messages.dart`: inbox có unread, tạo nhóm, chat, thu hồi/báo cáo, quản lý nhóm và chuyển chủ/rời.
- `social_api.dart`: API `/community/...` trên Dio Community hiện có. Không dùng samples hay fallback khi lỗi.
- `social_view_model.dart`, `conversation_view_model.dart`: REST state và WebSocket invalidation, pagination, retry key và bỏ response cũ sau logout/dispose. Gửi tin dùng REST, socket chỉ báo thay đổi.
- Chạm avatar trên feed tới hồ sơ tác giả. Tab Hành trình bên trong Community đổi thành Tin nhắn; tab Hành trình chính của app giữ nguyên.

Tên/avatar vẫn lấy từ Auth; giới thiệu Community là field riêng. Trang người khác chỉ thấy public posts, không thấy email hay QR của họ. QR cá nhân là token ngẫu nhiên có thể cấp lại, cần đăng nhập để resolve, không là token đăng nhập. Không cần kết bạn để chat/tạo nhóm.

Chat hiện hỗ trợ chữ 4000 ký tự, 50 người/nhóm. Người mới vào hoặc được thêm lại không đọc lịch sử trước lần tham gia hiện tại. Tin lỗi giữ bản nháp và mã retry trong phiên màn chat; chưa có outbox qua khởi động lại app. Giữ tin mình để thu hồi; giữ tin người khác để báo cáo riêng tin đó cho Admin. Không có gọi điện, gửi media, typing/presence hoặc push nền.

Thêm native plugin `mobile_scanner` và `qr_flutter`. Android/iOS đã khai báo Camera; cần `flutter pub get` và full rebuild APK/IPA. Chỉ mở camera khi chọn Quét QR; có thể nhập email/nội dung QR nếu không cấp quyền. Cần kiểm tra camera trên thiết bị thật.

Backend phải deploy **Auth → Community → Gateway** từ source mới, cùng internal token. App build qua Gateway với `--dart-define=API_BASE_URL=https://<gateway>/api/v1 --dart-define=COMMUNITY_BASE_URL=https://<gateway>/api/v1`. Web Admin cũng cần rebuild để có quản lý nhóm/báo cáo.

Kiểm thử: `flutter test test/community`, `flutter analyze lib/features/community test/community/social_test.dart`. Các test dùng API adapter cục bộ, không gửi tin hay thao tác tài khoản production. Smoke test hai user: email/QR → profile → DM; tạo nhóm → thêm/gỡ/chuyển chủ; mất mạng retry; tombstone; logout; báo cáo và Admin xử lý.
