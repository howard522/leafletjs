// lib/main.dart
import 'package:flutter/material.dart';
import 'package:leaflet_nav/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeafletNavApp());
}

class LeafletNavApp extends StatelessWidget {
  const LeafletNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaflet Nav — POI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}
