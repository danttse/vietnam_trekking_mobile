# BỘ SƠ ĐỒ USE CASE VÀ SEQUENCE DIAGRAM (SRS v3.1) — TREKVIỆT

Thư mục này chứa đầy đủ **28 sơ đồ Mermaid (`.mmd`)** chuẩn hóa theo tài liệu đặc tả yêu cầu **SRS v3.1**, đối chuẩn với mã nguồn thực tế và chuẩn quốc tế **ISO/IEC/IEEE 29148:2018**.

---

## 1. Sơ đồ Tổng quan Phân hệ (Overview Use Case Diagrams)
* **[overview-user-usecases.mmd](overview-user-usecases.mmd):** Sơ đồ Use Case tổng quan phân hệ Người dùng (Mobile App) — gồm 17 Use Cases (`UC-01` đến `UC-14`, `UC-23`, `UC-24`, `UC-25`).
* **[overview-admin-usecases.mmd](overview-admin-usecases.mmd):** Sơ đồ Use Case tổng quan phân hệ Quản trị (Web Admin Portal) — gồm 9 Use Cases (`UC-15` đến `UC-22`, `UC-26`).

---

## 2. Danh mục 10 Use Case được Chỉnh sửa và Bổ sung mới trong SRS v3.1

### A. 6 Use Case hiện có được chỉnh sửa & mở rộng:
1. **[UC-04-offline-map.mmd](UC-04-offline-map.mmd):** Tải gói bản đồ ngoại tuyến cấp Địa điểm (Place-level qua `GET /places/:id/offline-package`), tải `.zip.part`, kiểm tra mã băm SHA-256, giải nén và dùng chung MBTiles cho toàn bộ tuyến đường trực thuộc.
2. **[UC-09-provinces-statistics.mmd](UC-09-provinces-statistics.mmd):** Xem bản đồ tỉnh 3 trạng thái (`UNVISITED`, `SELF_REPORTED`, `VERIFIED`), tự đánh dấu thủ công qua `PATCH /visits/provinces/me/:id`, và áp dụng quy tắc một chiều (No-downgrade rule) khi đã đạt `VERIFIED` qua GPS.
3. **[UC-10-badges.mmd](UC-10-badges.mmd):** Xem Cấp bậc (10 Ranks: NEWBIE đến TREK_LEGEND theo 6 tiêu chí), lịch sử cộng điểm kinh nghiệm (7 quy tắc XP), tiến độ thăng hạng và danh sách huy hiệu.
4. **[UC-13-route-contribution.mmd](UC-13-route-contribution.mmd):** Đóng góp cung đường sau hành trình, đính kèm danh sách các Điểm mốc cá nhân (`markerIds`) tạo trong hành trình để gửi cho Admin duyệt.
5. **[UC-19-admin-community-moderation.mmd](UC-19-admin-community-moderation.mmd):** Kiểm duyệt nội dung cộng đồng: Bổ sung nghiệp vụ lọc và xử lý các tin nhắn chat bị người dùng báo cáo vi phạm (`message_reports`) bên cạnh bài viết và bình luận.
6. **[UC-21-admin-contributions.mmd](UC-21-admin-contributions.mmd):** Duyệt đóng góp người dùng: Bổ sung quyền cho Admin xem chi tiết, chỉnh sửa và phê duyệt từng Điểm mốc cá nhân thành Milestone chính thức (`POST /admin/contributions/:id/markers/:markerId/review`).

### B. 4 Use Case được bổ sung mới hoàn toàn:
7. **[UC-23-community-messaging-qr.mmd](UC-23-community-messaging-qr.mmd):** Nhắn tin trực tiếp, Chat nhóm (tối đa 50 người, 4,000 ký tự) qua REST + WebSocket, quét mã QR Token cá nhân phân giải hồ sơ nhanh, thu hồi tin nhắn (Tombstone) và báo cáo vi phạm.
8. **[UC-24-custom-markers.mmd](UC-24-custom-markers.mmd):** Tạo và quản lý Điểm mốc cá nhân (10 phân loại cố định) kèm tọa độ GPS, ảnh và ghi chú khi đang trong hành trình ACTIVE offline, đồng bộ qua hàng đợi `offline_outbox`.
9. **[UC-25-password-recovery.mmd](UC-25-password-recovery.mmd):** Khôi phục mật khẩu qua mã OTP 6 số gửi về email (hạn 10 phút, giới hạn 3 lần/15 phút), đặt lại mật khẩu Bcrypt và thu hồi toàn bộ refresh token cũ.
10. **[UC-26-admin-rank-config.mmd](UC-26-admin-rank-config.mmd):** Quản lý Cấu hình Cấp bậc: Admin xem và điều chỉnh ngưỡng 6 tiêu chí của hệ thống 10 Cấp bậc (`rank_configs`), kiểm tra tính đơn điệu tăng dần và ghi Audit Log.

---

## 3. Danh mục 16 Use Case Kế thừa (Không đổi logic):
* `UC-01-auth.mmd`, `UC-02-profile-settings.mmd`, `UC-03-explore.mmd`, `UC-05-journey-management.mmd`, `UC-06-gps-backtrack.mmd`, `UC-07-milestone-checkin.mmd`, `UC-08-offline-sync.mmd`, `UC-11-community.mmd`, `UC-12-place-review.mmd`, `UC-14-place-suggestion.mmd`, `UC-15-admin-auth.mmd`, `UC-16-admin-dashboard.mmd`, `UC-17-admin-users.mmd`, `UC-18-admin-trekking-data.mmd`, `UC-20-admin-badge-map.mmd`, `UC-22-admin-audit-log.mmd`.

---

## 4. Hướng dẫn Xuất ảnh (Export PNG / SVG)
Cài đặt Mermaid CLI:
```powershell
npm install -g @mermaid-js/mermaid-cli
```

Xuất ảnh hàng loạt sang PNG độ nét cao:
```powershell
Get-ChildItem -Filter *.mmd | ForEach-Object {
    $outPng = $_.BaseName + ".png"
    mmdc -i $_.Name -o $outPng -b white -s 2
}
```
Hoặc mở file trực tiếp trên VS Code bằng extension **Markdown Preview Mermaid Support** / **Mermaid Preview**.
