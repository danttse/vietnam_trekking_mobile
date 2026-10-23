import '../models/comment_model.dart';

class CommentSampleData {
  static List<CommentModel> getSampleComments() {
    final now = DateTime.now();

    return [
      // ==========================================
      // COMMENTS CHO BÀI VIẾT: post_001 (Fansipan)
      // ==========================================
      // 1. Thread 1: Hoàng Nam
      CommentModel(
        id: 'cmt_001',
        postId: 'post_001',
        userId: 'user_005',
        userName: 'Hoàng Nam',
        userAvatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        content:
            'Cung đường tuyệt vời! Cảnh mây lúc bình minh từ đỉnh Fansipan thực sự không bút nào tả xiết.',
        parentCommentId: null,
        rootCommentId: null,
        replyToUserName: null,
        likeCount: 5,
        isLiked: true,
        replyCount: 2,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
      ),
      // Rep cấp 1 cho Hoàng Nam
      CommentModel(
        id: 'cmt_002',
        postId: 'post_001',
        userId: 'user_006',
        userName: 'Minh Trí',
        userAvatar:
            'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
        content: 'Bạn đi cung Trạm Tôn hay Cát Cát vậy bạn?',
        parentCommentId: 'cmt_001',
        rootCommentId: 'cmt_001',
        replyToUserName: 'Hoàng Nam',
        likeCount: 1,
        isLiked: false,
        replyCount: 0,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 20)),
      ),
      // Rep trung gian: Hoàng Nam trả lời Minh Trí trong thread cmt_001
      CommentModel(
        id: 'cmt_003',
        postId: 'post_001',
        userId: 'user_005',
        userName: 'Hoàng Nam',
        userAvatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        content:
            'Mình đi cung Trạm Tôn 2 ngày 1 đêm nha, đường leo khá thoáng và an toàn.',
        parentCommentId: 'cmt_002',
        rootCommentId: 'cmt_001',
        replyToUserName: 'Minh Trí',
        likeCount: 2,
        isLiked: false,
        replyCount: 0,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),

      // 2. Thread 2: Thu Hà
      CommentModel(
        id: 'cmt_004',
        postId: 'post_001',
        userId: 'user_007',
        userName: 'Thu Hà',
        userAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        content: 'Ảnh chụp xuất sắc quá bạn ơi! Có cần thuê porter không ạ?',
        parentCommentId: null,
        rootCommentId: null,
        replyToUserName: null,
        likeCount: 3,
        isLiked: false,
        replyCount: 1,
        createdAt: now.subtract(const Duration(minutes: 50)),
      ),
      // Rep cấp 1: Tác giả bài viết Lan Phương trả lời Thu Hà
      CommentModel(
        id: 'cmt_005',
        postId: 'post_001',
        userId: 'user_001',
        userName: 'Lan Phương',
        userAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
        content:
            'Nên thuê porter để mang đồ nặng nha bạn, leo sẽ đỡ mất sức và an toàn hơn nhiều á.',
        parentCommentId: 'cmt_004',
        rootCommentId: 'cmt_004',
        replyToUserName: 'Thu Hà',
        likeCount: 4,
        isLiked: true,
        replyCount: 0,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),

      // ==========================================
      // COMMENTS CHO BÀI VIẾT: post_002 (Hà Giang Loop)
      // ==========================================
      // 1. Thread 1: Quốc Bảo
      CommentModel(
        id: 'cmt_006',
        postId: 'post_002',
        userId: 'user_008',
        userName: 'Quốc Bảo',
        userAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        content:
            'Đoạn đèo Mã Pí Lèng đang làm đường hay thông thoáng rồi vậy bác?',
        parentCommentId: null,
        rootCommentId: null,
        replyToUserName: null,
        likeCount: 2,
        isLiked: false,
        replyCount: 2,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      // Rep cấp 1: Đức Anh trả lời Quốc Bảo
      CommentModel(
        id: 'cmt_007',
        postId: 'post_002',
        userId: 'user_002',
        userName: 'Đức Anh',
        userAvatar:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQF-1aVnj0A5dJG-wpOKVBfGc1VlGYb2ExaP-RU35FTHg&s',
        content: 'Đường đi ngon lành rồi nhé bạn, chỉ có sương mù lúc sáng sớm thôi.',
        parentCommentId: 'cmt_006',
        rootCommentId: 'cmt_006',
        replyToUserName: 'Quốc Bảo',
        likeCount: 3,
        isLiked: false,
        replyCount: 0,
        createdAt: now.subtract(const Duration(hours: 3, minutes: 30)),
      ),
      // Rep trung gian: Quốc Bảo cảm ơn Đức Anh
      CommentModel(
        id: 'cmt_008',
        postId: 'post_002',
        userId: 'user_008',
        userName: 'Quốc Bảo',
        userAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        content: 'Cảm ơn bác nhiều nhé, cuối tuần này team mình xuất phát!',
        parentCommentId: 'cmt_007',
        rootCommentId: 'cmt_006',
        replyToUserName: 'Đức Anh',
        likeCount: 1,
        isLiked: true,
        replyCount: 0,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),

      // ==========================================
      // COMMENTS CHO BÀI VIẾT: post_003 (Tà Xùa Săn Mây)
      // ==========================================
      CommentModel(
        id: 'cmt_009',
        postId: 'post_003',
        userId: 'user_009',
        userName: 'Thanh Thảo',
        userAvatar:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        content:
            'Sống lưng khủng long gió có to lắm không bạn? Nhìn ảnh mây trôi mê mẩn thật sự!',
        parentCommentId: null,
        rootCommentId: null,
        replyToUserName: null,
        likeCount: 8,
        isLiked: true,
        replyCount: 1,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      CommentModel(
        id: 'cmt_010',
        postId: 'post_003',
        userId: 'user_003',
        userName: 'Nam Hải',
        userAvatar:
            'https://ik.imagekit.io/tvlk/blog/2023/04/go-and-share-san-may-ta-xua-7.jpeg',
        content:
            'Sáng sớm gió khá lạnh và mạnh, bạn nhớ đi giày bám tốt và đừng đi quá sát mép dốc nhé.',
        parentCommentId: 'cmt_009',
        rootCommentId: 'cmt_009',
        replyToUserName: 'Thanh Thảo',
        likeCount: 6,
        isLiked: false,
        replyCount: 0,
        createdAt: now.subtract(const Duration(hours: 16)),
      ),

      // ==========================================
      // COMMENTS CHO BÀI VIẾT: post_004 (Putaleng)
      // ==========================================
      CommentModel(
        id: 'cmt_011',
        postId: 'post_004',
        userId: 'user_010',
        userName: 'Tuấn Hưng',
        userAvatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        content: 'Chúc mừng bạn! Putaleng nổi tiếng dốc gắt, quá nể phục luôn.',
        parentCommentId: null,
        rootCommentId: null,
        replyToUserName: null,
        likeCount: 4,
        isLiked: false,
        replyCount: 0,
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      ),
    ];
  }

  /// Lấy danh sách bình luận theo postId
  static List<CommentModel> getCommentsByPostId(String postId) {
    return getSampleComments()
        .where((comment) => comment.postId == postId)
        .toList();
  }
}
