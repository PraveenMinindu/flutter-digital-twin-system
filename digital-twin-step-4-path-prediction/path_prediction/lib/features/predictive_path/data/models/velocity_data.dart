/// The movement snapshot calculated from two consecutive positions.
/// Carried forward into the prediction engine.
class VelocityData {
  /// Speed in metres per second.
  final double speedMetersPerSecond;

  /// Compass bearing in degrees (0 = North, 90 = East, 180 = South, 270 = West).
  final double headingDegrees;

  /// Straight-line distance between the last two positions in metres.
  final double distanceMeters;

  /// Seconds that elapsed between the last two Firestore snapshots.
  final double elapsedSeconds;

  const VelocityData({
    required this.speedMetersPerSecond,
    required this.headingDegrees,
    required this.distanceMeters,
    required this.elapsedSeconds,
  });

  double get speedKmh => speedMetersPerSecond * 3.6;

  String get compassLabel {
    final h = headingDegrees;
    if (h >= 337.5 || h < 22.5) return 'N';
    if (h < 67.5) return 'NE';
    if (h < 112.5) return 'E';
    if (h < 157.5) return 'SE';
    if (h < 202.5) return 'S';
    if (h < 247.5) return 'SW';
    if (h < 292.5) return 'W';
    return 'NW';
  }

  static const VelocityData zero = VelocityData(
    speedMetersPerSecond: 0,
    headingDegrees: 0,
    distanceMeters: 0,
    elapsedSeconds: 0,
  );
}
