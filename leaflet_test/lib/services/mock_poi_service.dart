// lib/services/mock_poi_service.dart
import 'package:latlong2/latlong.dart';
import '../models/poi.dart';

class MockPoiService {
  /// 為示意用途：座標為近似值，後續可替換為真實座標或串接真後端。
  static Future<List<Poi>> getPois() async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // 模擬延遲
    return const [
      Poi(
        id: 'dm_lake',
        name: '清華大學 成功湖',
        description: '校園地標湖景，步道環湖適合散步。',
        position: LatLng(24.793721, 120.995982),
      ),
      Poi(
        id: 'literature_museum',
        name: '清華大學 圖書館',
        description: '人文社科教學與展演空間。',
        position: LatLng(24.79528496218696, 120.99472363460389),
      ),
      Poi(
        id: 'engineering_building',
        name: '國立臺灣海洋大學海事發展與訓練中心',
        description: '一個館',
        position: LatLng(25.14976038622738, 121.77758741271107),
      ),
    ];
  }
}
