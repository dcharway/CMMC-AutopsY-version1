# CMMC Autopsy — Flutter edition

A Flutter rewrite of the CMMC Autopsy GRC software, targeting **iOS, Android, and web** from a single Dart codebase.

This folder ships the application source (`lib/`) and `pubspec.yaml`. The native iOS / Android / web wrappers are generated locally by `flutter create` so they pick up your developer identity, bundle ID, and signing config.

---

## 1. Install Flutter

Follow https://docs.flutter.dev/get-started/install for your OS. Verify:

```bash
flutter --version
flutter doctor
```

Fix any red items `flutter doctor` reports — typically Android Studio (for Android builds) and Xcode (for iOS builds, **macOS only**).

## 2. Generate the native shells

From this directory (`flutter/`):

```bash
flutter create . \
  --org com.cmmcautopsy \
  --project-name cmmc_autopsy \
  --platforms=android,ios,web
```

That command **adds** `android/`, `ios/`, and `web/` folders without touching the `lib/` source or `pubspec.yaml` that already exist.

## 3. Install dependencies and run

```bash
flutter pub get

# Pick a target:
flutter run                # whichever device is connected
flutter run -d chrome      # web
flutter run -d android     # connected Android device or emulator
flutter run -d ios         # connected iPhone or simulator (macOS only)
```

## 4. Build release artifacts

```bash
# Android — Play Store upload
flutter build appbundle --release

# Android — direct install
flutter build apk --release

# iOS — App Store (macOS only)
flutter build ipa --release

# Web — static site
flutter build web --release
```

The output paths print at the end of each build.

---

## Architecture

```
lib/
├── main.dart                 — bootstrap; provides the GrcStore
├── app.dart                  — MaterialApp + adaptive sidebar shell
├── data/
│   ├── models.dart           — Control, POAM, Evidence, Affirmation, enums
│   └── cmmc_controls.dart    — 120-row seed catalogue + checklist + affirmation
├── state/
│   └── grc_store.dart        — ChangeNotifier store, shared_preferences persistence,
│                               readiness/SPRS scoring, naming-convention regex
├── widgets/
│   └── common.dart           — KpiTile, TagChip, SectionHeader
└── screens/
    ├── dashboard_screen.dart
    ├── control_registry_screen.dart      — searchable table with status dropdown
    ├── poam_tracker_screen.dart          — Kanban board, age meter, editor
    ├── evidence_repository_screen.dart   — upload, tag, naming validation
    ├── assessment_workflow_screen.dart   — 4-phase CAP stepper
    ├── affirmations_screen.dart          — annual attestation tracker
    ├── ai_insights_screen.dart           — rule-based recommendations
    ├── export_center_screen.dart         — CSV / JSON packet via share sheet
    └── settings_screen.dart
```

State persists per-device via `shared_preferences` (UserDefaults on iOS, SharedPreferences on Android, localStorage on web). No backend required for the MVP.

---

## Known limitations of this MVP

- **No real auth / multi-user sync.** Single-device data store.
- **Charts** are intentionally minimal (`fl_chart` pie + linear progress family heatmap). The recharts dashboards in the React version (compliance trend, POA&M velocity, evidence trend) are not reimplemented.
- **Export** writes files to a temp directory and opens the system share sheet. Web exports surface through Share API where supported; otherwise files end up in browser downloads.
- **POA&M Kanban** uses a tap-to-edit pattern rather than drag-and-drop (Flutter's drag-and-drop API across a multi-column board is a separate undertaking).

These are the natural next steps if the MVP is acceptable.
