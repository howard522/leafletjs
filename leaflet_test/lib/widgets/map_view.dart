// lib/widgets/map_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../models/poi.dart';
import '../state/app_state.dart';
import '../utils/maps_launcher.dart';

class MapView extends StatefulWidget {
  final AppState app;
  const MapView({super.key, required this.app});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _popupLayerController = PopupController();
  final MapController _mapController = MapController();
  double _zoom = 16;

  void _zoomIn() {
    _zoom = (_zoom + 1).clamp(1.0, 20.0);
    _mapController.move(_mapController.camera.center, _zoom);
    setState(() {});
  }

  void _zoomOut() {
    _zoom = (_zoom - 1).clamp(1.0, 20.0);
    _mapController.move(_mapController.camera.center, _zoom);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget.app.pois
        .map((p) => Marker(
              point: p.position,
              width: 44,
              height: 44,
              child: const Icon(Icons.location_on, size: 40),
            ))
        .toList();

    final me = widget.app.currentPosition;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter:
                widget.app.mapCenter ?? const LatLng(24.7956, 120.9942),
            initialZoom: _zoom,
            onTap: (_, __) => _popupLayerController.hideAllPopups(),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapEvent: (e) {
              final z = e.camera.zoom;
              if (z != _zoom) {
                _zoom = z;
                setState(() {});
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.leaflet_nav',
            ),

            // 我的所在位置：先畫光暈，再畫藍點
            if (me != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: me,
                    radius: 22, // UI：淡藍光暈
                    color: const Color(0x332197F3),
                    borderColor: const Color(0x552197F3),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
            if (me != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: me,
                    width: 18,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x552196F3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            PopupMarkerLayerWidget(
              options: PopupMarkerLayerOptions(
                popupController: _popupLayerController,
                markers: markers,
                markerTapBehavior: MarkerTapBehavior.togglePopup(),
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) {
                    final poi =
                        _findPoiByLatLng(marker.point, widget.app.pois);
                    if (poi == null) return const SizedBox.shrink();

                    final distanceText = _distanceFromMe(poi.position);

                    return Container(
                      constraints: const BoxConstraints(maxWidth: 326),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                            color: Color(0x1F000000),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      poi.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '新竹市東區',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          '一般',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: const Color(0xFF2F7CF6),
                                              ),
                                        ),
                                        if (distanceText != null) ...[
                                          const Text('•'),
                                          Text(
                                            distanceText,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageFor(poi),
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 96,
                                    height: 96,
                                    color: const Color(0xFFEFEFEF),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.image, size: 28),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
                                try {
                                  await MapsLauncher.openInGoogleMaps(
                                    lat: poi.position.latitude,
                                    lng: poi.position.longitude,
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('開啟 Google Maps 失敗：$e'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('Google Map'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () =>
                                  _popupLayerController.hideAllPopups(),
                              child: const Text('繼續'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        Positioned(
          right: 12,
          bottom: 12,
          child: _ZoomControls(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
        ),
      ],
    );
  }

  Poi? _findPoiByLatLng(LatLng pt, List<Poi> pois) {
    for (final p in pois) {
      final dLat = (p.position.latitude - pt.latitude).abs();
      final dLng = (p.position.longitude - pt.longitude).abs();
      if (dLat < 1e-7 && dLng < 1e-7) return p; // 為何：浮點誤差
    }
    return null;
  }

  String? _distanceFromMe(LatLng target) {
    final me = widget.app.currentPosition;
    if (me == null) return null;
    final meters = const Distance().as(LengthUnit.Meter, me, target);
    if (meters < 1000) return '${meters.toStringAsFixed(0)}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _imageFor(Poi poi) {
    if (poi.id == 'literature_museum') {
      return 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?q=80&w=800&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=800&auto=format&fit=crop';
  }
}

class _ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(tooltip: '放大', onPressed: onZoomIn, icon: const Icon(Icons.add)),
            const Divider(height: 1),
            IconButton(tooltip: '縮小', onPressed: onZoomOut, icon: const Icon(Icons.remove)),
          ],
        ),
      ),
    );
  }
}
