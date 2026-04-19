import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/digital_twin_ball.dart';
import '../../data/models/velocity_data.dart';
import '../../data/services/firestore_service.dart';

/// The brain of the Velocity Engine.
///
/// Responsibilities:
///   1. Subscribe to the Firestore stream.
///   2. Remember the PREVIOUS position so we can compare with the NEW one.
///   3. Calculate distance, time, speed and heading.
///   4. Notify the UI whenever anything changes.
class VelocityController extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  // ── State ──────────────────────────────────────────────────────────────────

  /// The most recent position received from Firestore.
  DigitalTwinBall? currentBall;

  /// The position just BEFORE the latest update (used for calculations).
  DigitalTwinBall? previousBall;

  /// The computed movement data. Starts at zero until two positions exist.
  VelocityData velocity = VelocityData.zero;

  bool isLoading = true;
  String? errorMessage;

  StreamSubscription<List<DigitalTwinBall>>? _sub;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call once from initState to start listening.
  void startTracking() {
    _sub = _service.watchBalls().listen(
      _onNewData,
      onError: (e) {
        errorMessage = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Internal logic ─────────────────────────────────────────────────────────

  void _onNewData(List<DigitalTwinBall> balls) {
    if (balls.isEmpty) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // We track the FIRST document in the collection.
    // In a real system each device would have its own document ID.
    final latest = balls.last;

    // If this is the very first update, just store it and wait for the next one.
    if (currentBall == null) {
      currentBall = latest;
      isLoading = false;
      notifyListeners();
      return;
    }

    // Don't recalculate if the position hasn't actually changed.
    if (latest.timestamp == currentBall!.timestamp) return;

    // Shift: current → previous, latest → current.
    previousBall = currentBall;
    currentBall = latest;

    // Now we have two points — calculate everything!
    velocity = _calculateVelocity(previousBall!, currentBall!);

    isLoading = false;
    notifyListeners();
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// VELOCITY CALCULATION — explained step by step
  /// ─────────────────────────────────────────────────────────────────────────
  VelocityData _calculateVelocity(
    DigitalTwinBall from,
    DigitalTwinBall to,
  ) {
    // ── STEP 1: Distance ────────────────────────────────────────────────────
    // The Earth is a sphere, so we can't use flat Pythagoras.
    // The Haversine formula gives the shortest surface distance between two
    // lat/lng points in metres.
    final distanceMeters = _haversineDistance(
      lat1: from.latitude,
      lng1: from.longitude,
      lat2: to.latitude,
      lng2: to.longitude,
    );

    // ── STEP 2: Time ────────────────────────────────────────────────────────
    // Subtract the two DateTime timestamps to get elapsed seconds.
    final elapsedSeconds =
        to.timestamp.difference(from.timestamp).inMilliseconds / 1000.0;

    // ── STEP 3: Speed ───────────────────────────────────────────────────────
    // Speed = Distance ÷ Time  (basic physics: v = d / t)
    // Guard against division by zero (timestamps identical = no time passed).
    final speedMs = elapsedSeconds > 0 ? distanceMeters / elapsedSeconds : 0.0;

    // ── STEP 4: Heading ─────────────────────────────────────────────────────
    // Bearing formula tells us the compass angle from point A to point B.
    // Result is in degrees: 0° = North, 90° = East, 180° = South, 270° = West.
    final headingDeg = _bearing(
      lat1: from.latitude,
      lng1: from.longitude,
      lat2: to.latitude,
      lng2: to.longitude,
    );

    return VelocityData(
      speedMetersPerSecond: speedMs,
      headingDegrees: headingDeg,
      distanceMeters: distanceMeters,
      elapsedSeconds: elapsedSeconds,
    );
  }

  /// Haversine formula — distance in metres between two lat/lng coordinates.
  ///
  /// How it works:
  ///   a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlng/2)
  ///   c = 2 × atan2(√a, √(1−a))
  ///   d = R × c          where R = 6,371,000 m (Earth radius)
  double _haversineDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const earthRadiusMeters = 6371000.0;

    // Convert degrees → radians (math functions need radians)
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.pow(math.sin(dLng / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Bearing formula — compass heading in degrees from point A to point B.
  ///
  /// How it works:
  ///   y = sin(Δlng) × cos(lat2)
  ///   x = cos(lat1) × sin(lat2) − sin(lat1) × cos(lat2) × cos(Δlng)
  ///   θ = atan2(y, x)   → convert to 0–360°
  double _bearing({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final dLng = _toRad(lng2 - lng1);
    final y = math.sin(dLng) * math.cos(_toRad(lat2));
    final x = math.cos(_toRad(lat1)) * math.sin(_toRad(lat2)) -
        math.sin(_toRad(lat1)) * math.cos(_toRad(lat2)) * math.cos(dLng);

    // atan2 returns -π to π; convert to 0–360°
    final bearing = (_toDeg(math.atan2(y, x)) + 360) % 360;
    return bearing;
  }

  double _toRad(double degrees) => degrees * math.pi / 180;
  double _toDeg(double radians) => radians * 180 / math.pi;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
