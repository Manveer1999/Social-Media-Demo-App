class StoryUpload {
  final String id;
  String mediaPath;
  String mediaType; // 'image' or 'video'
  String textOverlay;
  String selectedFilter;
  int duration;
  String visibility; // 'public', 'friends', 'private'

  StoryUpload({
    required this.id,
    this.mediaPath = '',
    this.mediaType = 'image',
    this.textOverlay = '',
    this.selectedFilter = 'none',
    this.duration = 5,
    this.visibility = 'public',
  });

  factory StoryUpload.fromJson(Map<String, dynamic> json) {
    return StoryUpload(
      id: json['id'],
      mediaPath: json['mediaPath'] ?? '',
      mediaType: json['mediaType'] ?? 'image',
      textOverlay: json['textOverlay'] ?? '',
      selectedFilter: json['selectedFilter'] ?? 'none',
      duration: json['duration'] ?? 5,
      visibility: json['visibility'] ?? 'public',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaPath': mediaPath,
      'mediaType': mediaType,
      'textOverlay': textOverlay,
      'selectedFilter': selectedFilter,
      'duration': duration,
      'visibility': visibility,
    };
  }
} 