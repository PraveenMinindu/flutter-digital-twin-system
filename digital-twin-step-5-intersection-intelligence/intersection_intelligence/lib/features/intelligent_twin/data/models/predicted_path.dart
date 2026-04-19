// lib/features/intelligent_twin/data/models/predicted_path.dart

import 'package:latlong2/latlong.dart';

class PredictedPath {
  final List<LatLng> points;

  const PredictedPath({required this.points});

  bool get hasPoints => points.length > 1;

  LatLng? get finalPoint => points.isNotEmpty ? points.last : null;

  static const PredictedPath empty = PredictedPath(points: []);
}
