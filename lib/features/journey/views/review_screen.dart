import 'package:flutter/material.dart';
import '../viewmodels/review_viewmodel.dart';
import 'widgets/rating_stars.dart';
import 'widgets/trekking_button.dart';
import 'review_success_screen.dart';

class ReviewScreen extends StatefulWidget {
  final String placeId;
  final String? placeName;
  final String? journeyId;

  const ReviewScreen({
    super.key,
    required this.placeId,
    this.placeName,
    this.journeyId,
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
    );
    _vm.addListener(_onVmChange);
  }

  void _onVmChange() {
    if (!mounted) return;
    if (_vm.state == ReviewSubmitState.success &&
        _vm.submittedReview != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReviewSuccessScreen(
            rating: _vm.rating,
            placeName: widget.placeName,
          ),
        ),
      );
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
          icon:
              Icon(Icons.arrow_back_ios_new, size: 20, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Đánh giá địa điểm',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: cs.onSurface)),
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
                        color: cs.onSurface),
                  ),
                  if (widget.placeId.isNotEmpty)
                    Text(
                      'Lâm Đồng, Việt Nam',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant),
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
                      letterSpacing: 0.5),
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
          Text('CHIA SẺ TRẢI NGHIỆM',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextField(
            controller: _contentCtrl,
            maxLines: 5,
            style: TextStyle(color: cs.onSurface, fontSize: 13),
            onChanged: (v) => _vm.setContent(v),
            decoration: InputDecoration(
              hintText:
                  'Đường đi Tà Năng mùa này rất đẹp, cỏ xanh mướt...',
              hintStyle: TextStyle(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 13),
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
          Text('THÊM HÌNH ẢNH',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: Row(
              children: [
                // Add photo button
                GestureDetector(
                  onTap: () {/* pick image */},
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: cs.onSurface.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 22, color: cs.onSurfaceVariant),
                        const SizedBox(height: 4),
                        Text('+ Thêm ảnh',
                            style: TextStyle(
                                fontSize: 9,
                                color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                // Added photos
                ...List.generate(
                    _vm.imageLocalPaths.length > 2
                        ? 2
                        : _vm.imageLocalPaths.length, (i) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(_vm.imageLocalPaths[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Anonymous toggle ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
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
                            color: cs.onSurface),
                      ),
                      Text(
                        'Tên bạn sẽ không hiện thị công khai',
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _vm.isAnonymous,
                  onChanged: (_) {
                    _vm.toggleAnonymous();
                    setState(() {});
                  },
                  activeThumbColor: const Color(0xFFE8620A),
                  activeTrackColor:
                      const Color(0xFFE8620A).withValues(alpha: 0.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          TrekkingPrimaryButton(
            label: 'Gửi đánh giá',
            loading: isLoading,
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
