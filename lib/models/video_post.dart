class VideoPost {
  final String id;
  final String userAvatar;
  final String username;
  final String videoThumbnail;
  final String caption;
  int likeCount;
  final int commentCount;
  final DateTime timestamp;
  bool isLiked;

  VideoPost({
    required this.id,
    required this.userAvatar,
    required this.username,
    required this.videoThumbnail,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.timestamp,
    this.isLiked = false,
  });

  factory VideoPost.fromJson(Map<String, dynamic> json) {
    return VideoPost(
      id: json['id'],
      userAvatar: json['userAvatar'],
      username: json['username'],
      videoThumbnail: json['videoThumbnail'],
      caption: json['caption'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      timestamp: DateTime.parse(json['timestamp']),
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userAvatar': userAvatar,
      'username': username,
      'videoThumbnail': videoThumbnail,
      'caption': caption,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'timestamp': timestamp.toIso8601String(),
      'isLiked': isLiked,
    };
  }
} 