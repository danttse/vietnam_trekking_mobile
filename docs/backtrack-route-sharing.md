# Backtrack và chia sẻ route

## Sử dụng

1. Bắt đầu hành trình, mở bản đồ offline và chọn **Bắt đầu ghi GPS**.
2. Đường đã đi hiển thị màu xanh lá. GPS được lưu vào SQLite theo từng điểm; dữ liệu vẫn còn khi mở lại màn map hoặc ứng dụng.
3. Chọn **Quay lại theo đường đã đi** / **Backtrack** để xem vệt đường màu cam và điểm bắt đầu màu xanh lá. Đây là vệt GPS để đi theo, không có chỉ dẫn rẽ từng bước.
4. Chọn **Kết thúc hành trình** → **Kết thúc & chia sẻ** để mở form gửi route và các cột mốc được chọn cho admin.
5. Có thể gửi lại từ nút **Chia sẻ route tới admin** trên chi tiết hành trình hoặc bản đồ đã hoàn thành.

GPS sử dụng dịch vụ foreground hiện có: tiếp tục ghi khi chuyển màn trong ứng dụng, tạm dừng khi ứng dụng vào nền/khóa màn hình. Khi mở lại ứng dụng, mở màn map để khôi phục phiên ghi. Tạm dừng hành trình ngừng lưu điểm; hoàn thành/hủy ngừng ghi. Điểm sai số trên 50 m, quá cũ, trùng hoặc nhảy vị trí bất thường bị bỏ qua.

## API

- `POST /api/v1/journeys/:id/complete`: tự đính kèm `track.encodedPolyline` (precision 5) và `statistics` từ GPS đã lưu, kể cả khi hoàn thành qua check-in FINISH.
- `POST /api/v1/contributions/routes`: gửi `sourceJourneyId`, `contributionKind: ROUTE`, `encodedPolyline`, `statistics`, `markerIds`, `clientOperationId`. Backend dùng track/statistics của hành trình khi client không truyền các trường này.
- `GET /api/v1/admin/contributions/:id`: trả `routeSubmission.encodedPolyline` và `trekkingPlaceId` để admin xem đường GPS trên bản đồ offline của địa điểm.

Khi mất mạng, complete và contribution được lưu vào outbox. Đồng bộ giữ thứ tự tạo → bắt đầu → hoàn thành → gửi đóng góp; ID hành trình/cột mốc được đổi sang ID server. Chỉ báo **Admin đã nhận** khi contribution đã đồng bộ, còn offline hiển thị **Chờ đồng bộ**. Idempotency ngăn đóng góp trùng khi retry.

## Kiểm tra trên thiết bị

- Cho phép GPS, bắt đầu ghi rồi di chuyển ít nhất hai điểm. Kiểm tra vệt xanh, số điểm và backtrack màu cam.
- Chuyển sang màn khác, quay lại map; kiểm tra vệt còn và số điểm tăng khi app mở.
- Tạm dừng/tiếp tục hành trình; kiểm tra điểm không tăng trong lúc tạm dừng.
- Mất mạng, kết thúc và gửi route; bật mạng để đồng bộ rồi mở Admin → Đóng góp, kiểm tra đường GPS và cột mốc.
- Đăng xuất/đổi tài khoản; kiểm tra vệt GPS của tài khoản trước không xuất hiện.
