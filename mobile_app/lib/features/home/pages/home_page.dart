import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../../../models/video_model.dart';
import '../../../repositories/video_repository.dart';

import '../widgets/hero_banner.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VideoRepository repository = VideoRepository();

  late Future<List<VideoModel>> futureVideos;

  @override
  void initState() {
    super.initState();

    futureVideos = repository.getVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<VideoModel>>(
        future: futureVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final videos = snapshot.data!;

          if (videos.isEmpty) {
            return const Center(child: Text("No videos available"));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeAppBar(),

                const SizedBox(height: AppSpacing.md),

                HeroBanner(video: videos.first),

                const SizedBox(height: AppSpacing.lg),

                const SectionHeader(title: "🎬 Now Screening"),

                // Video list comes here next...
              ],
            ),
          );
        },
      ),
    );
  }
}
