// lib/features/intelligent_twin/data/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/twin_object.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.objectsCollection);

  Stream<TwinObject?> watchObjectA() {
    return _col.doc(AppConstants.objectADocId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return TwinObject.fromMap(snap.data()!, snap.id);
    });
  }

  Stream<TwinObject?> watchObjectB() {
    return _col.doc(AppConstants.objectBDocId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return TwinObject.fromMap(snap.data()!, snap.id);
    });
  }

  Future<void> setObjectA(double lat, double lng) async {
    await _col.doc(AppConstants.objectADocId).set({
      'latitude': lat,
      'longitude': lng,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setObjectB(double lat, double lng) async {
    await _col.doc(AppConstants.objectBDocId).set({
      'latitude': lat,
      'longitude': lng,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> loadDemoObjects() async {
    final batch = _db.batch();

    batch.set(_col.doc(AppConstants.objectADocId), {
      'latitude': 6.9271,
      'longitude': 79.8612,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

    batch.set(_col.doc(AppConstants.objectBDocId), {
      'latitude': 6.9200,
      'longitude': 79.8450,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> moveAToPlace1() => setObjectA(6.9271, 79.8612);
  Future<void> moveAToPlace2() => setObjectA(6.9278, 79.8620);
  Future<void> moveAToPlace3() => setObjectA(6.9286, 79.8628);
  Future<void> moveAToPlace4() => setObjectA(6.9294, 79.8636);

  Future<void> resetObjects() async {
    final batch = _db.batch();
    batch.delete(_col.doc(AppConstants.objectADocId));
    batch.delete(_col.doc(AppConstants.objectBDocId));
    await batch.commit();
  }
}
