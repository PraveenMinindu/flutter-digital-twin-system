import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/models/digital_twin_ball.dart';
import '../../data/services/firestore_service.dart';

class LiveMapController extends ChangeNotifier {
  final FirestoreService _firestoreService;

  LiveMapController({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  DigitalTwinBall? _ball;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<DigitalTwinBall>? _subscription;

  DigitalTwinBall? get ball => _ball;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void startListening() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _firestoreService.streamBallLocation().listen(
      (ballData) {
        _ball = ballData;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
