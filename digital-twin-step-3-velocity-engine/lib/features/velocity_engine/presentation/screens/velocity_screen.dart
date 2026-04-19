import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../controllers/velocity_controller.dart';

class VelocityScreen extends StatefulWidget {
  const VelocityScreen({super.key});

  @override
  State<VelocityScreen> createState() => _VelocityScreenState();
}

class _VelocityScreenState extends State<VelocityScreen> {
  final MapController _mapController = MapController();
  final _timeFmt = DateFormat('HH:mm:ss');

  @override
  void initState() {
    super.initState();
    // Start the Firestore listener as soon as this screen opens.
    context.read<VelocityController>().startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Velocity Engine '),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<VelocityController>(
        builder: (context, ctrl, _) {
          // ── Loading ──────────────────────────────────────────────────────
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ────────────────────────────────────────────────────────
          if (ctrl.errorMessage != null) {
            return Center(child: Text('Error: ${ctrl.errorMessage}'));
          }

          // ── No data yet ──────────────────────────────────────────────────
          if (ctrl.currentBall == null) {
            return const Center(child: Text('Waiting for Firestore data...'));
          }

          final ball = ctrl.currentBall!;
          final vel = ctrl.velocity;
          final pos = LatLng(ball.latitude, ball.longitude);

          return Stack(
            children: [
              // ── OpenStreetMap ──────────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: pos,
                  initialZoom: AppConstants.defaultZoom,
                ),
                children: [
                  // OSM tile layer — no API key needed!
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.digital_twin_step_3_velocity_engine',
                  ),
                  // Marker layer
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pos,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.deepPurple,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ── Data panel (bottom card) ───────────────────────────────
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Live Telemetry',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _TelemetryTile(
                              icon: Icons.speed,
                              label: 'Speed',
                              value:
                                  '${vel.speedMetersPerSecond.toStringAsFixed(2)} m/s',
                              sub: '(${vel.speedKmh.toStringAsFixed(1)} km/h)',
                            ),
                            _TelemetryTile(
                              icon: Icons.explore,
                              label: 'Heading',
                              value:
                                  '${vel.headingDegrees.toStringAsFixed(1)}°',
                              sub: vel.compassLabel,
                            ),
                            _TelemetryTile(
                              icon: Icons.straighten,
                              label: 'Distance',
                              value:
                                  '${vel.distanceMeters.toStringAsFixed(1)} m',
                              sub:
                                  '${vel.elapsedSeconds.toStringAsFixed(1)} s ago',
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Last update: ${_timeFmt.format(ball.timestamp)}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Centre-on-marker FAB ───────────────────────────────────
              Positioned(
                bottom: 180,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: 'centre',
                  onPressed: () =>
                      _mapController.move(pos, AppConstants.defaultZoom),
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Small reusable tile for the telemetry panel.
class _TelemetryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _TelemetryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
