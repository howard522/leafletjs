// lib/utils/maps_launcher.dart
import 'package:url_launcher/url_launcher.dart';

class MapsLauncher {
  static Future<void> openInGoogleMaps({
    required double lat,
    required double lng,
  }) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok) {
      // 為何：提醒使用者可能是無瀏覽器或拒絕
      throw Exception('無法開啟 Google Maps');
    }
  }
}
