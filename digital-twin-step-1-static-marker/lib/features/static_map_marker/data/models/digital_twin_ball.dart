class DigitalTwinBall {
  final double latitude;
  final double longitude;
  final bool isActive;

  DigitalTwinBall({
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  factory DigitalTwinBall.fromMap(Map<String, dynamic> map) {
    return DigitalTwinBall(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      isActive: map['is_active'] ?? false,
    );
  }
}
