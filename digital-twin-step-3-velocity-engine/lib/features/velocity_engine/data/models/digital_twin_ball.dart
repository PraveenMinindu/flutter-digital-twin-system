import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents one tracked object in Firestore.
/// Each document must have: latitude, longitude, timestamp.
class DigitalTwinBall {
  final String id;
  final double latitude;
  final double longitude;

  /// When this position was recorded (server timestamp).
  final DateTime timestamp;

  const DigitalTwinBall({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory DigitalTwinBall.fromMap(Map<String, dynamic> map, String docId) {
    return DigitalTwinBall(
      id: docId,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      // Fall back to "now" if timestamp is missing so the app doesn't crash.
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
