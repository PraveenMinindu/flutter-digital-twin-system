// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appTitle = 'Project 5 - Intelligent Twin';

  // Same Firebase project, but separate collection for Project 5
  static const String objectsCollection = 'ball_intelligent_objects';

  static const String objectADocId = 'object_a';
  static const String objectBDocId = 'object_b';

  static const double defaultLat = 6.9271;
  static const double defaultLng = 79.8612;
  static const double defaultZoom = 14.0;

  // B interceptor speed
  static const double objectBSpeedMs = 8.0;

  // Prediction settings
  static const int predictionSteps = 12;
  static const int predictionHorizonSeconds = 24;
}
