import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/digital_twin_ball.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Stream<DigitalTwinBall> streamBallLocation() {
    return _db
        .collection(AppConstants.collectionName)
        .doc(AppConstants.documentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Ball document not found in Firestore.');
      }

      return DigitalTwinBall.fromMap(doc.data()!);
    });
  }
}
