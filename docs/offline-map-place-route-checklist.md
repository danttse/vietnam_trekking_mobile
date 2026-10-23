# Kiểm tra bản đồ địa điểm và cung đường

Nền bản đồ dùng style và MBTiles từ ZIP đã xuất bản của **place**. Các route của
cùng place dùng chung gói này; đường đi được vẽ từ `route.path` hiện tại. Các lớp
route/cột mốc có sẵn trong ZIP được bỏ khỏi preview để tránh hiện nhầm cung đường.
Ảnh đầu trang của route lấy từ `route.imageUrl`, được upload riêng ở Admin.
Route chưa có ảnh hiển thị nền trống; ảnh của place không thay thế ảnh route.

1. Khởi động lại trekking-service, tải lại Admin và cài APK mới hoặc chạy lại
   Flutter. Giữ dữ liệu ứng dụng để kiểm tra gói offline đã tải.
2. Admin → Chi tiết địa điểm: preview đọc ZIP đã xuất bản qua endpoint backend
   có xác thực (`places/:id/offline-map/file`), kể cả bucket không bật CORS. Nếu chưa có gói,
   màn hình báo thiếu gói. Khi đã mở bản đồ, tile không lấy từ máy chủ OSM.
3. Admin → Tạo/sửa route: chọn place có gói offline, nhập path GeoJSON/GPX,
   upload ảnh riêng, nhập mô tả và thông số. Đổi path phải thay đường màu cam
   trên cùng nền bản đồ; zoom/phóng to không được submit form. Lưu và mở lại
   để kiểm tra ảnh, path và thông số đã lưu.
4. Nhập 3.25 km phải lưu `distanceMeters=3250`. Các route cũ bị lưu sai đơn vị
   cần nhập lại cự ly đúng và lưu; không suy đoán rồi sửa hàng loạt dữ liệu cũ.
5. App → Chi tiết place: nếu chưa tải, bấm **Tải bản đồ offline**. Không cần
   chọn route để tải. Sau đó xem route A và B của place: nền bản đồ giống nhau,
   đường đi và ảnh đầu trang khác nhau theo route.
6. App → Chi tiết route: kiểm tra mô tả, độ khó, địa điểm, cự ly, thời gian,
   độ cao leo, độ cao tối đa và điểm đầu/cuối. Dữ liệu route được cache cùng
   place; mở lại các màn đã xem sau khi bật chế độ máy bay.
7. Mở/phóng to/đóng map liên tục, rồi quay về chi tiết place. Nền, nhãn và
   path phải vẫn hiện khi mất mạng; không tải lại ZIP cho mỗi route.

Kiểm thử tự động: `flutter test test/trekking`; Admin `npm test` và `npm run build`;
backend Jest `map_download.test.js` và `offline.test.js` cùng các bài journey,
marker, contribution. Kiểm thử ZIP dùng SQLite thật và xác nhận tile server
đọc được sau khi đóng màn hình thứ hai. MapLibre native và thao tác cảm ứng
cần thử thêm trên thiết bị/emulator theo các bước trên.
