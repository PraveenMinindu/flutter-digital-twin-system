import 'package:latlong2/latlong.dart';

/// The output of the prediction engine.
///
/// [points] is an ordered list of coordinates that form the predicted path,
/// starting from the current position and ending at the furthest predicted point.
///
/// [finalPoint] is just the last item in [points] — the position we expect the
/// object to reach after [predictionHorizonSeconds] seconds.
class PredictedPath {
  /// All coordinates along the predicted path (current pos + future steps).
  final List<LatLng> points;

  /// The end of the predicted path.
  LatLng get finalPoint => points.last;

  const PredictedPath({required this.points});

  /// Safe empty state used before any velocity data is available.
  static const PredictedPath empty = PredictedPath(points: []);

  bool get hasPoints => points.length > 1;
}
