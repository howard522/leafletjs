// lib/pages/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/mock_poi_service.dart';
import '../state/app_state.dart';
import '../widgets/map_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final app = AppState();
  StreamSubscription<Position>? _sub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 載入 POI（模擬後端）
    app.pois = await MockPoiService.getPois();
    // 定位（可選，若不允許定位則以醉月湖為中心）
    final granted = await LocationService.ensurePermission();
    if (granted) {
      final pos = await LocationService.getCurrentPosition();
      app.currentPosition = LatLng(pos.latitude, pos.longitude);
      app.mapCenter = app.currentPosition;
      _sub = LocationService.positionStream().listen((p) {
        app.currentPosition = LatLng(p.latitude, p.longitude);
        if (app.followMe) app.mapCenter = app.currentPosition;
        if (mounted) setState(() {});
      });
    } else {
      app.mapCenter = app.pois.isNotEmpty ? app.pois.first.position : const LatLng(24.7956, 120.9942);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未授權定位，已以校園 POI 作為地圖中心')),
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = app.pois.isEmpty && app.mapCenter == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaflet Nav — POI Demo'),
        actions: [
          IconButton(
            tooltip: '跟隨定位（切換）',
            onPressed: () => setState(() => app.followMe = !app.followMe),
            icon: Icon(app.followMe ? Icons.my_location : Icons.location_disabled),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : MapView(app: app),
      
    );
  }
}
