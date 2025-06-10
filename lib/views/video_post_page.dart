import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/video_post_controller.dart';
import '../widgets/loading_widget.dart' as custom_widgets;

class VideoPostPage extends StatelessWidget {
  const VideoPostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoPostController());
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
        title: Text(
          'nav_home'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return custom_widgets.LoadingWidget(message: 'loading'.tr);
        }
        
        if (controller.hasError.value) {
          return custom_widgets.ErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadPosts,
          );
        }
        
        if (controller.posts.isEmpty) {
          return const custom_widgets.EmptyStateWidget(
            title: 'No posts yet',
            subtitle: 'Check back later for new content!',
            icon: Icons.video_library_outlined,
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshPosts,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: controller.posts.length,
            onPageChanged: (index) {
              controller.playVideo(index);
            },
            itemBuilder: (context, index) {
              final post = controller.posts[index];
              
              // Ensure first video plays when widget is first built
              if (index == 0 && controller.currentVideoIndex.value == 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.playVideo(0);
                });
              }
              
              return VideoPostWidget(
                post: post,
                controller: controller,
              );
            },
          ),
        );
      }),
    );
  }
}

class VideoPostWidget extends StatelessWidget {
  final dynamic post;
  final VideoPostController controller;

  const VideoPostWidget({
    Key? key,
    required this.post,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        GestureDetector(
          onTap: controller.togglePlayPause,
          onDoubleTap: () => controller.toggleLike(post.id),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video player or thumbnail
              Obx(() {
                final isCurrentVideo = controller.currentPostId.value == post.id;
                final videoController = controller.getVideoController(post.id);
                
                if (isCurrentVideo && videoController != null && videoController.value.isInitialized) {
                  return AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  );
                } else {
                  // Fallback to thumbnail
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(post.videoThumbnail),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              }),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 0.7, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Play/pause button overlay
        Center(
          child: Obx(() {
            final isCurrentVideo = controller.currentPostId.value == post.id;
            return AnimatedOpacity(
              opacity: isCurrentVideo && !controller.isPlaying.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          }),
        ),
        
        // User info and actions
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left side - user info and caption
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User info
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: NetworkImage(post.userAvatar),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  controller.formatTimeAgo(post.timestamp),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Caption
                      Text(
                        post.caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Right side - action buttons
                Column(
                  children: [
                    // Like button
                    Obx(() {
                      final currentPost = controller.posts.firstWhere(
                        (p) => p.id == post.id,
                        orElse: () => post,
                      );
                      return _ActionButton(
                        icon: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: currentPost.isLiked 
                                ? Colors.red.withOpacity(0.2)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            currentPost.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: currentPost.isLiked ? Colors.red : Colors.white,
                            size: 28,
                          ),
                        ),
                        label: controller.formatLikesCount(currentPost.likeCount),
                        onTap: () => controller.toggleLike(post.id),
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // Comment button
                    _ActionButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mode_comment_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      label: post.commentCount.toString(),
                      onTap: () => controller.openComments(post.id),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Share button
                    _ActionButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      label: 'video_post_share'.tr,
                      onTap: () => controller.sharePost(post.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Double tap animation
        Obx(() {
          final currentPost = controller.posts.firstWhere(
            (p) => p.id == post.id,
            orElse: () => post,
          );
          return currentPost.isLiked
              ? const Center(
                  child: AnimatedOpacity(
                    opacity: 0.8,
                    duration: Duration(milliseconds: 500),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 80,
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              children: [
                widget.icon,
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
 