# Kiểm tra hành trình sau bản sửa 10/10/2026

Khởi động lại trekking-service (port 3003), chạy lại Flutter hoặc cài APK debug
mới bằng cách cập nhật app hiện tại. Tải lại trang Web Admin. Giữ dữ liệu app để
kiểm tra các hành trình đã tạo và gói bản đồ đã tải.

1. Đăng nhập tài khoản đã tạo hành trình, mở **Hành trình → Sắp tới**.
   Hành trình mới và các hành trình dùng route đã vô hiệu hóa đều phải hiện.
   Route vô hiệu hóa vẫn giữ tên/thông tin trong lịch sử; route đã xóa có thể
   hiển thị thông tin cache hoặc nhãn không còn khả dụng.
2. Mở **Chi tiết hành trình**. Bấm bắt đầu, tạm dừng, rồi tiếp tục.
   Trạng thái nút và model đưa sang check-in/bản đồ phải khớp. Quay về danh sách,
   danh sách tự tải lại; có thể kéo xuống để làm mới.
3. Mở **Xem bản đồ** với gói đã tải. Camera mở tại vùng của gói offline,
   kể cả khi GPS giả lập đang ở ngoài vùng. Thử tắt mạng và mở lại.
4. Khi còn offline, tạm dừng/tiếp tục hành trình. Đóng rồi mở lại app: trạng thái
   đã lưu vẫn còn. Bật mạng, để app hoạt động khoảng 30 giây cho worker đồng bộ.
   Hành trình không được nhân đôi, trạng thái phải khớp backend.
5. Trên Admin mở **Hành trình & Check-in** và lọc ID tài khoản. Đợi tối đa
   10 giây hoặc bấm **Làm mới** để thấy thay đổi đã đồng bộ. Bấm tên hành trình
   để xem địa điểm, route, lịch dự kiến, trạng thái, ghi chú và số check-in/marker.
   Bộ lọc trạng thái dùng PLANNED, ACTIVE, PAUSED, COMPLETED, CANCELLED.

Dữ liệu đang chờ trên SQLite chỉ xuất hiện trên Admin sau khi đồng bộ lên
backend. Thống kê quãng đường thực tế được lưu riêng với quãng đường dự kiến
của route; nếu route được nhập 3 mét thì ứng dụng không tự đổi thành 3 km.

Kiểm thử tự động: `flutter test test/trekking`, Jest journey/offline/marker/
contribution và `npm test` ở Web Admin. Tương tác MapLibre/GPS cần kiểm tra trên
máy giả lập hoặc thiết bị bằng các bước trên.
