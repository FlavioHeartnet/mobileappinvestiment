<!--
Sync Impact Report
Version change: 0.0.0 → 1.0.0
Modified principles:
- N/A (initial constitution content)
Added sections:
- Architecture Standards
- Workflow & Quality Gates
Removed sections:
- None
Templates requiring updates:
- ✅ .specify/templates/plan-template.md (reviewed, aligns with constitution)
- ✅ .specify/templates/spec-template.md (reviewed, aligns with constitution)
- ✅ .specify/templates/tasks-template.md (updated for MVVM/mobile focus)
- ✅ .specify/templates/agent-file-template.md (reviewed, no changes required)
Follow-up TODOs:
- None
-->
# Simulador Investimento App Constitution

## Core Principles

### I. Flutter MVVM Foundation
All features MUST follow Flutter’s official application structure with a clear MVVM separation: Views handle rendering, ViewModels hold presentation state and expose commands, and Models encapsulate domain rules. Business logic MUST not live in widgets; ViewModels MUST remain platform-agnostic and testable without UI bindings.

### II. Clean Code Boundaries
We enforce Clean Code practices: single responsibility per file/class, dependency injection for collaborators, and no hidden globals. Shared logic lives under `lib/core/` and feature-specific logic under `lib/features/<feature>/`. Any cross-feature reuse requires explicit agreement and documentation in plan.md.

### III. Offline Deterministic Calculations
The simulator MUST run entirely on-device without remote or persistent databases. Calculations, tax tables, and user inputs stay in memory, and deterministic rounding (two decimal places) MUST be applied at each ledger step to guarantee reproducible results across devices.

### IV. Evidence-Driven Testing
Every change MUST include automated coverage at the appropriate level: domain calculations covered by unit tests, ViewModels by widget/unit hybrids, and primary journeys by integration tests. Tests MUST run on CI with Flutter’s stable toolchain and fail before implementation during TDD cycles when feasible.

### V. Mobile Experience Integrity
Layouts MUST target current 6.1" iPhone-class devices, preserving legibility, accessibility (44px touch targets, 14pt text), and 60fps responsiveness. Material 3 components are the baseline; deviations require documented rationale and design sign-off.

## Architecture Standards

- Flutter 3.24.x (stable) and Dart 3.2 are the authoritative toolchain versions. Tool upgrades require constitution amendment or explicit approval captured in plan.md.
- State management MUST use `provider` + `ChangeNotifier` unless a plan documents a justified alternative. ViewModels expose immutable UI state snapshots and command methods.
- No database layers are permitted. Ephemeral caching may use in-memory collections only. Any future persistence proposals demand an amendment specifying storage rules.
- Numeric utilities, currency formatting, and tax constants reside in `lib/core/finance/` with reusable unit-tested helpers.
- Feature modules MUST expose a public API via barrel files under `lib/features/<feature>/`.

## Workflow & Quality Gates

- Implementation plans MUST record toolchain versions, state management choices, and constitution compliance notes before coding begins.
- Research (Phase 0) MUST resolve all NEEDS CLARIFICATION items related to MVVM boundaries, tax logic, and performance before moving to design.
- Pull requests MUST reference the associated plan.md section validating adherence to Core Principles III and IV (accuracy and testing).
- QA sign-off requires passing `flutter test`, `flutter test integration_test`, and manual verification on a 6.1" iOS simulator.
- Any deviation from MVVM or Clean Code boundaries MUST include a mitigation task in tasks.md and be resolved before release.

## Governance

This constitution supersedes conflicting project guidance. Amendments require:
1. Drafting proposed changes with rationale and impact analysis.
2. Reviewing affected templates (plan/spec/tasks/agent files) and documenting updates.
3. Incrementing the constitution version per semantic rules and recording the amendment date.
4. Obtaining maintainer approval before merging changes.

Compliance is verified during plan reviews, code reviews, and release readiness checks. Non-compliance blocks merges until rectified. Historical versions MUST remain accessible via version control history.

**Version**: 1.0.0 | **Ratified**: 2025-11-03 | **Last Amended**: 2025-11-03
