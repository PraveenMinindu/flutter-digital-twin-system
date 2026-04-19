/// Central place for all app-wide constants.
/// Change these values to point at your own Firestore collection or map center.
class AppConstants {
  AppConstants._();

  static const String appName = 'Digital Twin – Velocity Engine';
  static const String appVersion = '3.0.0';

  // Firestore
  static const String ballsCollection = 'ball_tracker';

  // Default map center (San Francisco)
  static const double defaultLat = 6.9271;
  static const double defaultLng = 79.8612;
  static const double defaultZoom = 15.0;
}
