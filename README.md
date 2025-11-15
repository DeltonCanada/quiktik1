# QuikTik – Customer Queue App

QuikTik gives customers a live view of their queue tickets, lets them buy spots in line, and guides them to arrive on time with real-time countdowns. The codebase is focused on Saskatchewan data today, but the architecture is ready to scale to additional provinces, establishments, and ticketing flows.

## Features

- Customer-first onboarding with automatic account provisioning and localization (English & French).
- Province → city → establishment navigation with real data for Saskatchewan, including Meadow Lake.
- Secure ticket purchase flow with payment simulation, invoice generation, and active ticket filtering for paid entries only.
- Real-time queue updates, “your turn” countdowns, and home-screen ticket summaries.
- Favorites, testimonials, and marketing content to round out the customer experience.

## Tech Stack

- **Flutter 3.35+** using Material 3 and Riverpod for state management (migration to a layered architecture is in progress).
- **Dart 3** with `flutter_lints`, strongly typed models, and localization helpers.
- Platform targets: Web (Chrome), Android, and Windows desktop (requires Visual Studio with the Desktop C++ workload).

## Getting Started

### 1. Prerequisites

- Flutter SDK ≥ 3.35 (`flutter --version` to confirm).
- Dart SDK is bundled with Flutter.
- For **Android**: Android Studio + SDK manager with a configured emulator.
- For **Windows desktop**: Visual Studio 2019/2022 with the *Desktop development with C++* workload.
- For **iOS/macOS** (optional): Xcode with command line tools.

### 2. Install dependencies

```powershell
flutter pub get
```

### 3. Run the app

Pick the device that matches your environment. Common options:

```powershell
# Web (Chrome)
flutter run -d chrome

# Windows desktop
flutter run -d windows

# Android emulator or physical device
flutter run -d <android-device-id>
```

> Tip: list available targets with `flutter devices`.

## Quality Checks

Use the helper script to format code, run the analyzer, and execute tests in one shot:

```powershell
dart run tool/run_checks.dart
```

Individual commands are also supported:

```powershell
dart format lib test tool
flutter analyze
flutter test
```

## Project Structure

```
lib/
	main.dart                     // App entry point with providers and theming
	screens/                      // Customer flows (auth, onboarding, tickets, etc.)
	services/                     // Queue, auth, favorites, location data
	widgets/                      // Reusable components (buy ticket, countdown, invoices)
	models/                       // Strongly typed data objects
	utils/                        // Localization helpers and supporting utilities
tool/
	run_checks.dart               // Format + analyze + test convenience script
analysis_options.yaml           // Lint rules (extends flutter_lints)
pubspec.yaml                     // Dependencies, assets, and app metadata
```

## Contributing & Next Steps

- Follow the roadmap in the issue tracker (architecture layering, persistence, UI polish, platform hardening).
- Keep commits small and descriptive; run `dart run tool/run_checks.dart` before pushing.
- Update this README and the changelog when you add features or make significant fixes.

Have feedback or a new feature idea? Open an issue or draft a pull request—let’s keep making the queue experience frictionless.
