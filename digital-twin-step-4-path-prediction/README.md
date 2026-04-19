# Digital Twin - Step 4: Predictive Path

Builds on Steps 1-3.
Adds dead-reckoning prediction: uses current speed and heading to draw a
forward path showing where the object is expected to be in the next N seconds.

---

## Prediction Logic Explained

The technique used here is called dead reckoning.
It assumes the object keeps its current speed and direction for a short time ahead.

```
Current position  ------ predicted path ------->  Future position
(lat, lng, now)         (10 steps x 1 s)           (lat, lng, +10 s)
```

### Step 1 - Divide the horizon into equal slices

  predictionHorizonSeconds = 10   (total seconds to look ahead)
  predictionSteps          = 10   (number of intermediate points)
  stepDuration             = 10 / 10 = 1 second per slice

### Step 2 - Distance per slice

  stepDistance (m) = speed (m/s) x stepDuration (s)

  Example: 5 m/s x 1 s = 5 metres per slice.

### Step 3 - Convert distance + direction to a new coordinate

  We use the Destination Point formula (the inverse of Haversine).
  Given a starting lat/lng, a distance in metres, and a compass heading,
  it returns the exact lat/lng you arrive at.

  lat2 = asin( sin(lat1) * cos(d/R)
              + cos(lat1) * sin(d/R) * cos(heading) )

  lng2 = lng1 + atan2( sin(heading) * sin(d/R) * cos(lat1),
                       cos(d/R) - sin(lat1) * sin(lat2) )

  where d = stepDistance, R = 6 371 000 m (Earth radius).

### Step 4 - Chain the steps

  Each output point becomes the starting point for the next step.
  After 10 iterations we have a list of 11 points (current + 10 future).
  These points are passed directly to a flutter_map Polyline.

---

## Features

| Feature | Detail |
|---|---|
| Live sync | Firestore snapshots stream |
| Velocity | Haversine distance + bearing (from Step 3) |
| Prediction | Dead-reckoning via Destination Point formula |
| Map | OpenStreetMap via flutter_map - no API key |
| Polyline | Orange path from current to predicted position |
| Markers | Indigo dot (current), orange outline (future end) |
| Telemetry card | Speed, heading, prediction horizon, point count |

---

## Getting Started

### 1. Firebase
```bash
flutterfire configure
```

### 2. Firestore document structure
Collection: digital_twin_balls

Each document:
```json
{
  "latitude":  37.7749,
  "longitude": -122.4194,
  "timestamp": <Firestore Server Timestamp>
}
```

Update the document repeatedly to simulate movement.
Each update triggers a new velocity + prediction calculation.

### 3. Run
```bash
flutter pub get
flutter run
```

---

## Tuning the Prediction

Edit lib/core/constants/app_constants.dart:

  predictionHorizonSeconds  — how far ahead to predict (default 10 s)
  predictionSteps           — how many points to generate  (default 10)

Increase steps for a smoother line.
Increase horizon to see further ahead (useful at higher speeds).

---

## Project Structure

```
lib/
  core/constants/
    app_constants.dart              - all tunable values in one place

  features/predictive_path/
    data/
      models/
        digital_twin_ball.dart      - raw Firestore position snapshot
        velocity_data.dart          - calculated speed + heading
        predicted_path.dart         - list of future coordinates
      services/
        firestore_service.dart      - real-time Firestore stream

    presentation/
      controllers/
        predictive_controller.dart  - velocity + prediction calculations
      screens/
        predictive_screen.dart      - OSM map, polyline, telemetry card

  firebase_options.dart
  main.dart
```
