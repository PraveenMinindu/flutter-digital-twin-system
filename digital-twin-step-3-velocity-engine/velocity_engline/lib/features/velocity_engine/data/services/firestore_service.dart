import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/digital_twin_ball.dart';

/// Responsible ONLY for talking to Firestore.
/// Returns a real-time stream — every time a document changes, the stream
/// emits the full updated list.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.ballsCollection);

  /// Emits a new list of [DigitalTwinBall] every time Firestore changes.
  Stream<List<DigitalTwinBall>> watchBalls() {
    return _col
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DigitalTwinBall.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Write a new position (useful for testing from the app).
  Future<void> updatePosition({
    required String docId,
    required double latitude,
    required double longitude,
  }) {
    return _col.doc(docId).set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
