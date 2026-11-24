import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/navigation/pages/bottomNavigation_screen.dart';
import '../../screens/peertube_video_player_screen.dart';
import '../../models/video_model.dart';

import '../routes/route_names.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';

final GoRouter appRouter = GoRouter(
  // Start application with Login page
  initialLocation: '/login',

  routes: [
    // LOGIN
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

    // REGISTER
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    // HOME
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) {
        return const BottomNavigationScreen();
      },
    ),


    // VIDEO PLAYER
    GoRoute(
      path: RouteNames.videoPlayer,
      builder: (context, state) {
        final video = state.extra as VideoModel;

        return PeerTubeVideoPlayerScreen(video: video);
      },
    ),
  ],
);
