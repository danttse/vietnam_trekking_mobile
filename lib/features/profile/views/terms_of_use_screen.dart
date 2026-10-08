import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  Widget _buildSection({
    required BuildContext context,
    required String number,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$number.  ',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: title,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBarWithBack(
              title: 'Điều khoản sử dụng',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cập nhật lần cuối: 20/12/2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context: context,
                      number: '1',
                      title: 'Giới thiệu',
                      content:
                          'Chào mừng bạn đến với Trek Việt Nam, ứng dụng hỗ trợ điều hướng, ghi lại nhật ký hành trình trekking và kết nối cộng đồng đam mê dã ngoại tại Việt Nam. Bằng việc đăng ký tài khoản, bạn đồng ý tuân thủ các điều khoản này.',
                    ),
                    _buildSection(
                      context: context,
                      number: '2',
                      title: 'Điều kiện sử dụng',
                      content:
                          'Bạn phải từ 16 tuổi trở lên hoặc có sự giám sát của người bảo hộ để sử dụng ứng dụng. Bạn chịu trách nhiệm hoàn toàn về tính bảo mật của mật khẩu và mọi hoạt động dưới tài khoản của mình.',
                    ),
                    _buildSection(
                      context: context,
                      number: '3',
                      title: 'Quyền và nghĩa vụ của người dùng',
                      content:
                          'Người dùng được phép sử dụng bản đồ ngoại tuyến, lưu trữ lịch sử di chuyển và chia sẻ ảnh trekking lành mạnh lên cộng đồng. Nghiêm cấm hành vi phá hoại dữ liệu, đăng tải thông tin sai lệch về bản đồ biên giới hoặc địa danh nhạy cảm.',
                    ),
                    _buildSection(
                      context: context,
                      number: '4',
                      title: 'Quyền sở hữu trí tuệ',
                      content:
                          'Toàn bộ mã nguồn, thiết kế đồ họa, hệ thống huy hiệu và cơ sở dữ liệu cung đường trekking độc quyền đều thuộc quyền sở hữu của Trek Việt Nam. Mọi hành vi sao chép không xin phép đều bị nghiêm cấm.',
                    ),
                    _buildSection(
                      context: context,
                      number: '5',
                      title: 'Giới hạn trách nhiệm',
                      content:
                          'Trekking là hoạt động thể thao mạo hiểm ngoài trời. Chúng tôi cung cấp bản đồ GPS mang tính tham khảo và không chịu trách nhiệm pháp lý trước bất kỳ tai nạn, rủi ro tự nhiên hay lạc đường nào của bạn trên cung đường thực tế.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
