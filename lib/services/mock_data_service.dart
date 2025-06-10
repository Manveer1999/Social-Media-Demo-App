import '../models/video_post.dart';
import '../models/user_profile.dart';
import '../models/story_upload.dart';
import '../models/payment_details.dart';

class MockDataService {
  static Future<List<VideoPost>> getVideoPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      VideoPost(
        id: '1',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        username: 'johndoe',
        videoThumbnail: 'https://picsum.photos/300/400?random=1',
        caption: 'Amazing sunset at the beach! 🌅 #sunset #beach #nature',
        likeCount: 1234,
        commentCount: 67,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isLiked: false,
      ),
      VideoPost(
        id: '2',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        username: 'janesmit',
        videoThumbnail: 'https://picsum.photos/300/400?random=2',
        caption: 'Cooking my favorite pasta recipe 🍝 Who wants the recipe?',
        likeCount: 2567,
        commentCount: 123,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isLiked: true,
      ),
      VideoPost(
        id: '3',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        username: 'mikejohnson',
        videoThumbnail: 'https://picsum.photos/300/400?random=3',
        caption: 'Morning workout session 💪 #fitness #motivation #gym',
        likeCount: 890,
        commentCount: 45,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        isLiked: false,
      ),
      VideoPost(
        id: '4',
        userAvatar: 'https://i.pravatar.cc/150?img=4',
        username: 'sarahwilson',
        videoThumbnail: 'https://picsum.photos/300/400?random=4',
        caption: 'Art process video 🎨 Creating something beautiful today!',
        likeCount: 3456,
        commentCount: 234,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isLiked: true,
      ),
      VideoPost(
        id: '5',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        username: 'davidlee',
        videoThumbnail: 'https://picsum.photos/300/400?random=5',
        caption: 'Travel vlog from Tokyo 🗾 Such an amazing city! #travel #tokyo',
        likeCount: 5678,
        commentCount: 389,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isLiked: false,
      ),
    ];
  }

  static Future<UserProfile> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final posts = await getVideoPosts();

    return UserProfile(
      userId: userId,
      profilePicture: 'https://i.pravatar.cc/200?img=10',
      username: 'johndoe',
      displayName: 'John Doe',
      bio: '📱 Mobile developer | 🎨 UI/UX enthusiast | 🌍 Travel lover\nBuilding amazing apps with Flutter 💙',
      followerCount: 12500,
      followingCount: 756,
      postCount: posts.length,
      posts: posts,
      storyHighlights: [
        'Travel',
        'Food',
        'Work',
        'Friends',
      ],
      socialLinks: [
        'https://twitter.com/johndoe',
        'https://linkedin.com/in/johndoe',
        'https://github.com/johndoe',
      ],
      achievements: [
        'Top Creator 2023',
        '1M Views',
        'Rising Star',
        'Community Builder',
      ],
    );
  }

  static List<String> getStoryFilters() {
    return [
      'none',
      'vintage',
      'black_white',
      'sepia',
      'cool',
      'warm',
      'bright',
      'contrast',
    ];
  }

  static List<String> getVisibilityOptions() {
    return [
      'public',
      'friends',
      'private',
    ];
  }

  static Future<PaymentDetails> getPaymentDetails(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return PaymentDetails(
      projectId: projectId,
      projectTitle: 'Premium Content Access',
      projectDescription: 'Unlock exclusive content and features including HD videos, ad-free experience, and premium filters.',
      price: 9.99,
    );
  }

  static List<String> getPaymentMethods() {
    return [
      'credit_card',
      'paypal',
      'google_pay',
      'apple_pay',
    ];
  }

  static Future<bool> processPayment(PaymentDetails paymentDetails) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));
    
    // Mock success rate of 90%
    return DateTime.now().millisecond % 10 < 9;
  }

  static Future<List<String>> getStoryTemplates() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return [
      'simple',
      'gradient',
      'photo_frame',
      'collage',
      'neon',
      'vintage',
      'minimal',
      'artistic',
    ];
  }

  static Future<Map<String, dynamic>> uploadStory(StoryUpload story) async {
    // Simulate upload process
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'storyId': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': 'Story uploaded successfully!',
    };
  }

  static Future<List<VideoPost>> searchPosts(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final allPosts = await getVideoPosts();
    
    if (query.isEmpty) return allPosts;
    
    return allPosts.where((post) =>
      post.caption.toLowerCase().contains(query.toLowerCase()) ||
      post.username.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Future<bool> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // Mock success
  }

  static Future<bool> followUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true; // Mock success
  }

  static Future<bool> unfollowUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true; // Mock success
  }
} 