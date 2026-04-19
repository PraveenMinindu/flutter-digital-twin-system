import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_constants.dart';
import '../controllers/live_map_controller.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final LiveMapController controller = LiveMapController();
  final MapController flutterMapController = MapController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_handleControllerUpdates);
    controller.startListening();
  }

  void _handleControllerUpdates() {
    final ball = controller.ball;
    if (ball != null) {
      flutterMapController.move(
        LatLng(ball.latitude, ball.longitude),
        AppConstants.defaultZoom,
      );
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerUpdates);
    controller.dispose();
    flutterMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final ball = controller.ball;
          if (ball == null) {
            return const Center(
              child: Text('No live ball data available.'),
            );
          }

          if (!ball.isActive) {
            return const Center(
              child: Text('Ball is inactive.'),
            );
          }

          final position = LatLng(ball.latitude, ball.longitude);

          return FlutterMap(
            mapController: flutterMapController,
            options: MapOptions(
              initialCenter: position,
              initialZoom: AppConstants.defaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.digital_twin_step_2',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: position,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 42,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
