/// Holds the CALCULATED movement data derived from two consecutive positions.
///
/// Think of this as the "output" of the Velocity Engine:
///   - How fast is the object moving?  → speedMetersPerSecond
///   - Which direction is it heading?  → headingDegrees
///   - How far did it travel?          → distanceMeters
class VelocityData {
  /// Speed in metres per second (m/s).
  final double speedMetersPerSecond;

  /// Compass heading in degrees (0° = North, 90° = East, 180° = South, 270° = West).
  final double headingDegrees;

  /// Straight-line distance between the two positions in metres.
  final double distanceMeters;

  /// How many seconds passed between the two position snapshots.
  final double elapsedSeconds;

  const VelocityData({
    required this.speedMetersPerSecond,
    required this.headingDegrees,
    required this.distanceMeters,
    required this.elapsedSeconds,
  });

  /// Convenience: speed as km/h for display.
  double get speedKmh => speedMetersPerSecond * 3.6;

  /// A safe zero-state before any movement is detected.
  static const VelocityData zero = VelocityData(
    speedMetersPerSecond: 0,
    headingDegrees: 0,
    distanceMeters: 0,
    elapsedSeconds: 0,
  );

  /// Human-readable compass direction label.
  String get compassLabel {
    if (headingDegrees >= 337.5 || headingDegrees < 22.5) return 'N';
    if (headingDegrees < 67.5) return 'NE';
    if (headingDegrees < 112.5) return 'E';
    if (headingDegrees < 157.5) return 'SE';
    if (headingDegrees < 202.5) return 'S';
    if (headingDegrees < 247.5) return 'SW';
    if (headingDegrees < 292.5) return 'W';
    return 'NW';
  }
}
