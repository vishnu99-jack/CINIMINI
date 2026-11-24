import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MediaKit.ensureInitialized();

  runApp(const CiniminiApp());
}

class CiniminiApp extends StatelessWidget {
  const CiniminiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'Cinimini',

      theme: AppTheme.darkTheme,

      routerConfig: appRouter,
    );
  }
}
