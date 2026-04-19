// lib/features/intelligent_twin/data/models/twin_object.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TwinObject {
  final String id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const TwinObject({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory TwinObject.fromMap(Map<String, dynamic> map, String docId) {
    final ts = map['timestamp'];
    DateTime parsedTime;

    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else {
      parsedTime = DateTime.now();
    }

    return TwinObject(
      id: docId,
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      timestamp: parsedTime,
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
