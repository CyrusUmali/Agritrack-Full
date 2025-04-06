import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapMiniView extends StatelessWidget {
  final bool isMobile;

  const MapMiniView({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return _maps(context);
  }

  Widget _maps(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(14.077557, 121.328938), // Philippines location
                  zoom: 13,
                  minZoom: 13,
                  maxBounds: LatLngBounds(
                    LatLng(13.927557, 121.178938), // SW bounds
                    LatLng(14.227557, 121.478938), // NE bounds
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",
                    userAgentPackageName: 'com.example.app',
                  ),
                  // Example polygon for a region in the Philippines
                  // PolygonLayer(
                  //   polygons: [
                  //     Polygon(
                  //       points: [
                  //         LatLng(14.05, 121.30),
                  //         LatLng(14.05, 121.35),
                  //         LatLng(14.10, 121.35),
                  //         LatLng(14.10, 121.30),
                  //       ],
                  //       color: Colors.blue.withOpacity(0.5),
                  //       borderColor: Colors.blue,
                  //       borderStrokeWidth: 2,
                  //       isFilled: true,
                  //       label: 'Sample Region',
                  //       labelStyle: const TextStyle(
                  //         color: Colors.black,
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // MarkerLayer(
                  //   markers: [
                  //     // Location marker
                  //     Marker(
                  //       width: 40.0,
                  //       height: 40.0,
                  //       point: LatLng(14.077557, 121.328938),
                  //       child: Icon(
                  //         Icons.location_on,
                  //         color: Theme.of(context).colorScheme.error,
                  //         size: 40,
                  //       ),
                  //     ),
                  //     // Region label marker
                  //     Marker(
                  //       point: LatLng(14.075, 121.325),
                  //       width: 120,
                  //       height: 40,
                  //       child: const Text(
                  //         'Sample Region',
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //           fontWeight: FontWeight.bold,
                  //           backgroundColor: Colors.white70,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
