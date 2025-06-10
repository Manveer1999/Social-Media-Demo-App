import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../models/video_post.dart';
import '../services/mock_data_service.dart';

class VideoPostController extends GetxController {
  var posts = <VideoPost>[].obs;
  var isLoading = false.obs;
  var currentVideoIndex = 0.obs;
  var isPlaying = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var currentPostId = ''.obs;
  
  // Video player controllers for each post
  final Map<String, VideoPlayerController> _videoControllers = {};
  VideoPlayerController? get currentVideoController => 
      _videoControllers[getCurrentPost()?.id];
  
  VideoPlayerController? getVideoController(String postId) =>
      _videoControllers[postId];

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      isLoading(true);
      hasError(false);
      
      final videoPosts = await MockDataService.getVideoPosts();
      posts.assignAll(videoPosts);
      
      // Set initial current post ID
      if (posts.isNotEmpty) {
        currentPostId(posts[0].id);
      }
      
      // Initialize video controllers for each post
      _initializeVideoControllers();
    } catch (e) {
      hasError(true);
      errorMessage('Failed to load posts: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void _initializeVideoControllers() {
    final List<String> workingVideoUrls = [
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    ];
    
    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      if (!_videoControllers.containsKey(post.id)) {
        // Use different video URLs for variety
        final videoUrl = workingVideoUrls[i % workingVideoUrls.length];
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
        _videoControllers[post.id] = controller;
        
        // Initialize the controller
        controller.initialize().then((_) {
          controller.setLooping(true);
          // Auto-play the first video (index 0) when it's ready
          if (i == 0) {
            controller.play();
            isPlaying(true);
          }
        });
      }
    }
  }

  void toggleLike(String postId) {
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = posts[postIndex];
      post.isLiked = !post.isLiked;
      
      if (post.isLiked) {
        post.likeCount++;
      } else {
        post.likeCount--;
      }
      
      posts[postIndex] = post;
      posts.refresh();
    }
  }

  void playVideo(int index) {
    // Pause current video
    currentVideoController?.pause();
    
    // Update index and current post ID
    currentVideoIndex(index);
    final newPost = getCurrentPost();
    if (newPost != null) {
      currentPostId(newPost.id);
    }
    
    // Play new video
    final newController = _videoControllers[getCurrentPost()?.id];
    if (newController != null && newController.value.isInitialized) {
      newController.play();
      isPlaying(true);
    }
  }

  void pauseVideo() {
    currentVideoController?.pause();
    isPlaying(false);
  }

  void togglePlayPause() {
    final controller = currentVideoController;
    if (controller != null && controller.value.isInitialized) {
      if (isPlaying.value) {
        controller.pause();
        isPlaying(false);
      } else {
        controller.play();
        isPlaying(true);
      }
    }
  }

  void nextVideo() {
    if (currentVideoIndex.value < posts.length - 1) {
      currentVideoIndex(currentVideoIndex.value + 1);
    }
  }

  void previousVideo() {
    if (currentVideoIndex.value > 0) {
      currentVideoIndex(currentVideoIndex.value - 1);
    }
  }

  void sharePost(String postId) {
    // Mock share functionality
    Get.snackbar(
      'video_post_share'.tr,
      'Post shared successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openComments(String postId) {
    // Navigate to comments page (mock)
    Get.snackbar(
      'video_post_comment'.tr,
      'Comments feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }

  String formatLikesCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  String formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  VideoPost? getCurrentPost() {
    if (posts.isNotEmpty && currentVideoIndex.value < posts.length) {
      return posts[currentVideoIndex.value];
    }
    return null;
  }

  void addNewPost(VideoPost post) {
    posts.insert(0, post);
    posts.refresh();
    
    // Update current post ID to the new post (move to top)
    currentVideoIndex(0);
    currentPostId(post.id);
    
    // Initialize video controller for the new post
    _initializeVideoControllerForPost(post);
  }

  void _initializeVideoControllerForPost(VideoPost post) {
    if (!_videoControllers.containsKey(post.id)) {
      // For uploaded content, we'll use a working placeholder video since it's mock data
      final controller = VideoPlayerController.networkUrl(
        Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
      );
      _videoControllers[post.id] = controller;
      
      controller.initialize().then((_) {
        controller.setLooping(true);
        // Auto-play if this is the current video
        if (post.id == getCurrentPost()?.id && isPlaying.value) {
          controller.play();
        }
      });
    }
  }

  @override
  void onClose() {
    // Dispose all video controllers
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.onClose();
  }
} 