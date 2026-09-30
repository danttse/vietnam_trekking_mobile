// [BACKEND TEST TEMP SCREEN]
// Màn hình tạm Điều Khoản Sử Dụng phục vụ Backend Test.
// Xóa hoặc thay thế file này khi pull Frontend chính thức.

import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

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
                    'Điều khoản sử dụng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Last updated text
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
                        title: 'Giới thiệu',
                        content:
                            'Chào mừng bạn đến với Trek Việt Nam, ứng dụng hỗ trợ điều hướng, ghi lại nhật ký hành trình trekking và kết nối cộng đồng đam mê dã ngoại tại Việt Nam. Bằng việc đăng ký tài khoản, bạn đồng ý tuân thủ các điều khoản này.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 18),
                      _buildSection(
                        index: '2.',
                        title: 'Điều kiện sử dụng',
                        content:
                            'Bạn phải từ 16 tuổi trở lên hoặc có sự giám sát của người bảo hộ để sử dụng ứng dụng. Bạn chịu trách nhiệm hoàn toàn về tính bảo mật của mật khẩu và mọi hoạt động dưới tài khoản của mình.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 18),
                      _buildSection(
                        index: '3.',
                        title: 'Quyền và nghĩa vụ của người dùng',
                        content:
                            'Người dùng được phép sử dụng bản đồ ngoại tuyến, lưu trữ lịch sử di chuyển và chia sẻ ảnh trekking lành mạnh lên cộng đồng. Nghiêm cấm hành vi phá hoại dữ liệu, đăng tải thông tin sai lệch về bản đồ biên giới hoặc địa danh nhạy cảm.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 18),
                      _buildSection(
                        index: '4.',
                        title: 'Quyền sở hữu trí tuệ',
                        content:
                            'Toàn bộ mã nguồn, thiết kế đồ họa, hệ thống huy hiệu và cơ sở dữ liệu cung đường trekking độc quyền đều thuộc quyền sở hữu của Trek Việt Nam. Mọi hành vi sao chép không xin phép đều bị nghiêm cấm.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 18),
                      _buildSection(
                        index: '5.',
                        title: 'Giới hạn trách nhiệm',
                        content:
                            'Trekking là hoạt động thể thao mạo hiểm ngoài trời. Chúng tôi cung cấp bản đồ GPS mang tính tham khảo và không chịu trách nhiệm pháp lý trước bất kỳ tai nạn, rủi ro tự nhiên hay lạc đường nào của bạn trên cung đường thực tế.',
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
