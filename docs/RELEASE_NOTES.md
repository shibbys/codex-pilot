# Alpha Release Notes (v0.1.0-alpha)

## Highlights
- Android-first daily weight tracker with local storage (Drift/SQLite).
- Dashboard with trendline and goal line; ETA includes target date.
- Timeframes: 7 / 15 / 30 / All (forward-fill in Days mode).
- History: tap to edit/delete entries.
- Reminders: daily schedule with fallback when exact alarms are not permitted.
- CSV: export, share, import (with optional pre-clear).
- Theming: preset seed colors; English/Portuguese localization.

## How to Install (APK)
1. Build debug APK: lutter build apk --debug (from pp/).
2. Sideload: db install -r build/app/outputs/flutter-apk/app-debug.apk.
3. First run: allow notifications (Android 13+).

## CSV Locations (Android)
- Export path (emulator/device): /storage/emulated/0/Android/data/<applicationId>/files/.
- For import: place .csv into Downloads or pick via file picker.

## Known Limitations
- Exact alarms require OS permission; app falls back to inexact scheduling.
- iOS is not targeted in this alpha (naming aligned only).
- Chart polish and color picker improvements are planned.

## Near-Term Roadmap
- Color picker dialog (icon trigger), chart header with title + right-aligned fullscreen icon.
- Entries/Days toggle: icon-only (no checkmark), tooltips for clarity.
- History trailing chevron and lighter dividers.
- Logging sheet: formatter, +/- nudge chips, autofocus + haptics.
- Goal chip on Dashboard.