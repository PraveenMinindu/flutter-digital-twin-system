// lib/features/predictive_path/data/models/tracking_point.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingPoint {
  final String id;
  final double latitude;
  final double longitude;
  final bool isActive;
  final DateTime timestamp;

  TrackingPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.timestamp,
  });

  factory TrackingPoint.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    final ts = data['timestamp'];
    DateTime parsedTime;

    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else {
      parsedTime = DateTime.now();
    }

    return TrackingPoint(
      id: doc.id,
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      isActive: data['is_active'] ?? false,
      timestamp: parsedTime,
    );
  }
}
