import 'package:flutter/material.dart';
import 'features/navigation/pages/bottomNavigation_screen.dart';
import 'package:media_kit/media_kit.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MediaKit.ensureInitialized();

  runApp(const CiniminiApp());
}

class CiniminiApp extends StatelessWidget {
  const CiniminiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinimini',
      home: BottomNavigationScreen(),
    );
  }
}
