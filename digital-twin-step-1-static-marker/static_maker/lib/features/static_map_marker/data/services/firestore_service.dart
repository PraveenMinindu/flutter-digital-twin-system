import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/digital_twin_ball.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DigitalTwinBall> getBallLocation() async {
    final doc = await _db
        .collection(AppConstants.collectionName)
        .doc(AppConstants.documentId)
        .get();

    if (!doc.exists || doc.data() == null) {
      throw Exception("Ball not found");
    }

    return DigitalTwinBall.fromMap(doc.data()!);
  }
}
