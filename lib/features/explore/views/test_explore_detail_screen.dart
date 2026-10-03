// ============================================================
// [TEST-ONLY] test_explore_detail_screen.dart
//
// Màn hình này được tạo TẠM THỜI để test backend trước khi
// dev frontend hoàn thiện màn hình chính thức.
//
// KHI PULL CODE DEV FRONTEND VỀ:
//   1. Xóa file này: lib/features/explore/views/test_explore_detail_screen.dart
//   2. Xóa import và đoạn điều hướng trong UserNavigationScreen
//      (tìm comment // [TEST-ONLY] để định vị nhanh)
//
// Tìm nhanh tất cả chỗ cần dọn: grep -r "TEST-ONLY" lib/
// ============================================================

import 'package:flutter/material.dart';
import '../data/models/explore_place_model.dart';

// ---------------------------------------------------------------------------
// Model dữ liệu tạm – sẽ được thay bằng API response thực từ backend
// ---------------------------------------------------------------------------

/// [TEST-ONLY] Điểm dừng trên lộ trình
class _TestItineraryStop {
  final String name;
  final String elevation;
  final String description;

  const _TestItineraryStop({
    required this.name,
    required this.elevation,
    required this.description,
  });
}

/// [TEST-ONLY] Đánh giá trekker
class _TestReview {
  final String userName;
  final double rating;
  final String comment;
  final String timeAgo;
  final String avatarUrl;

  const _TestReview({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    required this.avatarUrl,
  });
}

// ---------------------------------------------------------------------------
// Dữ liệu mock tĩnh – thay bằng API call khi backend sẵn sàng
// ---------------------------------------------------------------------------

class _TestMockData {
  static const description =
      'Hành trình chinh phục Nóc nhà Đông Dương ở độ cao 3,143m đầy thách thức nhưng cũng cảm xúc đỉnh. '
      'Bạn sẽ đi qua những cánh rừng làng mây, vượt qua những thử thách và thường '
      'xuyên được đắm mình vào thiên nhiên hùng vĩ tràn trề cảm xúc rừng rú mỗi ngày mỗi ngắn.';

  static const itinerary = <_TestItineraryStop>[
    _TestItineraryStop(
      name: 'Trạm Tôn (1,900m)',
      elevation: '1,900m',
      description:
          'Điểm xuất phát, nghỉ ngơi lấy sức nhẹ nhàng như những rừng trúc.',
    ),
    _TestItineraryStop(
      name: 'Điểm ngủ (2,200m)',
      elevation: '2,200m',
      description:
          'Bắt đầu xuất phát hôm nay sức lạ chống lạc đó thêm hiệm má.',
    ),
    _TestItineraryStop(
      name: 'Lán ngủ đêm (2,800m)',
      elevation: '2,800m',
      description:
          'Căm trại, ăn tối và ngắm sao giữa màn trời Sapa.',
    ),
    _TestItineraryStop(
      name: 'Đỉnh Fansipan (3,143m)',
      elevation: '3,143m',
      description:
          'Nơi nhìn vào chân trời huyền thoại đánh bại bình minh rừng rú.',
    ),
  ];

  static const reviews = <_TestReview>[
    _TestReview(
      userName: 'Hoàng Nam',
      rating: 5.0,
      comment:
          'Cung đường tuyệt vời! Cảnh mây lúc sáng sớm tuyệt đẹp mình tới đỉnh mặc dù mình không đi bộ nhiều. Chuyến đi thực sự đáng nhớ!',
      timeAgo: '2 ngày trước',
      avatarUrl:
          'https://i.pravatar.cc/150?img=12',
    ),
    _TestReview(
      userName: 'Thùy Trang',
      rating: 4.6,
      comment:
          'Đoạn leo đà 2,800m tới lán ngủ hơi khó leo tốn sức. Nên chuẩn bị tốt trước khi tới để không bị sốc độ cao.',
      timeAgo: '5 ngày trước',
      avatarUrl:
          'https://i.pravatar.cc/150?img=47',
    ),
  ];
}

// ---------------------------------------------------------------------------
// [TEST-ONLY] Màn hình chi tiết Explore
// ---------------------------------------------------------------------------

class TestExploreDetailScreen extends StatelessWidget {
  final ExplorePlaceModel place;

  const TestExploreDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Nội dung cuộn ──────────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroHeader(place: place),
                _InfoSection(place: place),
                const _Divider(),
                _DescriptionSection(),
                const _Divider(),
                _ItinerarySection(),
                const _Divider(),
                _MapPlaceholder(),
                const _Divider(),
                _ReviewsSection(),
                const SizedBox(height: 100), // space for FAB
              ],
            ),
          ),

          // ── Nút quay lại nổi ───────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _BackButton(),
          ),

          // ── Nút yêu thích nổi ──────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: _FavoriteButton(),
          ),

          // ── Nút "Tạo hành trình" dính dưới ────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActionBar(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero – ảnh + badge + tên nhỏ phía dưới ảnh
