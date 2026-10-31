# vietnam_trekking_mobile

A new Flutter project.

## Community

Community dùng REST và WebSocket qua API Gateway. Đăng bài/sửa/xóa, public/private,
địa điểm/hành trình, ảnh, bình luận/reply và reactions đã nối API thật.

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=COMMUNITY_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=TREKKING_BASE_URL=http://10.0.2.2:3000/api/v1
flutter test test/community
```

`COMMUNITY_BASE_URL` mặc định bằng `API_BASE_URL`; URL WebSocket tự suy ra thành
`ws(s)://host/api/v1/community/ws`. Backend yêu cầu MongoDB Atlas/replica set.
Ảnh dùng Cloudinary qua trekking upload purpose `COMMUNITY_POST`. Hành trình
cần đồng bộ lên server trước khi chia sẻ. Báo cáo, nhóm và chat chưa có backend.

Các test community dùng HTTP fixtures và WebSocket cục bộ, không cần tài khoản
production. Socket tự kết nối lại sau mất mạng, token refresh hoặc khi app trở
lại foreground; sau logout, dữ liệu chờ từ phiên cũ không được đưa lại vào UI.
