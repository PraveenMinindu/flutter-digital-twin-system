# Step 02 — Real-Time Digital Twin (Live Sync)

## Overview

This step transforms the static digital twin into a **real-time system**.

Instead of fetching data once, the app now listens to Firestore updates continuously. Any change in the database is instantly reflected on the map.

---

## What This Step Does

- Subscribes to Firestore snapshot streams
- Automatically updates marker position when data changes
- Enables real-time synchronization between database and UI

---

## Key Concept

A Digital Twin is not just a stored representation — it is a **live mirror of the physical world**.

This step introduces that core principle:
> The system does not ask for updates — it receives them.

---

## Tech Stack

- Flutter
- Dart
- Firebase Firestore (Snapshot Streams)
- OpenStreetMap (flutter_map)

---

## How It Works

1. The app connects to Firestore using a snapshot listener
2. Firestore pushes updates whenever coordinates change
3. The UI rebuilds instantly with the new position
4. The marker moves in real time

---

## Performance

- Updates observed in under ~300 ms
- Works over mobile data connection
- No manual refresh required

---

## Architecture Impact

The architecture from Step 01 remains unchanged:
- Model
- Service
- Controller
- UI

Only the **data flow changes**:
- from one-time fetch → to continuous stream

This proves the value of clean architecture.

---

## Why This Matters

This step introduces:
- real-time systems thinking
- event-driven data flow
- live synchronization

This is the foundation for:
- tracking systems
- IoT dashboards
- live location services

---

## Limitations

- No velocity calculation
- No direction tracking
- No prediction logic

---

## Next Step

Step 03 introduces a **velocity engine**, allowing the system to calculate speed and direction using coordinate data.

---

## Author

Praveen Minindu