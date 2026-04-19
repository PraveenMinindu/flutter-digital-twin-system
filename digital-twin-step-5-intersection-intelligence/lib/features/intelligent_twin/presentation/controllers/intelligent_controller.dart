// lib/features/intelligent_twin/presentation/controllers/intelligent_controller.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/intersection_result.dart';
import '../../data/models/predicted_path.dart';
import '../../data/models/twin_object.dart';
import '../../data/models/velocity_data.dart';
import '../../data/services/firestore_service.dart';

class IntelligentController extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  TwinObject? objectA;
  TwinObject? previousA;
  TwinObject? objectB;

  VelocityData velocityA = VelocityData.zero;
  PredictedPath predictedPathA = PredictedPath.empty;
  IntersectionResult intersection = IntersectionResult.none;

  bool isLoading = true;
  String? errorMessage;

  StreamSubscription<TwinObject?>? _subA;
  StreamSubscription<TwinObject?>? _subB;

  void startTracking() {
    _subB = _service.watchObjectB().listen(
      (b) {
        objectB = b;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );

    _subA = _service.watchObjectA().listen(
      _onObjectAUpdated,
      onError: (e) {
        errorMessage = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );

    isLoading = false;
    notifyListeners();
  }

  Future<void> _onObjectAUpdated(TwinObject? latest) async {
    if (latest == null) {
      objectA = null;
      notifyListeners();
      return;
    }

    if (objectA == null) {
      objectA = latest;
      notifyListeners();
      return;
    }

    if (latest.timestamp == objectA!.timestamp &&
        latest.latitude == objectA!.latitude &&
        latest.longitude == objectA!.longitude) {
      return;
    }

    previousA = objectA;
    objectA = latest;

    velocityA = _calculateVelocity(previousA!, objectA!);
    predictedPathA = _buildPredictedPath(objectA!, velocityA);

    if (objectB != null && predictedPathA.hasPoints) {
      intersection = _findMeetingPoint(objectB!, predictedPathA);

      if (intersection.found) {
        await _stepObjectBToward(objectB!, intersection.meetingPoint);
      }
    } else {
      intersection = IntersectionResult.none;
    }

    notifyListeners();
  }

  VelocityData _calculateVelocity(TwinObject from, TwinObject to) {
    final distM = _haversineDistance(
      lat1: from.latitude,
      lng1: from.longitude,
      lat2: to.latitude,
      lng2: to.longitude,
    );

    final elapsedSec =
        to.timestamp.difference(from.timestamp).inMilliseconds / 1000.0;

    final speedMs = elapsedSec > 0 ? distM / elapsedSec : 0.0;

    final heading = _bearing(
      lat1: from.latitude,
      lng1: from.longitude,
      lat2: to.latitude,
      lng2: to.longitude,
    );

    return VelocityData(
      speedMetersPerSecond: speedMs,
      headingDegrees: heading,
      distanceMeters: distM,
      elapsedSeconds: elapsedSec,
    );
  }

  PredictedPath _buildPredictedPath(TwinObject origin, VelocityData vel) {
    if (vel.speedMetersPerSecond <= 0) return PredictedPath.empty;

    final int steps = AppConstants.predictionSteps;
    final double stepSec = AppConstants.predictionHorizonSeconds / steps;
    final double stepM = vel.speedMetersPerSecond * stepSec;

    double lat = origin.latitude;
    double lng = origin.longitude;

    final List<LatLng> points = [LatLng(lat, lng)];

    for (int i = 0; i < steps; i++) {
      final next = _destinationPoint(
        lat: lat,
        lng: lng,
        distanceMeters: stepM,
        headingDegrees: vel.headingDegrees,
      );
      points.add(next);
      lat = next.latitude;
      lng = next.longitude;
    }

    return PredictedPath(points: points);
  }

  IntersectionResult _findMeetingPoint(TwinObject b, PredictedPath pathA) {
    final double bSpeed = AppConstants.objectBSpeedMs;
    final double stepSec =
        AppConstants.predictionHorizonSeconds / AppConstants.predictionSteps;

    for (int i = 1; i < pathA.points.length; i++) {
      final candidate = pathA.points[i];
      final timeForA = i * stepSec;

      final distBToPoint = _haversineDistance(
        lat1: b.latitude,
        lng1: b.longitude,
        lat2: candidate.latitude,
        lng2: candidate.longitude,
      );

      final timeForB = distBToPoint / bSpeed;

      if (timeForB <= timeForA) {
        return IntersectionResult(
          meetingPoint: candidate,
          pathBToMeeting: [LatLng(b.latitude, b.longitude), candidate],
          estimatedTimeSec: timeForB,
          found: true,
        );
      }
    }

    return IntersectionResult.none;
  }

  Future<void> _stepObjectBToward(TwinObject b, LatLng target) async {
    final dist = _haversineDistance(
      lat1: b.latitude,
      lng1: b.longitude,
      lat2: target.latitude,
      lng2: target.longitude,
    );

    if (dist < 1) return;

    final double stepMeters = 8.0;

    if (dist <= stepMeters) {
      await _service.setObjectB(target.latitude, target.longitude);
      return;
    }

    final bearingDeg = _bearing(
      lat1: b.latitude,
      lng1: b.longitude,
      lat2: target.latitude,
      lng2: target.longitude,
    );

    final next = _destinationPoint(
      lat: b.latitude,
      lng: b.longitude,
      distanceMeters: stepMeters,
      headingDegrees: bearingDeg,
    );

    await _service.setObjectB(next.latitude, next.longitude);
  }

  Future<void> loadDemo() => _service.loadDemoObjects();
  Future<void> moveAPlace1() => _service.moveAToPlace1();
  Future<void> moveAPlace2() => _service.moveAToPlace2();
  Future<void> moveAPlace3() => _service.moveAToPlace3();
  Future<void> moveAPlace4() => _service.moveAToPlace4();
  Future<void> resetObjects() => _service.resetObjects();

  double _haversineDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const double earthRadius = 6371000;

    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);

    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.pow(math.sin(dLng / 2), 2);

    final c =
        2 * math.atan2(math.sqrt(a.toDouble()), math.sqrt(1 - a.toDouble()));

    return earthRadius * c;
  }

  double _bearing({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final dLng = _degToRad(lng2 - lng1);

    final y = math.sin(dLng) * math.cos(_degToRad(lat2));
    final x =
        math.cos(_degToRad(lat1)) * math.sin(_degToRad(lat2)) -
        math.sin(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.cos(dLng);

    return (_radToDeg(math.atan2(y, x)) + 360) % 360;
  }

  LatLng _destinationPoint({
    required double lat,
    required double lng,
    required double distanceMeters,
    required double headingDegrees,
  }) {
    const double earthRadius = 6371000;

    final brng = _degToRad(headingDegrees);
    final lat1 = _degToRad(lat);
    final lng1 = _degToRad(lng);
    final angDist = distanceMeters / earthRadius;

    final lat2 = math.asin(
      math.sin(lat1) * math.cos(angDist) +
          math.cos(lat1) * math.sin(angDist) * math.cos(brng),
    );

    final lng2 =
        lng1 +
        math.atan2(
          math.sin(brng) * math.sin(angDist) * math.cos(lat1),
          math.cos(angDist) - math.sin(lat1) * math.sin(lat2),
        );

    return LatLng(_radToDeg(lat2), _radToDeg(lng2));
  }

  double _degToRad(double deg) => deg * math.pi / 180;
  double _radToDeg(double rad) => rad * 180 / math.pi;

  @override
  void dispose() {
    _subA?.cancel();
    _subB?.cancel();
    super.dispose();
  }
}
