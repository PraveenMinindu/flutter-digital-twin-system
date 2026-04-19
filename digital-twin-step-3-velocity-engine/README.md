# Digital Twin – Step 3: Velocity Engine 
> Builds on Step 1 (static marker) and Step 2 (live sync).  
> Adds **speed**, **heading**, and **distance** calculated from two consecutive Firestore positions.

---

## How the Velocity Calculation Works

```
Position A  ──────────────────────────────►  Position B
(lat1, lng1, timestamp1)                    (lat2, lng2, timestamp2)
```

### Step 1 — Distance (Haversine formula)
The Earth is curved, so we can't use flat Pythagoras.  
The **Haversine formula** calculates the shortest path between two lat/lng points on a sphere.

```
a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlng/2)
c = 2 × atan2(√a, √(1−a))
distance = 6,371,000 m × c        ← Earth radius in metres
```

### Step 2 — Time
```
elapsed_seconds = (timestamp2 - timestamp1).inMilliseconds / 1000
```

### Step 3 — Speed
```
speed (m/s) = distance (m) ÷ elapsed_seconds (s)      ← v = d / t
speed (km/h) = speed (m/s) × 3.6
```

### Step 4 — Heading (Bearing formula)
Gives the compass angle from A → B (0° = North, 90° = East …)

```
y = sin(Δlng) × cos(lat2)
x = cos(lat1) × sin(lat2) − sin(lat1) × cos(lat2) × cos(Δlng)
heading = atan2(y, x)  converted to 0–360°
```

---

## Features

| Feature | Details |
|---|---|
| **Live sync** | Firestore `snapshots()` stream |
| **Speed** | m/s and km/h |
| **Heading** | degrees + compass label (N, NE, E …) |
| **Distance** | metres between last two positions |
| **Map** | OpenStreetMap via `flutter_map` — no API key needed |
| **Telemetry card** | always-visible panel at the bottom of the map |

---

## Getting Started

### 1. Firebase
```bash
flutterfire configure
```

### 2. Firestore collection
Collection: **`digital_twin_balls`**

Each document needs:
```json
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "timestamp": <Firestore Server Timestamp>
}
```

> Update the document repeatedly to simulate movement. The engine detects each
> change and recalculates speed and heading automatically.

### 3. Run
```bash
flutter pub get
flutter run
```

---

## Project Structure

```
lib/
├── core/constants/            # App-wide constants (collection name, defaults)
├── features/velocity_engine/
│   ├── data/
│   │   ├── models/
│   │   │   ├── digital_twin_ball.dart   # Raw Firestore data
│   │   │   └── velocity_data.dart       # Calculated movement output
│   │   └── services/
│   │       └── firestore_service.dart   # Firestore stream + writes
│   └── presentation/
│       ├── controllers/
│       │   └── velocity_controller.dart # Haversine + bearing calculations
│       └── screens/
│           └── velocity_screen.dart     # OSM map + telemetry card
├── firebase_options.dart
└── main.dart
```
