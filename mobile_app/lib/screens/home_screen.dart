import 'package:flutter/material.dart';

import '../models/video_model.dart';
import '../repositories/video_repository.dart';
import '../widgets/video_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: AppBar(title: const Text("Cinimini")),

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

          return ListView.builder(
            itemCount: videos.length,

            itemBuilder: (_, index) {
              return VideoCard(video: videos[index]);
            },
          );
        },
      ),
    );
  }
}
