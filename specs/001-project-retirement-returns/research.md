# Research Notes

## Flutter SDK Baseline
- Decision: Adopt Flutter 3.24.x (stable channel) with Dart 3.2 for development.
- Rationale: Latest stable release (Q4 2025) guarantees compatibility with iOS 17-era devices, includes Impeller defaults for smoother rendering, and aligns with Flutter documentation that recommends staying on the stable channel for production apps.
- Alternatives considered: Flutter 3.19/3.22 LTS (would forgo Material 3 updates) and beta channel builds (higher risk, not aligned with official guidance).

## State Management & Core Dependencies
- Decision: Use the Flutter SDK with Material 3 widgets, `provider` + `ChangeNotifier` for state management, and `intl` for currency/date formatting.
- Rationale: Flutter's official architecture guidance demonstrates layered design with `ChangeNotifier` and `provider`; the packages are lightweight, first-party endorsed, and integrate cleanly with declarative UI.
- Alternatives considered: `flutter_riverpod` and `bloc` (more boilerplate for this scope), custom inherited widgets (less maintainable, deviates from guidance).

## Testing Strategy
- Decision: Leverage `flutter_test` for unit/widget tests, `integration_test` for end-to-end user journeys, and built-in golden testing via `flutter_test` for key UI snapshots.
- Rationale: Matches Flutter's official testing pyramid (unit → widget → integration), keeps tooling within the standard SDK, and supports automated verification of tax calculations and responsive layouts.
- Alternatives considered: Manual QA only (insufficient), deprecated `flutter_driver` (no longer recommended), third-party snapshot tools (unnecessary dependency).

## Target Platform Scope
- Decision: Prioritize iOS 16+ (iPhone 14–16 class, 6.1" viewport) while maintaining Flutter's cross-platform compatibility for future Android enablement.
- Rationale: Specification mandates newest iPhones, and Flutter's layout/adaptive guidance encourages designing to a reference device before expanding; Android parity can follow once core experience validated.
- Alternatives considered: Simultaneous Android optimization (dilutes focus), tablet-first approach (out of scope).

## Governance Gap
- Decision: Escalate the empty constitution file to project maintainers and track it as a blocker before implementation.
- Rationale: Without ratified principles we cannot certify compliance with governance gates; documenting the gap keeps the plan transparent.
- Alternatives considered: Proceed without governance (violates process), invent unofficial principles (creates misalignment).
