// lib/models/poi.dart
import 'package:latlong2/latlong.dart';

class Poi {
  final String id;
  final String name;
  final String description;
  final LatLng position;

  const Poi({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
  });
}
