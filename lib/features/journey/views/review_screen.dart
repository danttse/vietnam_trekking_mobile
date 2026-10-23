import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_error_handler.dart';

import '../viewmodels/review_viewmodel.dart';
import '../data/models/review_model.dart';
import 'widgets/rating_stars.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import 'review_success_screen.dart';

class ReviewScreen extends StatefulWidget {
  final String placeId;
  final String? placeName;
  final String? journeyId;
  final ReviewModel? existingReview;

  const ReviewScreen({
    super.key,
    required this.placeId,
    this.placeName,
    this.journeyId,
    this.existingReview,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final ReviewViewModel _vm;
  final _contentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = ReviewViewModel(
      placeId: widget.placeId,
      placeName: widget.placeName,
      journeyId: widget.journeyId,
      existingReview: widget.existingReview,
    );
    _contentCtrl.text = _vm.content;
    _vm.addListener(_onVmChange);
  }

  void _onVmChange() {
    if (!mounted) return;
    if (_vm.state == ReviewSubmitState.success && _vm.submittedReview != null) {
      // Delay navigation để tránh lỗi _debugLocked
      // Navigation phải được thực hiện sau khi notifyListeners() hoàn tất
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReviewSuccessScreen(
              rating: _vm.rating,
              placeName: widget.placeName,
              placeId: widget.placeId,
            ),
          ),
        );
      });
    } else if (_vm.state == ReviewSubmitState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.error ?? 'Gửi đánh giá thất bại'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChange);
    _vm.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading = _vm.state == ReviewSubmitState.submitting;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Đánh giá địa điểm',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Place info ─────────────────────────────────────────────────
          if (widget.placeName != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.placeName!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  if (widget.placeId.isNotEmpty)
                    Text(
                      'Lâm Đồng, Việt Nam',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // ── Rating ────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'MỨC ĐỘ HÀI LÒNG CỦA BẠN?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                RatingStars(
                  rating: _vm.rating,
                  starSize: 36,
                  onChanged: (v) {
                    _vm.setRating(v);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Content ───────────────────────────────────────────────────
          Text(
            'CHIA SẺ TRẢI NGHIỆM',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentCtrl,
            maxLines: 5,
            style: TextStyle(color: cs.onSurface, fontSize: 13),
            onChanged: (v) => _vm.setContent(v),
            decoration: InputDecoration(
              hintText: 'Đường đi Tà Năng mùa này rất đẹp, cỏ xanh mướt...',
              hintStyle: TextStyle(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 13,
              ),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 20),

          // ── Images ────────────────────────────────────────────────────
          Text(
            'THÊM HÌNH ẢNH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Thêm ảnh (tối đa 10)'),
                onPressed: isLoading
                    ? null
                    : () async {
                        try {
                          final files = await ImagePicker().pickMultiImage(
                            imageQuality: 85,
                          );
                          if (!mounted) return;
                          for (final file in files) {
                            _vm.addImage(file.path);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ApiErrorHandler.handle(e)),
                              ),
                            );
                          }
                        }
                      },
              ),
              for (final url in _vm.imageRemoteUrls)
                Stack(
                  children: [
                    Image.network(
                      url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stack) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isLoading
                            ? null
                            : () => _vm.removeRemoteImage(url),
                      ),
                    ),
                  ],
                ),
              for (final path in _vm.imageLocalPaths)
                Stack(
                  children: [
                    Image.file(
                      File(path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isLoading
                            ? null
                            : () => _vm.removeImage(path),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Anonymous toggle ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đánh giá ẩn danh',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Tên của bạn sẽ không hiển thị công khai',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _vm.isAnonymous,
                  onChanged: isLoading ? null : (_) => _vm.toggleAnonymous(),
                  activeThumbColor: const Color(0xFFE8620A),
                  activeTrackColor: const Color(0xFFE8620A)
                      .withValues(alpha: 0.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          BtnLoginPrimary(
            text: widget.existingReview == null
                ? 'Gửi đánh giá'
                : 'Lưu chỉnh sửa (1 lần)',
            isLoading: isLoading,
            onPressed: _vm.canSubmit
                ? () {
                    _vm.setContent(_contentCtrl.text);
                    _vm.submit();
                  }
                : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
