import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FarmMapCard extends StatelessWidget {
  final Map<String, dynamic> farm;
  final bool isMobile;

  const FarmMapCard({
    super.key,
    required this.farm,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: isMobile ? 200 : 300,
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(14.077557, 121.328938),
            zoom: 13,
            minZoom: 13,
            maxBounds: LatLngBounds(
              LatLng(13.927557, 121.178938),
              LatLng(14.227557, 121.478938),
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(14.077557, 121.328938),
                  child: Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.error,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
