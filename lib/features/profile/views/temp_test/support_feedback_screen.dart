// [BACKEND TEST TEMP SCREEN]
// Màn hình tạm Hỗ Trợ & Phản Hồi phục vụ Backend Test.
// Xóa hoặc thay thế file này khi pull Frontend chính thức.

import 'package:flutter/material.dart';

class SupportFeedbackScreen extends StatefulWidget {
  const SupportFeedbackScreen({super.key});

  @override
  State<SupportFeedbackScreen> createState() => _SupportFeedbackScreenState();
}

class _SupportFeedbackScreenState extends State<SupportFeedbackScreen> {
  static const Color accentColor = Color(0xFFE07A5F);

  String _selectedIssueType = 'Lỗi định vị GPS / Bản đồ';
  final List<String> _issueTypes = [
    'Lỗi định vị GPS / Bản đồ',
    'Gợi ý tính năng mới',
    'Sự cố tài khoản',
    'Vấn đề dữ liệu cung đường',
    'Khác',
  ];

  final TextEditingController _detailController = TextEditingController();
  bool _isLoading = false;

  final List<bool> _expandedFaq = [true, false, false];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('[Backend Test] Đã gửi phản hồi thành công!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

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
                    'Hỗ trợ & Phản hồi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: CÂU HỎI THƯỜNG GẶP
                      Text(
                        'CÂU HỎI THƯỜNG GẶP',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // FAQ Accordion list
                      _buildFaqTile(
                        index: 0,
                        question: 'Làm sao để check-in tại cột mốc?',
                        answer:
                            'Bật định vị GPS trên điện thoại của bạn, di chuyển đến phạm vi 50m quanh cột mốc và nhấn nút \'Check-in ngay\' trên màn hình Bản đồ hành trình.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 10),
                      _buildFaqTile(
                        index: 1,
                        question: 'Huy hiệu hoạt động như thế nào?',
                        answer:
                            'Huy hiệu tự động mở khóa khi bạn hoàn thành các thử thách trekking như số tỉnh thành đạt mốc hoặc tổng quãng đường tích lũy.',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 10),
                      _buildFaqTile(
                        index: 2,
                        question: 'Cách tạo hành trình mới?',
                        answer:
                            'Bạn vào màn hình Hành trình, chọn tạo mới hành trình và thiết lập các địa điểm, cột mốc dự kiến tham gia.',
                        colorScheme: colorScheme,
                      ),

                      const SizedBox(height: 24),

                      // Section 2: GỬI PHẢN HỒI CHO CHÚNG TÔI
                      Text(
                        'GỬI PHẢN HỒI CHO CHÚNG TÔI',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Feedback Form Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LOẠI VẤN ĐỀ',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Dropdown field
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedIssueType,
                                  isExpanded: true,
                                  dropdownColor:
                                      colorScheme.surfaceContainerHighest,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                  items: _issueTypes.map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedIssueType = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'MÔ TẢ CHI TIẾT',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Textarea field
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: TextField(
                                controller: _detailController,
                                maxLines: 4,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Mô tả lỗi hoặc đề xuất của bạn tại đây...',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Gửi phản hồi',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer contact info
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Hoặc gửi thư trực tiếp đến chúng tôi qua',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('[Backend Test] support@trekvietnam.vn'),
                                  ),
                                );
                              },
                              child: const Text(
                                'support@trekvietnam.vn',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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

  Widget _buildFaqTile({
    required int index,
    required String question,
    required String answer,
    required ColorScheme colorScheme,
  }) {
    final isExpanded = _expandedFaq[index];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedFaq[index] = !_expandedFaq[index];
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
              child: Text(
                answer,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
