import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/digital_twin_ball.dart';
import '../../data/models/route_result.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/osrm_service.dart';

class BallMapController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final OsrmService _osrm = OsrmService();

  DigitalTwinBall? ball;
  RouteResult? route;

  bool isLoading = true;
  String? error;

  Future<void> fetchBall() async {
    try {
      ball = await _firestore.getBallLocation();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoute() async {
    if (ball == null) return;

    try {
      final start = LatLng(ball!.latitude, ball!.longitude);
      final end = LatLng(6.9344, 79.8428);

      route = await _osrm.getRoute(start, end);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
