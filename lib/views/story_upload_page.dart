import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/story_upload_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart' as custom_widgets;

class StoryUploadPage extends StatelessWidget {
  const StoryUploadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryUploadController());
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'story_upload_add_story'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: controller.canUpload 
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      )
                    : null,
                color: controller.canUpload 
                    ? null 
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: controller.canUpload ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: TextButton(
                onPressed: controller.canUpload ? controller.uploadStory : null,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'story_upload_post'.tr,
                  style: TextStyle(
                    color: controller.canUpload 
                        ? Colors.white
                        : Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isUploading.value) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              custom_widgets.LoadingWidget(message: 'story_upload_uploading'.tr),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(
                  value: controller.uploadProgress.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text('${(controller.uploadProgress.value * 100).toInt()}%'),
            ],
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media selection
              _MediaSelectionSection(controller: controller),
              
              const SizedBox(height: 24),
              
              // Preview section
              if (controller.currentStory.value?.mediaPath.isNotEmpty == true)
                _PreviewSection(controller: controller),
              
              const SizedBox(height: 24),
              
              // Text overlay
              _TextOverlaySection(controller: controller),
              
              const SizedBox(height: 24),
              
              // Filters
              _FiltersSection(controller: controller),
              
              const SizedBox(height: 24),
              
              // Duration settings
              _DurationSection(controller: controller),
              
              const SizedBox(height: 24),
              
              // Visibility settings
              _VisibilitySection(controller: controller),
              
              const SizedBox(height: 40),
              
              // Upload button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'story_upload_post'.tr,
                  onPressed: controller.canUpload ? controller.uploadStory : null,
                  isEnabled: controller.canUpload,
                  isLoading: controller.isUploading.value,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MediaSelectionSection extends StatelessWidget {
  final StoryUploadController controller;

  const _MediaSelectionSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Select Media',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MediaSelectionCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'story_upload_camera'.tr,
                  subtitle: 'Take a photo',
                  onTap: controller.selectMediaFromCamera,
                  gradient: [
                    Colors.purple.withOpacity(0.8),
                    Colors.blue.withOpacity(0.8),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MediaSelectionCard(
                  icon: Icons.photo_library_outlined,
                  title: 'story_upload_gallery'.tr,
                  subtitle: 'Choose from library',
                  onTap: controller.selectMediaFromGallery,
                  gradient: [
                    Colors.pink.withOpacity(0.8),
                    Colors.orange.withOpacity(0.8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaSelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final List<Color> gradient;

  const _MediaSelectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final StoryUploadController controller;

  const _PreviewSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[300],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Mock preview image
                Image.network(
                  'https://picsum.photos/300/500?random=${DateTime.now().millisecond}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
                
                // Text overlay
                if (controller.textOverlay.value.isNotEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.textOverlay.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TextOverlaySection extends StatelessWidget {
  final StoryUploadController controller;

  const _TextOverlaySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Overlay',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'story_upload_text_overlay'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: controller.updateTextOverlay,
          maxLines: 2,
        ),
      ],
    );
  }
}

class _FiltersSection extends StatelessWidget {
  final StoryUploadController controller;

  const _FiltersSection({required this.controller});

  String _getFilterDisplayName(String filter) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'story_upload_filters'.tr,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Obx(() => SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.availableFilters.length,
            itemBuilder: (context, index) {
              final filter = controller.availableFilters[index];
              final isSelected = controller.selectedFilter.value == filter;
              
              return GestureDetector(
                onTap: () => controller.selectFilter(filter),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.filter,
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getFilterDisplayName(filter),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )),
      ],
    );
  }
}

class _DurationSection extends StatelessWidget {
  final StoryUploadController controller;

  const _DurationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'story_upload_duration'.tr,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Obx(() => Column(
          children: [
            Slider(
              value: controller.storyDuration.value.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '${controller.storyDuration.value}s',
              onChanged: (value) => controller.updateDuration(value.toInt()),
            ),
            Text('${controller.storyDuration.value} seconds'),
          ],
        )),
      ],
    );
  }
}

class _VisibilitySection extends StatelessWidget {
  final StoryUploadController controller;

  const _VisibilitySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'story_upload_visibility'.tr,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Obx(() => Row(
          children: controller.visibilityOptions.map((option) {
            final isSelected = controller.selectedVisibility.value == option;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectVisibility(option),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                    ),
                  ),
                  child: Text(
                    'story_upload_$option'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
} 