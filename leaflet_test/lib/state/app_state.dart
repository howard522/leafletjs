// lib/state/app_state.dart
import 'package:latlong2/latlong.dart';
import '../models/poi.dart';

class AppState {
  LatLng? currentPosition;
  LatLng? mapCenter;
  bool followMe = true;

  List<Poi> pois = const [];
}
