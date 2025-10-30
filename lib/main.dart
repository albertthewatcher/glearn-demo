import 'package:flutter/material.dart';

import 'theme.dart';
import 'home_screen.dart';
import 'page3_screen.dart';
import 'page2_screen.dart';

void main() {
  runApp(const GlearnApp());
}

class GlearnApp extends StatelessWidget {
  const GlearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galaxy Learning',
      debugShowCheckedModeBanner: false,
      theme: buildGalaxyTheme(Brightness.light),
      darkTheme: buildGalaxyTheme(Brightness.dark),
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
      routes: {
        '/page1': (_) => const HomeScreen(),
        '/page2': (_) => const Page2Screen(),
        '/page3': (_) => const Page3Screen(),
      },
    );
  }
}
