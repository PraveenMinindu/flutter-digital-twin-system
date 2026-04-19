// lib/features/intelligent_twin/presentation/screens/intelligent_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../controllers/intelligent_controller.dart';

class IntelligentScreen extends StatefulWidget {
  const IntelligentScreen({super.key});

  @override
  State<IntelligentScreen> createState() => _IntelligentScreenState();
}

class _IntelligentScreenState extends State<IntelligentScreen> {
  final MapController _mapController = MapController();
  final DateFormat _timeFmt = DateFormat('HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    return Consumer<IntelligentController>(
      builder: (context, controller, _) {
        final a = controller.objectA;
        final b = controller.objectB;
        final ix = controller.intersection;
        final vel = controller.velocityA;

        final center = a != null
            ? LatLng(a.latitude, a.longitude)
            : const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);

        final posA = a != null ? LatLng(a.latitude, a.longitude) : null;
        final posB = b != null ? LatLng(b.latitude, b.longitude) : null;

        return Scaffold(
          appBar: AppBar(title: const Text(AppConstants.appTitle)),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: AppConstants.defaultZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.digital_twin_step_5_intelligent_twin',
                  ),

                  if (controller.predictedPathA.hasPoints)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: controller.predictedPathA.points,
                          strokeWidth: 4,
                          color: Colors.orange,
                        ),
                      ],
                    ),

                  if (ix.found)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: ix.pathBToMeeting,
                          strokeWidth: 4,
                          color: Colors.teal,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      if (posA != null)
                        Marker(
                          point: posA,
                          width: 50,
                          height: 50,
                          child: const _ObjectMarker(
                            label: 'A',
                            color: Colors.indigo,
                          ),
                        ),
                      if (posB != null)
                        Marker(
                          point: posB,
                          width: 50,
                          height: 50,
                          child: const _ObjectMarker(
                            label: 'B',
                            color: Colors.teal,
                          ),
                        ),
                      if (ix.found)
                        Marker(
                          point: ix.meetingPoint,
                          width: 44,
                          height: 44,
                          child: const _MeetingMarker(),
                        ),
                    ],
                  ),
                ],
              ),

              Positioned(
                top: 12,
                left: 12,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Legend',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        _LegendRow(color: Colors.indigo, label: 'Object A'),
                        _LegendRow(color: Colors.teal, label: 'Object B'),
                        _LegendRow(
                          color: Colors.orange,
                          label: 'Predicted Path',
                        ),
                        _LegendRow(color: Colors.amber, label: 'Meeting Point'),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 180,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: () {
                    _mapController.move(center, AppConstants.defaultZoom);
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),

              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.errorMessage != null)
                          Text(
                            controller.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        if (a == null)
                          const Text(
                            'No Object A data yet. Press "Load Demo" first.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        if (a != null) ...[
                          Text(
                            'A Speed: ${vel.speedMetersPerSecond.toStringAsFixed(2)} m/s (${vel.compassLabel})',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Heading: ${vel.headingDegrees.toStringAsFixed(2)}°',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Intercept: ${ix.found ? "Found" : "Not found"}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last A update: ${_timeFmt.format(a.timestamp)}',
                          ),
                        ],
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: controller.loadDemo,
                                child: const Text('Load Demo'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: controller.moveAPlace1,
                                child: const Text('A → Place 1'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: controller.moveAPlace2,
                                child: const Text('A → Place 2'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: controller.moveAPlace3,
                                child: const Text('A → Place 3'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: controller.moveAPlace4,
                                child: const Text('A → Place 4'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: controller.resetObjects,
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ObjectMarker extends StatelessWidget {
  final String label;
  final Color color;

  const _ObjectMarker({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MeetingMarker extends StatelessWidget {
  const _MeetingMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.amber,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.flag, color: Colors.white, size: 18),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
