import 'package:cloud_firestore/cloud_firestore.dart';

/// One tracked object's raw position snapshot from Firestore.
/// Every document must have latitude, longitude and timestamp fields.
class DigitalTwinBall {
  final String id;
  final double latitude;
  final double longitude;
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
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      };
}
