import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mobile_app/core/navigation/navigation_service.dart';
import 'package:mobile_app/core/routes/route_names.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';

import 'package:mobile_app/models/video_model.dart';

class VideoCard extends StatelessWidget {
  final VideoModel video;

  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.large,

          onTap: () {
            NavigationService.push(
              context,
              RouteNames.videoPlayer,
              extra: video,
            );
          },

          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // THUMBNAIL
                // ==================================================
                ClipRRect(
                  borderRadius: AppRadius.large,

                  child: AspectRatio(
                    aspectRatio: 16 / 9,

                    child: Stack(
                      fit: StackFit.expand,

                      children: [
                        // ------------------------------------------------
                        // Thumbnail
                        // ------------------------------------------------
                        CachedNetworkImage(
                          imageUrl: video.thumbnail,
                          fit: BoxFit.cover,

                          placeholder: (context, url) {
                            return Container(
                              color: AppColors.surface,

                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,

                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },

                          errorWidget: (context, url, error) {
                            return Container(
                              color: AppColors.surface,

                              child: const Center(
                                child: Icon(
                                  Icons.movie_outlined,
                                  color: AppColors.textMuted,
                                  size: 36,
                                ),
                              ),
                            );
                          },
                        ),

                        // ------------------------------------------------
                        // Bottom gradient
                        // ------------------------------------------------
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 65,

                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,

                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ------------------------------------------------
                        // Play button
                        // ------------------------------------------------
                        Center(
                          child: Container(
                            width: 44,
                            height: 44,

                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),

                              shape: BoxShape.circle,

                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),

                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // ==================================================
                // TITLE
                // ==================================================
                Text(
                  video.title,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: AppTextStyles.videoTitle,
                ),

                const SizedBox(height: AppSpacing.xs),

                // ==================================================
                // CREATOR
                // ==================================================
                Row(
                  children: [
                    const Icon(
                      Icons.movie_creation_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        video.channel.isEmpty
                            ? 'Cinimini Creator'
                            : video.channel,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: AppTextStyles.creatorName,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
