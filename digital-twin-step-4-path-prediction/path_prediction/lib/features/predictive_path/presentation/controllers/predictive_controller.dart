// lib/features/predictive_path/presentation/controllers/predictive_controller.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/tracking_point.dart';
import '../../data/services/firestore_service.dart';

class PredictiveController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription<List<TrackingPoint>>? _subscription;

  List<TrackingPoint> _points = [];
  List<LatLng> _predictedPath = [];
  TrackingPoint? _currentPoint;
  TrackingPoint? _previousPoint;
  LatLng? _futurePoint;

  bool _isLoading = true;
  String? _errorMessage;

  double _speedMps = 0;
  double _headingDegrees = 0;

  List<TrackingPoint> get points => _points;
  List<LatLng> get predictedPath => _predictedPath;
  TrackingPoint? get currentPoint => _currentPoint;
  TrackingPoint? get previousPoint => _previousPoint;
  LatLng? get futurePoint => _futurePoint;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get speedMps => _speedMps;
  double get headingDegrees => _headingDegrees;

  void startListening() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _firestoreService.streamPredictionPoints().listen(
      (data) {
        _points = data;
        _processPoints();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void _processPoints() {
    if (_points.isEmpty) {
      _currentPoint = null;
      _previousPoint = null;
      _predictedPath = [];
      _futurePoint = null;
      _speedMps = 0;
      _headingDegrees = 0;
      return;
    }

    _currentPoint = _points.last;

    if (_points.length < 2) {
      _previousPoint = null;
      _predictedPath = [];
      _futurePoint = null;
      _speedMps = 0;
      _headingDegrees = 0;
      return;
    }

    _previousPoint = _points[_points.length - 2];

    final prev = _previousPoint!;
    final curr = _currentPoint!;

    final distanceMeters = _calculateDistanceMeters(
      prev.latitude,
      prev.longitude,
      curr.latitude,
      curr.longitude,
    );

    final timeSeconds =
        curr.timestamp.difference(prev.timestamp).inMilliseconds / 1000.0;

    if (timeSeconds > 0) {
      _speedMps = distanceMeters / timeSeconds;
    } else {
      _speedMps = 0;
    }

    _headingDegrees = _calculateHeadingDegrees(
      prev.latitude,
      prev.longitude,
      curr.latitude,
      curr.longitude,
    );

    _predictedPath = _buildPredictionPath(prev, curr);

    if (_predictedPath.isNotEmpty) {
      _futurePoint = _predictedPath.last;
    } else {
      _futurePoint = null;
    }
  }

  List<LatLng> _buildPredictionPath(TrackingPoint prev, TrackingPoint curr) {
    final List<LatLng> path = [];

    final deltaLat = curr.latitude - prev.latitude;
    final deltaLng = curr.longitude - prev.longitude;

    for (int i = 1; i <= AppConstants.predictionSteps; i++) {
      final nextLat = curr.latitude + (deltaLat * i);
      final nextLng = curr.longitude + (deltaLng * i);
      path.add(LatLng(nextLat, nextLng));
    }

    return path;
  }

  double _calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = pow(sin(dLat / 2), 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a.toDouble()), sqrt(1 - a.toDouble()));

    return earthRadius * c;
  }

  double _calculateHeadingDegrees(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLon = _degToRad(lon2 - lon1);

    final y = sin(dLon) * cos(_degToRad(lat2));
    final x = cos(_degToRad(lat1)) * sin(_degToRad(lat2)) -
        sin(_degToRad(lat1)) * cos(_degToRad(lat2)) * cos(dLon);

    final bearing = atan2(y, x);
    return (_radToDeg(bearing) + 360) % 360;
  }

  double _degToRad(double deg) => deg * pi / 180.0;
  double _radToDeg(double rad) => rad * 180.0 / pi;

  Future<void> setPlace1() async => _firestoreService.writePlace1();
  Future<void> setPlace2() async => _firestoreService.writePlace2();
  Future<void> setPlace3() async => _firestoreService.writePlace3();
  Future<void> setPlace4() async => _firestoreService.writePlace4();

  Future<void> loadDemoPath() async => _firestoreService.writeAllDemoPlaces();
  Future<void> clearPoints() async => _firestoreService.clearAllPoints();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
