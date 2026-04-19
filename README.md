# Flutter Digital Twin System

A real-time digital twin system built step-by-step using Flutter, Firebase Firestore, and OpenStreetMap.

## Overview

This project evolves from a simple static map marker into a multi-agent system capable of:

- real-time synchronization
- velocity and direction calculation
- trajectory prediction
- autonomous interception

## Project Stages

### Step 1 — Static Marker
Display a single object from Firestore.

### Step 2 — Live Sync
Real-time updates using Firestore snapshot streams.

### Step 3 — Velocity Engine
Speed and direction using Haversine + bearing formulas.

### Step 4 — Path Prediction
Future trajectory using dead reckoning.

### Step 5 — Intercept Intelligence
Second object calculates and moves to interception point.

## Tech Stack

- Flutter
- Dart
- Firebase Firestore
- OpenStreetMap

## Architecture

- Model
- Service
- Controller
- UI Layer

## Demo

(Add your video or GIF here)

## Future Work

- Kalman filter (GPS smoothing)
- ML-based trajectory prediction
- Multi-object simulation
- Collision avoidance

## Author

Praveen Minindu