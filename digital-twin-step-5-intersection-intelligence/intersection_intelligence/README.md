# Digital Twin - Step 5: Intelligent Twin

Builds on Steps 1-4.
Introduces a second tracked object (Object B) that automatically calculates
and moves toward the point where it will intercept Object A.

---

## Intersection Logic Explained

The core question is:
  "Which point on Object A's future path can Object B reach before A does?"

This is solved by a time-race scan over the predicted path.

### Step 1 - Generate Object A's predicted path

Reuses the dead-reckoning logic from Project 4.
The path is a list of N equally spaced future positions for Object A,
each separated by a fixed time step (e.g. 1 second).

  path = [pos_0, pos_1, pos_2, ... pos_N]
  pos_i = where A will be after (i x stepDuration) seconds

### Step 2 - Walk the path and race Object B against Object A

For each candidate point pos_i on A's path:

  timeForA = i x stepDuration          (seconds until A reaches pos_i)

  distBToPoint = haversineDistance(B.position, pos_i)

  timeForB = distBToPoint / objectBSpeed    (seconds for B to reach pos_i)

### Step 3 - First point where B wins the race

  if timeForB <= timeForA:
    pos_i is a valid meeting point - use it

The scan stops at the first valid point (the earliest interception).
This is efficient and produces a natural-looking intercept trajectory.

### Step 4 - Move Object B one step toward the meeting point

Each time Object A updates, Object B advances one step of distance
  (objectBSpeedMs x 1 second)
toward the meeting point, and that new position is written back to Firestore.
The map updates in real time via the watchObjectB stream.

### What happens if no point is found?

If Object A is moving faster than Object B in all directions, no point on the
path qualifies (timeForB > timeForA for every candidate).
The UI shows "Intercept: None" and Object B stays in place.

---

## Features

| Feature | Detail |
|---|---|
| Two live objects | Object A and B tracked in Firestore |
| Velocity engine | Haversine distance + bearing (from Step 3) |
| Predicted path | Dead reckoning polyline for Object A (orange) |
| Intersection scan | Time-race across predicted path |
| Auto movement | Object B steps toward meeting point each update |
| Meeting marker | Amber flag marker at the calculated intercept point |
| Teal dashed line | Object B path toward meeting point |
| Telemetry card | Speeds, intercept status, estimated arrival time |

---

## Firestore Setup

Collection: digital_twin_balls

Two documents:

  object_a  - the moving target
  {
    "latitude":  37.7749,
    "longitude": -122.4194,
    "timestamp": <Server Timestamp>
  }

  object_b  - the interceptor (initial position)
  {
    "latitude":  37.7800,
    "longitude": -122.4100,
    "timestamp": <Server Timestamp>
  }

Update object_a repeatedly to simulate movement.
The app will automatically calculate where B should go and update object_b.

---

## Tuning

All tuneable values are in lib/core/constants/app_constants.dart:

  predictionHorizonSeconds  - how far ahead to predict A (default 30 s)
  predictionSteps           - path resolution (default 30 points)
  objectBSpeedMs            - B's travel speed in m/s (default 8.0)

Increase objectBSpeedMs to make B intercept A faster.
Increase predictionHorizonSeconds to look further ahead when A is fast.

---

## Getting Started

  1. Run: flutterfire configure
  2. Create the two Firestore documents above
  3. flutter pub get
  4. flutter run
  5. Update object_a's lat/lng/timestamp to simulate movement

---

## Project Structure

  lib/
    core/constants/
      app_constants.dart                - all tuneable values

    features/intelligent_twin/
      data/
        models/
          twin_object.dart              - raw Firestore position for A or B
          velocity_data.dart            - speed + heading for Object A
          predicted_path.dart           - future coordinates for Object A
          intersection_result.dart      - meeting point + B path + ETA
        services/
          firestore_service.dart        - streams + write for A and B

      presentation/
        controllers/
          intelligent_controller.dart   - full pipeline (velocity, prediction, intersection, B movement)
        screens/
          intelligent_screen.dart       - map + polylines + telemetry card

    firebase_options.dart
    main.dart
