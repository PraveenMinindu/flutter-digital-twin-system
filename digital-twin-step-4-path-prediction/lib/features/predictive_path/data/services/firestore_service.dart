// lib/features/predictive_path/data/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/tracking_point.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<TrackingPoint>> streamPredictionPoints() {
    return _db
        .collection(AppConstants.pointsCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TrackingPoint.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> writePlace1() async {
    await _db.collection(AppConstants.pointsCollection).doc('point_001').set({
      'latitude': 6.9271,
      'longitude': 79.8612,
      'is_active': true,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> writePlace2() async {
    await _db.collection(AppConstants.pointsCollection).doc('point_002').set({
      'latitude': 6.9278,
      'longitude': 79.8620,
      'is_active': true,
      'timestamp': Timestamp.fromDate(
        DateTime.now().add(const Duration(seconds: 5)),
      ),
    });
  }

  Future<void> writePlace3() async {
    await _db.collection(AppConstants.pointsCollection).doc('point_003').set({
      'latitude': 6.9286,
      'longitude': 79.8628,
      'is_active': true,
      'timestamp': Timestamp.fromDate(
        DateTime.now().add(const Duration(seconds: 10)),
      ),
    });
  }

  Future<void> writePlace4() async {
    await _db.collection(AppConstants.pointsCollection).doc('point_004').set({
      'latitude': 6.9294,
      'longitude': 79.8636,
      'is_active': true,
      'timestamp': Timestamp.fromDate(
        DateTime.now().add(const Duration(seconds: 15)),
      ),
    });
  }

  Future<void> writeAllDemoPlaces() async {
    final now = DateTime.now();
    final batch = _db.batch();
    final col = _db.collection(AppConstants.pointsCollection);

    batch.set(col.doc('point_001'), {
      'latitude': 6.9271,
      'longitude': 79.8612,
      'is_active': true,
      'timestamp': Timestamp.fromDate(now),
    });

    batch.set(col.doc('point_002'), {
      'latitude': 6.9278,
      'longitude': 79.8620,
      'is_active': true,
      'timestamp': Timestamp.fromDate(now.add(const Duration(seconds: 5))),
    });

    batch.set(col.doc('point_003'), {
      'latitude': 6.9286,
      'longitude': 79.8628,
      'is_active': true,
      'timestamp': Timestamp.fromDate(now.add(const Duration(seconds: 10))),
    });

    batch.set(col.doc('point_004'), {
      'latitude': 6.9294,
      'longitude': 79.8636,
      'is_active': true,
      'timestamp': Timestamp.fromDate(now.add(const Duration(seconds: 15))),
    });

    await batch.commit();
  }

  Future<void> clearAllPoints() async {
    final snapshot = await _db.collection(AppConstants.pointsCollection).get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
