import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/video_model.dart';
 // Change this import if needed

class HeroBanner extends StatelessWidget {
  final VideoModel video;

  const HeroBanner({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.large,
        image: DecorationImage(
          image: CachedNetworkImageProvider(video.thumbnail),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.large,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displaySmall,
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(video.channel, style: AppTextStyles.metadata),

            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                FilledButton.icon(
                  onPressed: () {
                    NavigationService.push(
                      context,
                      RouteNames.videoPlayer,
                      extra: video,
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Watch"),
                ),

                const SizedBox(width: AppSpacing.md),

                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Details Screen
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text("Details"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
