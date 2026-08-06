import 'package:flutter/material.dart';

import '../models/video_model.dart';
import '../screens/video_player_screen.dart';

class VideoCard extends StatelessWidget {
  final VideoModel video;

  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: () {
        Navigator.push(
          context,
         MaterialPageRoute(builder: (_) => VideoScreen(video: video))
        );
      },

      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),

              child: Image.network(
                video.thumbnail,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,

                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 60),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            /// Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                video.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// Channel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                video.channel,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
