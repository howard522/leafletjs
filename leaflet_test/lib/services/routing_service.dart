// lib/services/routing_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> polyline;
  final double distance; // meters
  final double duration; // seconds

  RouteResult({required this.polyline, required this.distance, required this.duration});
}

class RoutingService {
  // 公共 OSRM 節點，流量有限；商用請自架或改用其他供應商。
  static const _base = 'https://router.project-osrm.org/route/v1/driving';

  static Future<RouteResult> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '$_base/${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('OSRM HTTP ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    if (data['routes'] == null || (data['routes'] as List).isEmpty) {
      throw Exception('無可用路線');
    }
    final route = data['routes'][0];
    final distance = (route['distance'] as num).toDouble();
    final duration = (route['duration'] as num).toDouble();
    final coords = (route['geometry']['coordinates'] as List)
        .map<LatLng>((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
    return RouteResult(polyline: coords, distance: distance, duration: duration);
  }
}
