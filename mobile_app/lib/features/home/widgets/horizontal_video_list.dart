import 'package:flutter/material.dart';

import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/models/video_model.dart';

import 'video_card.dart';

class HorizontalVideoList extends StatelessWidget {
  final List<VideoModel> videos;

  const HorizontalVideoList({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),

        physics: const ClampingScrollPhysics(),

        itemCount: videos.length,

        separatorBuilder: (context, index) {
          return const SizedBox(width: AppSpacing.md);
        },

        itemBuilder: (context, index) {
          final video = videos[index];

          return SizedBox(width: 220, child: VideoCard(video: video));
        },
      ),
    );
  }
}
