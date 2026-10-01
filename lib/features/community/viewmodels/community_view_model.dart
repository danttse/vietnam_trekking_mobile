import 'package:flutter/material.dart';
import '../data/datasources/post_sample_data.dart';
import '../data/models/post_model.dart';

class CommunityViewModel extends ChangeNotifier {
  int _selectedTab = 0;
  List<PostModel> _posts = [];
  final Set<String> _hiddenPostIds = {};
  bool _isLoading = false;
  CommunityViewModel() {
    loadPosts();
  }
  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  Set<String> get hiddenPostIds => _hiddenPostIds;
  //cac bai viet ko bi an
  List<PostModel> get posts {
    final visiblePosts =
        _posts.where((post) => !_hiddenPostIds.contains(post.postId)).toList();
    if (_selectedTab == 0) {
      return visiblePosts;
    } else if (_selectedTab == 1) {
      return visiblePosts
          .where((post) =>
              post.type == 'JOURNEY_SHARE' || post.journeyId != null)
          .toList();
    } else {
      return visiblePosts
          .where((post) =>
              post.authorId == 'user_001' || post.type == 'BADGE_SHARE')
          .toList();
    }
  }
  void setTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
    }
  }
  void loadPosts() {
    _isLoading = true;
    notifyListeners();
    _posts = PostSampleData.getSamplePosts();
    _isLoading = false;
    notifyListeners();
  }
  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      final currentPost = _posts[index];
      final newIsLiked = !currentPost.isLiked;
      final newCount = newIsLiked
          ? currentPost.reactionCount + 1
          : (currentPost.reactionCount > 0
              ? currentPost.reactionCount - 1
              : 0);

      _posts[index] = currentPost.copyWith(
        isLiked: newIsLiked,
        reactionCount: newCount,
      );
      notifyListeners();
    }
  }
  void hidePost(String postId) {
    _hiddenPostIds.add(postId);
    notifyListeners();
  }
  void unhidePost(String postId) {
    _hiddenPostIds.remove(postId);
    notifyListeners();
  }
  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }
}
