# Quickstart: Retirement Investment Projection App

## Prerequisites
1. Install Flutter 3.24.x (stable) and Dart 3.2 (`flutter --version` to confirm).
2. Set up Xcode 15+ with iOS 17 SDK for iPhone 14–16 simulator targets.
3. Enable Flutter's Impeller renderer on iOS (`flutter config --enable-impeller` if not default).

## Project Setup
```bash
flutter pub get
```

Project structure follows Flutter's layered guidance:
- `lib/app` – app bootstrap, theme, routing.
- `lib/core` – shared utilities (formatters, validators, tax constants).
- `lib/features/retirement_projection` – data/domain/presentation sublayers for the simulator.
- `test` mirrors `lib` with unit, widget, and integration coverage.

## Running the Simulator
```bash
flutter run --target lib/main.dart -d ios
```
- Primary device: iPhone 15 (6.1"). Ensure results screen fits without horizontal scroll.
- Use `S` in the console to trigger a screenshot for manual review if needed.

## Testing
```bash
# Unit & widget
flutter test

# Integration (launches device/simulator)
flutter test integration_test
```
- Golden tests reside in `test/widget/` and rely on `flutter_test`’s `matchesGoldenFile`.
- Integration flow covers User Stories 1–2, including come-cotas toggle assertions.

## Next Steps
- Populate `.env` (if needed) with regional formatting overrides.
- Coordinate with maintainers to finalize the project constitution before implementation.
