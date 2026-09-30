// [BACKEND TEST TEMP SCREEN]
// Màn hình tạm Chính Sách Bảo Mật phục vụ Backend Test.
// Xóa hoặc thay thế file này khi pull Frontend chính thức.

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color accentColor = Color(0xFFE07A5F);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Chính sách bảo mật',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Last updated
              Text(
                'Cập nhật lần cuối: 20/12/2025',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        index: '1.',
                        title: 'Thu thập dữ liệu',
                        content:
                            'Chúng tôi thu thập thông tin đăng ký (Tên, Email, Ảnh đại diện) và đặc biệt là dữ liệu vị trí GPS của bạn (ngay cả khi ứng dụng chạy ngầm) để vẽ bản đồ hành trình trekking và kích hoạt tính năng check-in.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 18),
                      _buildSection(
                        index: '2.',
                        title: 'Sử dụng dữ liệu',
                        content:
                            'Dữ liệu vị trí được sử dụng để hiển thị vị trí của bạn trên bản đồ dã ngoại, thống kê tổng quãng đường di chuyển và mở khóa các huy hiệu thám hiểm cá nhân.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 18),
                      _buildSection(
                        index: '3.',
                        title: 'Chia sẻ dữ liệu',
                        content:
                            'Thông tin và lịch sử đi trekking của bạn chỉ được chia sẻ công khai khi bạn chủ động ấn nút \'Đăng bài viết\' trên diễn đàn Cộng đồng hoặc chia sẻ huy hiệu lên mạng xã hội.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 18),
                      _buildSection(
                        index: '4.',
                        title: 'Bảo mật thông tin',
                        content:
                            'Trek Việt Nam áp dụng các biện pháp mã hóa đầu cuối tiên tiến nhất để bảo vệ thông tin cá nhân và dữ liệu tọa độ của bạn trước các truy cập trái phép.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 18),
                      _buildSection(
                        index: '5.',
                        title: 'Quyền của bạn',
                        content:
                            'Bạn có quyền truy cập, chỉnh sửa thông tin hồ sơ cá nhân hoặc yêu cầu xóa vĩnh viễn tài khoản cùng toàn bộ lịch sử định vị GPS đã lưu trên máy chủ của chúng tôi bất kỳ lúc nào.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String index,
    required String title,
    required String content,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: '$index ',
                style: const TextStyle(color: accentColor),
              ),
              TextSpan(
                text: title,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
