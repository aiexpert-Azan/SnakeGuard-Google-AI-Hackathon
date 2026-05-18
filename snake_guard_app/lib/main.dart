import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  runApp(const SnakeGuardApp());
}

class SnakeGuardApp extends StatelessWidget {
  const SnakeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnakeGuard AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}



//Implementation plan

// # Snake Rescue AI Implementation Plan

// This document outlines the architecture, design tokens, and implementation plan for building the Snake Rescue AI Flutter application.

// ## User Review Required

// Please review the proposed folder structure, the packages to be installed, and the mocked API behavior. Since we don't have a real backend at the moment, I will implement a mock `api_service.dart` that simulates the `POST /analyze` and `GET /download-pdf` endpoints with a short delay and the exact JSON structure you specified.

// ## Open Questions

// - Should the location permission handle actual GPS coordinates using a package like `geolocator`, or is the simulated UI with a city dropdown sufficient for this phase?
// - For the Lottie animations (e.g., animated emergency icon, scanning effect), I will use default network Lottie files or create Flutter-native animations if network ones are unavailable. Is that acceptable?
// - Do you have any specific requirements for the mock PDF download behavior? (e.g., using `path_provider` to save a dummy file or just showing a success snackbar?)

// ## Proposed Changes

// We will update `pubspec.yaml` to include all necessary packages, delete the default counter app, and create a scalable folder structure.

// ### pubspec.yaml
// Add the following dependencies:
// - `http`
// - `image_picker`
// - `url_launcher`
// - `google_fonts`
// - `lottie`
// - `flutter_animate`
// - `cached_network_image`

// ### Core & Theme
// We will establish a solid design system utilizing Material 3.

// #### [NEW] lib/core/theme/app_theme.dart
// Defines the dark red emergency gradients, typography via `google_fonts`, and modern component themes.
// #### [NEW] lib/core/constants/colors.dart
// Defines the palette: emergency red, dark backgrounds, glassmorphism opacities.

// ### Data Layer
// Models and services for handling the API interaction.

// #### [NEW] lib/data/models/scan_result.dart
// Data classes for `ScanResult`, `Hospital`, and `TraceLog`.
// #### [NEW] lib/data/services/api_service.dart
// Simulates the network requests, returning the JSON structure with realistic delays to showcase the loading animations.

// ### Presentation Layer
// The UI components and the three main screens.

// #### [NEW] lib/presentation/widgets/primary_button.dart
// Large actionable button with pulse animations and gradients.
// #### [NEW] lib/presentation/widgets/glass_card.dart
// Reusable white card with subtle shadows and blur effects.
// #### [NEW] lib/presentation/widgets/neon_terminal.dart
// Expandable terminal UI for the Agent Trace Logs.
// #### [NEW] lib/presentation/widgets/hospital_card.dart
// Card for nearby hospitals with "Open in Maps" functionality.

// #### [NEW] lib/presentation/screens/location_permission_screen.dart
// Screen 1: Animated emergency icon, simulated location permission UI, city dropdown, and the "Start Emergency Scan" button.
// #### [NEW] lib/presentation/screens/snake_scan_screen.dart
// Screen 2: Image picker integration, camera/gallery buttons, glowing preview, and the "Analyze Snake" button with API simulation.
// #### [NEW] lib/presentation/screens/analysis_results_screen.dart
// Screen 3: Premium dashboard showing the AI results, hospital cards, PDF download button, and neon terminal trace logs.

// #### [MODIFY] lib/main.dart
// Set up the routing, apply `AppTheme`, and set `LocationPermissionScreen` as the initial route.

// ## Verification Plan

// ### Automated Tests
// - The code will be analyzed via `flutter analyze` to ensure clean architecture and null safety.
// - We will verify that the app compiles properly for iOS/Android using `flutter build`.

// ### Manual Verification
// - We will test the navigation flow from Screen 1 to Screen 3.
// - Ensure the image picker correctly selects and displays images.
// - Verify that the simulated API call returns the expected result and the UI updates from a loading state to the results screen.
// - Verify all animations (Hero, flutter_animate, glowing effects) run smoothly.


// TASKS 

// # Snake Rescue AI Tasks

// - [x] Update `pubspec.yaml` with required packages
// - [x] Create core and theme files
// - [x] Implement data models and API service
// - [x] Build reusable UI widgets
// - [x] Implement Location Permission Screen
// - [x] Implement Snake Scan Screen
// - [x] Implement Analysis Results Screen
// - [x] Update `main.dart` and set up routing
