// lib/features/predictive_path/presentation/screens/predictive_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_constants.dart';
import '../controllers/predictive_controller.dart';

class PredictiveScreen extends StatefulWidget {
  const PredictiveScreen({super.key});

  @override
  State<PredictiveScreen> createState() => _PredictiveScreenState();
}

class _PredictiveScreenState extends State<PredictiveScreen> {
  final PredictiveController controller = PredictiveController();
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_handleControllerUpdate);
    controller.startListening();
  }

  void _handleControllerUpdate() {
    final current = controller.currentPoint;
    if (current != null) {
      mapController.move(
        LatLng(current.latitude, current.longitude),
        AppConstants.defaultZoom,
      );
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerUpdate);
    controller.dispose();
    mapController.dispose();
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
        builder: (context, _) {
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

          final current = controller.currentPoint;

          if (current == null) {
            return const Center(
              child: Text('Waiting for Firestore data...'),
            );
          }

          final currentLatLng = LatLng(current.latitude, current.longitude);

          final historicalPoints = controller.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();

          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLatLng,
                    initialZoom: AppConstants.defaultZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.digital_twin_step_4_predictive_path',
                    ),
                    if (historicalPoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: historicalPoints,
                            strokeWidth: 4,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    if (controller.predictedPath.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              currentLatLng,
                              ...controller.predictedPath
                            ],
                            strokeWidth: 4,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentLatLng,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 42,
                          ),
                        ),
                        if (controller.futurePoint != null)
                          Marker(
                            point: controller.futurePoint!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.flag,
                              color: Colors.orange,
                              size: 36,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current: ${current.latitude.toStringAsFixed(4)}, ${current.longitude.toStringAsFixed(4)}',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Speed: ${controller.speedMps.toStringAsFixed(2)} m/s',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Direction: ${controller.headingDegrees.toStringAsFixed(2)}°',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Points in Firestore: ${controller.points.length}',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: controller.setPlace1,
                child: const Text('Place 1'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: controller.setPlace2,
                child: const Text('Place 2'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: controller.setPlace3,
                child: const Text('Place 3'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: controller.setPlace4,
                child: const Text('Place 4'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: controller.loadDemoPath,
                child: const Text('Load Demo Path'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: controller.clearPoints,
                child: const Text('Clear Points'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
