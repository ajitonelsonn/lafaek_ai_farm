import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/map/tile_cache.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// OpenStreetMap view of a farm plot.
///
/// Tiles come from the standard OSM tile servers through [CachedNetworkTileProvider],
/// so a map the farmer has opened once still draws with no signal. OSM
/// requires attribution, which is shown in the corner and must not be removed.
class FarmMap extends StatefulWidget {
  const FarmMap({
    super.key,
    required this.center,
    this.marker,
    this.onTap,
    this.zoom = 14,
    this.height = 240,
    this.interactive = true,
    this.tileCache,
  });

  /// Where the map opens.
  final LatLng center;

  /// The pinned plot, if one has been placed.
  final LatLng? marker;

  /// Called when the farmer taps the map to move the pin. Null makes the map
  /// read-only.
  final ValueChanged<LatLng>? onTap;

  final double zoom;
  final double height;
  final bool interactive;
  final MapTileCache? tileCache;

  @override
  State<FarmMap> createState() => FarmMapState();
}

class FarmMapState extends State<FarmMap> {
  final MapController _controller = MapController();
  late final MapTileCache _cache = widget.tileCache ?? MapTileCache();
  late final CachedNetworkTileProvider _tiles = CachedNetworkTileProvider(
    cache: _cache,
    // The OSM tile usage policy asks for a User-Agent that identifies the app.
    userAgent: 'LafaekAIFarm/0.1 (https://github.com/lafaek-ai-farm)',
  );

  /// Moves the view, used when the GPS fix arrives.
  void moveTo(LatLng point, {double? zoom}) =>
      _controller.move(point, zoom ?? _controller.camera.zoom);

  @override
  void dispose() {
    _tiles.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: widget.center,
                initialZoom: widget.zoom,
                minZoom: 3,
                maxZoom: 18,
                onTap: widget.onTap == null
                    ? null
                    : (_, point) => widget.onTap!(point),
                interactionOptions: InteractionOptions(
                  flags: widget.interactive
                      ? InteractiveFlag.pinchZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.doubleTapZoom
                      : InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileProvider: _tiles,
                  userAgentPackageName: 'com.lafaek.lafaek_ai_farm',
                  maxNativeZoom: 19,
                  // Offline, a missing tile should look empty, not alarming.
                  errorImage: null,
                  tileBuilder: (context, child, tile) => child,
                ),
                if (widget.marker != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: widget.marker!,
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 44,
                          color: AppColors.danger,
                          shadows: [
                            Shadow(color: Color(0x66000000), blurRadius: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            // OpenStreetMap's licence requires visible credit.
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: const Color(0xCCFFFFFF),
                child: Text('© OpenStreetMap contributors',
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
