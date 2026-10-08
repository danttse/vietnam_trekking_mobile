import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
              title: 'Chính sách bảo mật',
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
                      title: 'Thu thập dữ liệu',
                      content:
                          'Chúng tôi thu thập thông tin đăng ký (Tên, Email, Ảnh đại diện) và đặc biệt là dữ liệu vị trí GPS của bạn (ngay cả khi ứng dụng chạy ngầm) để vẽ bản đồ hành trình trekking và kích hoạt tính năng check-in.',
                    ),
                    _buildSection(
                      context: context,
                      number: '2',
                      title: 'Sử dụng dữ liệu',
                      content:
                          'Dữ liệu vị trí được sử dụng để hiển thị vị trí của bạn trên bản đồ dã ngoại, thống kê tổng quãng đường di chuyển và mở khóa các huy hiệu thám hiểm cá nhân.',
                    ),
                    _buildSection(
                      context: context,
                      number: '3',
                      title: 'Chia sẻ dữ liệu',
                      content:
                          'Thông tin và lịch sử đi trekking của bạn chỉ được chia sẻ công khai khi bạn chủ động ấn nút \'Đăng bài viết\' trên diễn đàn Cộng đồng hoặc chia sẻ huy hiệu lên mạng xã hội.',
                    ),
                    _buildSection(
                      context: context,
                      number: '4',
                      title: 'Bảo mật thông tin',
                      content:
                          'Trek Việt Nam áp dụng các biện pháp mã hóa đầu cuối tiên tiến nhất để bảo vệ thông tin cá nhân và dữ liệu tọa độ của bạn trước các truy cập trái phép.',
                    ),
                    _buildSection(
                      context: context,
                      number: '5',
                      title: 'Quyền của bạn',
                      content:
                          'Bạn có quyền truy cập, chỉnh sửa thông tin hồ sơ cá nhân hoặc yêu cầu xóa vĩnh viễn tài khoản cùng toàn bộ lịch sử định vị GPS đã lưu trên máy chủ của chúng tôi bất kỳ lúc nào.',
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
