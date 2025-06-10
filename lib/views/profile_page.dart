import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/profile_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart' as custom_widgets;

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return custom_widgets.LoadingWidget(message: 'loading'.tr);
        }
        
        if (controller.hasError.value) {
          return custom_widgets.ErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadUserProfile,
          );
        }
        
        if (!controller.hasProfile) {
          return const custom_widgets.EmptyStateWidget(
            title: 'Profile not found',
            subtitle: 'Unable to load profile information',
            icon: Icons.person_outline,
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                title: Text(
                  controller.userProfile.value!.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: controller.openSettings,
                    ),
                  ),
                ],
                floating: true,
                snap: true,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Profile Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _ProfileHeader(controller: controller),
                    _ProfileStats(controller: controller),
                    _ProfileBio(controller: controller),
                    _ProfileActions(controller: controller),
                    _ProfileTabs(controller: controller),
                  ],
                ),
              ),
              
              // Content based on selected tab
              _ProfileContent(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileController controller;

  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.userProfile.value!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Obx(() => CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: NetworkImage(
                    controller.isEditing.value 
                        ? controller.editingProfilePicture.value
                        : profile.profilePicture,
                  ),
                )),
              ),
              if (controller.isEditing.value)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.changeProfilePicture,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 24),
          
          // Name and username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => controller.isEditing.value
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Display Name',
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (value) => controller.editingDisplayName(value),
                          controller: TextEditingController(
                            text: controller.editingDisplayName.value,
                          ),
                        ),
                      )
                    : Text(
                        profile.displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      )),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '@${profile.username}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final ProfileController controller;

  const _ProfileStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.userProfile.value!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            count: controller.formatCount(profile.postCount),
            label: 'profile_posts'.tr,
            onTap: () => controller.selectTab(0),
            isActive: true,
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          _StatItem(
            count: controller.formatCount(profile.followerCount),
            label: 'profile_followers'.tr,
            onTap: () {},
            isActive: false,
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          _StatItem(
            count: controller.formatCount(profile.followingCount),
            label: 'profile_following'.tr,
            onTap: () {},
            isActive: false,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _StatItem({
    required this.count,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isActive 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.headlineSmall?.color,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isActive 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBio extends StatelessWidget {
  final ProfileController controller;

  const _ProfileBio({required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = controller.userProfile.value!;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => controller.isEditing.value
              ? TextField(
                  decoration: InputDecoration(
                    hintText: 'profile_bio'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => controller.editingBio(value),
                  controller: TextEditingController(
                    text: controller.editingBio.value,
                  ),
                )
              : Text(
                  profile.bio.isNotEmpty ? profile.bio : 'No bio yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
          
          if (profile.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: profile.socialLinks.map((link) {
                return GestureDetector(
                  onTap: () => controller.openSocialLink(link),
                  child: Chip(
                    label: Text(
                      link.split('/').last,
                      style: const TextStyle(fontSize: 12),
                    ),
                    avatar: const Icon(Icons.link, size: 16),
                  ),
                );
              }).toList(),
            ),
          ],
          
          if (profile.achievements.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: controller.openAchievements,
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${profile.achievements.length} achievements',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileActions extends StatelessWidget {
  final ProfileController controller;

  const _ProfileActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: controller.isEditing.value
                ? CustomButton(
                    text: 'save'.tr,
                    onPressed: controller.canSaveProfile 
                        ? controller.saveProfile 
                        : null,
                    isEnabled: controller.canSaveProfile,
                    isLoading: controller.isLoading.value,
                  )
                : CustomButton(
                    text: 'profile_edit_profile'.tr,
                    onPressed: controller.startEditing,
                  ),
          ),
          if (controller.isEditing.value) ...[
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'cancel'.tr,
                onPressed: controller.cancelEditing,
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ],
      )),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final ProfileController controller;

  const _ProfileTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      'profile_posts'.tr,
      'profile_stories'.tr,
      'profile_saved'.tr,
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Obx(() => Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = controller.selectedTab.value == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.selectTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileController controller;

  const _ProfileContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.userProfile.value!;
      
      switch (controller.selectedTab.value) {
        case 0: // Posts
          if (profile.posts.isEmpty) {
            return const SliverToBoxAdapter(
              child: custom_widgets.EmptyStateWidget(
                title: 'No posts yet',
                subtitle: 'Share your first post!',
                icon: Icons.photo_library_outlined,
              ),
            );
          }
          
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childCount: profile.posts.length,
              itemBuilder: (context, index) {
                final post = profile.posts[index];
                return _PostGridItem(post: post);
              },
            ),
          );
          
        case 1: // Stories
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: profile.storyHighlights.isEmpty
                  ? const custom_widgets.EmptyStateWidget(
                      title: 'No story highlights',
                      subtitle: 'Add highlights to showcase your best stories',
                      icon: Icons.highlight_outlined,
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: profile.storyHighlights.length,
                      itemBuilder: (context, index) {
                        final highlight = profile.storyHighlights[index];
                        return _StoryHighlightItem(highlight: highlight);
                      },
                    ),
            ),
          );
          
        case 2: // Saved
          return const SliverToBoxAdapter(
            child: custom_widgets.EmptyStateWidget(
              title: 'No saved posts',
              subtitle: 'Posts you save will appear here',
              icon: Icons.bookmark_outline,
            ),
          );
          
        default:
          return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
    });
  }
}

class _PostGridItem extends StatelessWidget {
  final dynamic post;

  const _PostGridItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          post.videoThumbnail,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }
}

class _StoryHighlightItem extends StatelessWidget {
  final String highlight;

  const _StoryHighlightItem({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.highlight, size: 32),
          const SizedBox(height: 8),
          Text(
            highlight,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 