// ---------------------------------------------------------------------------

class _HeroHeader extends StatelessWidget {
  final ExplorePlaceModel place;
  const _HeroHeader({required this.place});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ảnh header cao 220
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                place.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.image_outlined,
                      color: cs.onSurfaceVariant, size: 48),
                ),
              ),
              // Gradient nhẹ phía dưới ảnh
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
              // Badge tag (e.g. "Khó")
              if (place.tag != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      place.tag!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Rating badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Thông tin nhỏ dưới ảnh (3 tabs text + tên mini)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _MiniChip(
                      icon: Icons.people_outline,
                      label: '${place.reviewCount} đánh giá'),
                  const SizedBox(width: 8),
                  _MiniChip(
                      icon: Icons.straighten_outlined, label: place.distance),
                  const SizedBox(width: 8),
                  _MiniChip(
                      icon: Icons.location_on_outlined,
                      label: place.province),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tên tour + rating lớn + thống kê
// ---------------------------------------------------------------------------

class _InfoSection extends StatelessWidget {
  final ExplorePlaceModel place;
  const _InfoSection({required this.place});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge độ khó
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _difficultyColor(place.difficulty)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              place.difficulty,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _difficultyColor(place.difficulty),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Tên tour
          Text(
            place.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),

          // Tỉnh
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: cs.primary),
              const SizedBox(width: 4),
              Text(
                '${place.province}, Việt Nam',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _StatItem(
                  icon: Icons.straighten_outlined,
                  value: place.distance,
                  label: 'Cự ly',
                ),
                _VerticalDivider(),
                _StatItem(
                  icon: Icons.schedule_outlined,
                  value: place.duration,
                  label: 'Thời gian',
                ),
                _VerticalDivider(),
                _StatItem(
                  icon: Icons.terrain_outlined,
                  value: place.elevation,
                  label: 'Đỉnh cao',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Dễ':
        return const Color(0xFF207335);
      case 'Trung bình':
      case 'Vừa':
        return const Color(0xFFf59e0b);
      case 'Khó':
        return const Color(0xFFef4444);
      case 'Rất khó':
        return const Color(0xFF991b1b);
      default:
        return const Color(0xFFf59e0b);
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 36,
      color: cs.onSurfaceVariant.withValues(alpha: 0.15),
    );
  }
}

// ---------------------------------------------------------------------------
// Giới thiệu
// ---------------------------------------------------------------------------

class _DescriptionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'GIỚI THIỆU'),
          const SizedBox(height: 10),
          Text(
            _TestMockData.description,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.75),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lộ trình
// ---------------------------------------------------------------------------

class _ItinerarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'LỘ TRÌNH CHÍNH'),
          const SizedBox(height: 14),
          ...List.generate(_TestMockData.itinerary.length, (i) {
            final stop = _TestMockData.itinerary[i];
            final isLast = i == _TestMockData.itinerary.length - 1;
            return _ItineraryStopTile(stop: stop, index: i + 1, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _ItineraryStopTile extends StatelessWidget {
  final _TestItineraryStop stop;
  final int index;
  final bool isLast;

  const _ItineraryStopTile({
    required this.stop,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Số thứ tự + đường kẻ dọc
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: cs.primary.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Nội dung
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stop.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bản đồ lộ trình (placeholder – thay bằng flutter_map / google_maps sau)
// ---------------------------------------------------------------------------

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'BẢN ĐỒ LỘ TRÌNH'),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 180,
              width: double.infinity,
              color: cs.surfaceContainerHighest,
              child: Stack(
                children: [
                  // Ảnh bản đồ demo
                  Image.network(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                  ),
                  // Overlay nhẹ
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.map_outlined,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Xem bản đồ đầy đủ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Đánh giá Trekkers
// ---------------------------------------------------------------------------

class _ReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'ĐÁNH GIÁ TỪ TREKKERS'),
          const SizedBox(height: 12),
          ..._TestMockData.reviews
              .map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ReviewCard(review: r),
                  )),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _TestReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + tên + rating
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(review.avatarUrl),
                backgroundColor: cs.surfaceContainerHighest,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      review.timeAgo,
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Rating
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Colors.amber, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.75),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom action bar – nút "Tạo hành trình"
// ---------------------------------------------------------------------------

class _BottomActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: kết nối API tạo hành trình từ backend
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('[TEST] Tính năng đang chờ backend'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text(
            'Tạo hành trình',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nút quay lại nổi
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nút yêu thích nổi
// ---------------------------------------------------------------------------

class _FavoriteButton extends StatefulWidget {
  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _liked = !_liked),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _liked ? Colors.redAccent : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: cs.onSurface.withValues(alpha: 0.55),
        letterSpacing: 0.6,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 1,
      color: cs.onSurfaceVariant.withValues(alpha: 0.1),
    );
  }
}
