import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/map_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final BallMapController controller = BallMapController();

  @override
  void initState() {
    super.initState();
    controller.fetchBall();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Twin Map')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(child: Text(controller.error!));
          }

          if (controller.ball == null) {
            return const Center(child: Text('No ball data found'));
          }

          final ball = controller.ball!;
          final pos = LatLng(ball.latitude, ball.longitude);

          return FlutterMap(
            options: MapOptions(initialCenter: pos, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.static_maker',
              ),
              if (controller.route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.route!.points,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: pos,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.fetchRoute,
        child: const Icon(Icons.alt_route),
      ),
    );
  }
}
