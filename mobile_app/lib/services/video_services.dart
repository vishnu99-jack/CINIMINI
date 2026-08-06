import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/endpoints.dart';
import '../models/video_model.dart';

class VideoService {
  Future<List<VideoModel>> fetchVideos() async {
    final response = await http.get(Uri.parse(Endpoints.videos));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List videos = json['data'];

      return videos.map((e) => VideoModel.fromJson(e)).toList();
    }

    throw Exception("Unable to load videos");
  }
}
