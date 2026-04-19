// lib/features/intelligent_twin/data/models/velocity_data.dart

class VelocityData {
  final double speedMetersPerSecond;
  final double headingDegrees;
  final double distanceMeters;
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
