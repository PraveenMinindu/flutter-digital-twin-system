// lib/features/intelligent_twin/data/models/intersection_result.dart

import 'package:latlong2/latlong.dart';

class IntersectionResult {
  final LatLng meetingPoint;
  final List<LatLng> pathBToMeeting;
  final double estimatedTimeSec;
  final bool found;

  const IntersectionResult({
    required this.meetingPoint,
    required this.pathBToMeeting,
    required this.estimatedTimeSec,
    required this.found,
  });

  static const IntersectionResult none = IntersectionResult(
    meetingPoint: LatLng(0, 0),
    pathBToMeeting: [],
    estimatedTimeSec: 0,
    found: false,
  );
}
