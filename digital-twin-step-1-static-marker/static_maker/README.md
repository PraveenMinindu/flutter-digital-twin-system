# Step 01 — Static Digital Twin Marker

## Overview

This is the first step in building a Digital Twin system.

At this stage, the system is intentionally simple. It displays a single object (a "digital twin") on a map using coordinates stored in Firebase Firestore.

This project establishes the foundation for all future steps.

---

## What This Step Does

- Reads latitude and longitude from Firestore
- Displays a marker on an OpenStreetMap view
- Updates only when the app reloads (no real-time sync yet)

---

## Tech Stack

- Flutter
- Dart
- Firebase Firestore
- OpenStreetMap (flutter_map)

---

## Architecture

Even for a simple marker, the project follows a clean layered structure:

- **Model** → stores coordinate data
- **Service** → handles Firestore communication
- **Controller** → manages logic
- **UI (Screen)** → renders the map and marker

This separation allows the system to scale without refactoring.

---

## Why This Matters

This step is not about complexity — it is about **structure**.

By enforcing architecture early:
- future features can be added without breaking existing code
- logic remains maintainable
- each component has a clear responsibility

---

## Limitations

- No real-time updates
- No movement tracking
- No prediction or intelligence

---

## Next Step

Step 02 introduces **real-time synchronization** using Firestore snapshot streams, turning this static twin into a live system.

---

## Author

Praveen Minindu