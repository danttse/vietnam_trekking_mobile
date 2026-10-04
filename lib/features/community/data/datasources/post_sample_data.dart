import '../models/post_model.dart';

class PostSampleData {
  static List<PostModel> getSamplePosts() {
    final now = DateTime.now();

    return [
      PostModel(
        postId: 'post_001',
        authorId: 'user_001',
        authorName: 'Lan Phương',
        authorAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
        content:
            'Mới hoàn thành chuyến chinh phục đỉnh Fansipan sáng nay! Thời tiết cực đẹp, biển mây ngập tràn. Mệt nhưng vô cùng xứng đáng!',
        images: const [
          'https://www.vietnambooking.com/wp-content/uploads/2018/12/doc-mien-dat-nuoc-chiem-nguong-canh-dep-viet-nam-19122018-3.jpg',
        ],
        type: 'NORMAL',
        trekkingPlaceId: 'place_fansipan',
        reactionCount: 124,
        commentCount: 32,
        isLiked: false,
        visibility: 'PUBLIC',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      PostModel(
        postId: 'post_002',
        authorId: 'user_002',
        authorName: 'Đức Anh',
        authorAvatar:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQF-1aVnj0A5dJG-wpOKVBfGc1VlGYb2ExaP-RU35FTHg&s',
        content:
            'Một vài kinh nghiệm xương máu cho các bạn đi Hà Giang Loop tự túc lần đầu: Nhớ chuẩn bị giáp bảo hộ đầy đủ và check kỹ lốp xe trước khi leo đèo nhé.',
        images: const [
          'https://bizweb.dktcdn.net/100/453/654/files/sapa.jpg?v=1655971221589'
        ],
        type: 'NORMAL',
        trekkingPlaceId: 'place_hagiang',
        reactionCount: 89,
        commentCount: 15,
        isLiked: false,
        visibility: 'PUBLIC',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      PostModel(
        postId: 'post_003',
        authorId: 'user_003',
        authorName: 'Nam Hải',
        authorAvatar:
            'https://ik.imagekit.io/tvlk/blog/2023/04/go-and-share-san-may-ta-xua-7.jpeg',
        content:
            'Tà Xùa mùa săn mây tuyệt đẹp! Đứng trên sống lưng khủng long ngắm bình minh mây cuộn cuộn dưới thung lũng, cảm giác như lạc vào cõi tiên.',
        images: const [
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRejOYK7vK2QlLyYWXTpRd4d22muBh1MBb_hoXO_7MCYjguseH4e2BjTxoQ&s=10',
          'https://storage.googleapis.com/blogvxr-uploads/2026/02/0d4fa2ae-du-lich-ta-xua-2-ngay-1-dem-2242886-1250x715.jpg',
          'https://vov4.vov.vn/sites/default/files/styles/large/public/2023-12/z4947662991547_0dc72032ad508e18c108cba0b9ec4021.jpg',
        ],
        type: 'JOURNEY_SHARE',
        journeyId: 'journey_taxua_2026',
        trekkingPlaceId: 'place_taxua',
        reactionCount: 256,
        commentCount: 48,
        isLiked: true,
        visibility: 'PUBLIC',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      PostModel(
        postId: 'post_004',
        authorId: 'user_004',
        authorName: 'Minh Trang',
        authorAvatar:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0WQfg-sug1KYGqAaYeqblfN0bCZ6rgbJEK-mZ6vBOfTfjvbqjY4bYXe4&s=10',
        content:
            'Vừa nhận được huy hiệu "Chinh phục Putaleng 3049m". Hành trình 3 ngày 2 đêm vượt qua những con suối và dốc đá dựng đứng đã tôi luyện bản lĩnh!',
        images: const [
          'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1510312305653-8ed496efae75?auto=format&fit=crop&w=800&q=80',
        ],
        type: 'BADGE_SHARE',
        reactionCount: 178,
        commentCount: 29,
        isLiked: false,
        visibility: 'PUBLIC',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
