import 'package:get/get.dart';
import '../models/story_upload.dart';
import '../models/video_post.dart';
import '../services/mock_data_service.dart';
import '../controllers/video_post_controller.dart';

class StoryUploadController extends GetxController {
  var currentStory = Rx<StoryUpload?>(null);
  var isUploading = false.obs;
  var uploadProgress = 0.0.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  var availableFilters = <String>[].obs;
  var availableTemplates = <String>[].obs;
  var visibilityOptions = <String>[].obs;
  var selectedFilter = 'none'.obs;
  var selectedTemplate = 'simple'.obs;
  var selectedVisibility = 'public'.obs;
  var storyDuration = 5.obs;
  var textOverlay = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOptions();
    _initializeNewStory();
  }

  void _loadOptions() {
    availableFilters.assignAll(MockDataService.getStoryFilters());
    visibilityOptions.assignAll(MockDataService.getVisibilityOptions());
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await MockDataService.getStoryTemplates();
      availableTemplates.assignAll(templates);
    } catch (e) {
      print('Error loading templates: $e');
    }
  }

  void _initializeNewStory() {
    currentStory.value = StoryUpload(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  void selectMediaFromCamera() {
    // Mock camera functionality
    if (currentStory.value != null) {
      currentStory.value!.mediaPath = 'camera_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      currentStory.value!.mediaType = 'image';
      currentStory.refresh();
    }
    
    Get.snackbar(
      'story_upload_camera'.tr,
      'Photo captured from camera',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void selectMediaFromGallery() {
    // Mock gallery functionality
    if (currentStory.value != null) {
      currentStory.value!.mediaPath = 'gallery_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      currentStory.value!.mediaType = 'image';
      currentStory.refresh();
    }
    
    Get.snackbar(
      'story_upload_gallery'.tr,
      'Photo selected from gallery',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void selectFilter(String filter) {
    selectedFilter(filter);
    if (currentStory.value != null) {
      currentStory.value!.selectedFilter = filter;
      currentStory.refresh();
    }
  }

  void selectTemplate(String template) {
    selectedTemplate(template);
  }

  void selectVisibility(String visibility) {
    selectedVisibility(visibility);
    if (currentStory.value != null) {
      currentStory.value!.visibility = visibility;
      currentStory.refresh();
    }
  }

  void updateDuration(int duration) {
    storyDuration(duration);
    if (currentStory.value != null) {
      currentStory.value!.duration = duration;
      currentStory.refresh();
    }
  }

  void updateTextOverlay(String text) {
    textOverlay(text);
    if (currentStory.value != null) {
      currentStory.value!.textOverlay = text;
      currentStory.refresh();
    }
  }

  Future<void> uploadStory() async {
    if (currentStory.value == null || currentStory.value!.mediaPath.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select a photo or video first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isUploading(true);
      hasError(false);
      uploadProgress(0.0);

      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        uploadProgress(i / 100);
      }

      final result = await MockDataService.uploadStory(currentStory.value!);
      
      if (result['success']) {
        // Create a new video post from the uploaded story
        final newVideoPost = VideoPost(
          id: currentStory.value!.id,
          username: 'currentUser', // Replace with actual current user
          userAvatar: 'https://i.pravatar.cc/150?img=1', // Replace with actual user avatar
          videoThumbnail: 'https://i.pravatar.cc/300?img=5', // Use placeholder thumbnail URL
          caption: currentStory.value!.textOverlay.isNotEmpty 
              ? currentStory.value!.textOverlay 
              : 'New post uploaded!',
          likeCount: 0,
          commentCount: 0,
          timestamp: DateTime.now(),
          isLiked: false,
        );

        // Add to video posts if the controller exists
        try {
          final videoController = Get.find<VideoPostController>();
          videoController.addNewPost(newVideoPost);
        } catch (e) {
          print('VideoPostController not found: $e');
        }

        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Reset for new story
        _initializeNewStory();
        resetForm();
        
        // Navigate back or to stories page
        Get.back();
      } else {
        throw Exception(result['message'] ?? 'Upload failed');
      }
    } catch (e) {
      hasError(true);
      errorMessage('Upload failed: ${e.toString()}');
      Get.snackbar(
        'error'.tr,
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading(false);
      uploadProgress(0.0);
    }
  }

  void resetForm() {
    selectedFilter('none');
    selectedTemplate('simple');
    selectedVisibility('public');
    storyDuration(5);
    textOverlay('');
    uploadProgress(0.0);
    hasError(false);
    errorMessage('');
  }

  void cancelUpload() {
    if (isUploading.value) {
      isUploading(false);
      uploadProgress(0.0);
    }
    
    resetForm();
    Get.back();
  }

  bool get canUpload =>
      currentStory.value != null &&
      currentStory.value!.mediaPath.isNotEmpty &&
      !isUploading.value;

  String get filterDisplayName {
    final filter = selectedFilter.value;
    switch (filter) {
      case 'none':
        return 'Original';
      case 'black_white':
        return 'B&W';
      case 'vintage':
        return 'Vintage';
      case 'sepia':
        return 'Sepia';
      case 'cool':
        return 'Cool';
      case 'warm':
        return 'Warm';
      case 'bright':
        return 'Bright';
      case 'contrast':
        return 'Contrast';
      default:
        return filter.toUpperCase();
    }
  }

  String get visibilityDisplayName {
    final visibility = selectedVisibility.value;
    switch (visibility) {
      case 'public':
        return 'story_upload_public'.tr;
      case 'friends':
        return 'story_upload_friends'.tr;
      case 'private':
        return 'story_upload_private'.tr;
      default:
        return visibility;
    }
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
} 