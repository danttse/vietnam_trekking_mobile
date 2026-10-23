import 'package:flutter/material.dart';

import '../data/datasources/post_sample_data.dart';
import '../data/datasources/community_remote_datasource.dart';
import '../data/models/post_model.dart';
import '../../../core/network/api_error_handler.dart';

/// ViewModel for Community feature (posts, comments).
///
/// ⚠️ Currently uses sample data as fallback because Community Service backend
/// is not yet implemented. When backend is ready, uncomment API calls below.
class CommunityViewModel extends ChangeNotifier {
  int _selectedTab = 0;
  List<PostModel> _posts = [];
  final Set<String> _hiddenPostIds = {};
  bool _isLoading = false;
  String? _error;

  CommunityViewModel({CommunityRemoteDataSource? dataSource}) {
    loadPosts();
  }

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get hiddenPostIds => _hiddenPostIds;
  //cac bai viet ko bi an
  List<PostModel> get posts {
    final visiblePosts = _posts
        .where((post) => !_hiddenPostIds.contains(post.postId))
        .toList();
    if (_selectedTab == 0) {
      return visiblePosts;
    } else if (_selectedTab == 1) {
      return visiblePosts
          .where(
            (post) => post.type == 'JOURNEY_SHARE' || post.journeyId != null,
          )
          .toList();
    } else {
      return visiblePosts
          .where(
            (post) => post.authorId == 'user_001' || post.type == 'BADGE_SHARE',
          )
          .toList();
    }
  }

  void setTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
    }
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Uncomment when Community Service backend is ready
      // if (_dataSource != null) {
      //   final response = await _dataSource.getPosts(page: 1, limit: 50);
      //   _posts = response.items;
      // } else {
      //   _posts = PostSampleData.getSamplePosts();
      // }

      // TEMPORARY: Use sample data until backend is ready
      _posts = PostSampleData.getSamplePosts();
      _error = null;
    } catch (e) {
      _error = ApiErrorHandler.handle(e);
      // Fallback to sample data on error
      _posts = PostSampleData.getSamplePosts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.postId == postId);
    if (index == -1) return;

    final currentPost = _posts[index];
    final newIsLiked = !currentPost.isLiked;

    // Optimistic update
    final newCount = newIsLiked
        ? currentPost.reactionCount + 1
        : (currentPost.reactionCount > 0 ? currentPost.reactionCount - 1 : 0);

    _posts[index] = currentPost.copyWith(
      isLiked: newIsLiked,
      reactionCount: newCount,
    );
    notifyListeners();

    // TODO: Uncomment when Community Service backend is ready
    // try {
    //   if (_dataSource != null) {
    //     if (newIsLiked) {
    //       await _dataSource.likePost(postId);
    //     } else {
    //       await _dataSource.unlikePost(postId);
    //     }
    //   }
    // } catch (e) {
    //   // Revert on error
    //   _posts[index] = currentPost;
    //   notifyListeners();
    //   _error = ApiErrorHandler.handle(e);
    // }
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
