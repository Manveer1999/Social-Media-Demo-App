import 'video_post.dart';

class UserProfile {
  final String userId;
  String profilePicture;
  String username;
  String displayName;
  String bio;
  int followerCount;
  int followingCount;
  int postCount;
  List<VideoPost> posts;
  List<String> storyHighlights;
  List<String> socialLinks;
  List<String> achievements;

  UserProfile({
    required this.userId,
    this.profilePicture = '',
    required this.username,
    required this.displayName,
    this.bio = '',
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.posts = const [],
    this.storyHighlights = const [],
    this.socialLinks = const [],
    this.achievements = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      profilePicture: json['profilePicture'] ?? '',
      username: json['username'],
      displayName: json['displayName'],
      bio: json['bio'] ?? '',
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      posts: (json['posts'] as List?)
          ?.map((post) => VideoPost.fromJson(post))
          .toList() ?? [],
      storyHighlights: List<String>.from(json['storyHighlights'] ?? []),
      socialLinks: List<String>.from(json['socialLinks'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profilePicture': profilePicture,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'posts': posts.map((post) => post.toJson()).toList(),
      'storyHighlights': storyHighlights,
      'socialLinks': socialLinks,
      'achievements': achievements,
    };
  }
} 