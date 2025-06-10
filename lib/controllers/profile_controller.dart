import 'package:get/get.dart';
import '../models/user_profile.dart';
import '../services/mock_data_service.dart';

class ProfileController extends GetxController {
  var userProfile = Rx<UserProfile?>(null);
  var isLoading = false.obs;
  var isEditing = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var selectedTab = 0.obs; // 0: Posts, 1: Stories, 2: Saved
  
  // Edit profile fields
  var editingDisplayName = ''.obs;
  var editingBio = ''.obs;
  var editingProfilePicture = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile([String? userId]) async {
    try {
      isLoading(true);
      hasError(false);
      
      final profile = await MockDataService.getUserProfile(userId ?? 'current_user');
      userProfile(profile);
      
      // Initialize editing fields
      editingDisplayName(profile.displayName);
      editingBio(profile.bio);
      editingProfilePicture(profile.profilePicture);
    } catch (e) {
      hasError(true);
      errorMessage('Failed to load profile: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void selectTab(int index) {
    selectedTab(index);
  }

  void startEditing() {
    isEditing(true);
    if (userProfile.value != null) {
      editingDisplayName(userProfile.value!.displayName);
      editingBio(userProfile.value!.bio);
      editingProfilePicture(userProfile.value!.profilePicture);
    }
  }

  void cancelEditing() {
    isEditing(false);
    // Reset editing fields to original values
    if (userProfile.value != null) {
      editingDisplayName(userProfile.value!.displayName);
      editingBio(userProfile.value!.bio);
      editingProfilePicture(userProfile.value!.profilePicture);
    }
  }

  Future<void> saveProfile() async {
    if (userProfile.value == null) return;

    try {
      isLoading(true);
      
      // Update the profile with edited values
      userProfile.value!.displayName = editingDisplayName.value;
      userProfile.value!.bio = editingBio.value;
      userProfile.value!.profilePicture = editingProfilePicture.value;
      
      final success = await MockDataService.updateProfile(userProfile.value!);
      
      if (success) {
        isEditing(false);
        userProfile.refresh();
        
        Get.snackbar(
          'success'.tr,
          'Profile updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  void changeProfilePicture() {
    // Mock profile picture change
    final newPicture = 'https://i.pravatar.cc/200?img=${DateTime.now().millisecond % 70}';
    editingProfilePicture(newPicture);
    
    Get.snackbar(
      'success'.tr,
      'Profile picture selected',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> followUser(String userId) async {
    try {
      final success = await MockDataService.followUser(userId);
      
      if (success && userProfile.value != null) {
        userProfile.value!.followingCount++;
        userProfile.refresh();
        
        Get.snackbar(
          'success'.tr,
          'User followed successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to follow user',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final success = await MockDataService.unfollowUser(userId);
      
      if (success && userProfile.value != null) {
        userProfile.value!.followingCount--;
        userProfile.refresh();
        
        Get.snackbar(
          'success'.tr,
          'User unfollowed successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to unfollow user',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openSettings() {
    Get.snackbar(
      'profile_settings'.tr,
      'Settings page coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openAchievements() {
    Get.snackbar(
      'profile_achievements'.tr,
      'Achievements page coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openSocialLink(String link) {
    Get.snackbar(
      'profile_social_links'.tr,
      'Opening: $link',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  String get tabTitle {
    switch (selectedTab.value) {
      case 0:
        return 'profile_posts'.tr;
      case 1:
        return 'profile_stories'.tr;
      case 2:
        return 'profile_saved'.tr;
      default:
        return 'profile_posts'.tr;
    }
  }

  bool get hasProfile => userProfile.value != null;
  
  bool get canSaveProfile => 
      editingDisplayName.value.isNotEmpty && 
      editingDisplayName.value.trim().length >= 2;

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
} 