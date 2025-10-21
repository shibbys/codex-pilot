# codex-pilot
# Daily Weight Tracker App (Flutter)

This repository hosts the planning and implementation for an Android-focused Flutter application that helps users log their daily weight, stay motivated through smart reminders, and visualize progress toward personal goals.

## Current Status
The Flutter application scaffold lives under [`app/`](app/). After cloning the repo, follow the instructions in [`app/README.md`](app/README.md) to install dependencies, generate Drift code, and run the starter experience.

## Getting the Scaffold Locally
If you have trouble seeing the new Flutter files after syncing, double-check that you are on the `work` branch and that you pulled the latest commit (`git fetch origin && git checkout work && git pull`).

The scaffold should include the `app/pubspec.yaml`, `app/lib/main.dart`, and the feature stubs under `app/lib/features/`. Once those files are present, run `flutter pub get` followed by `flutter pub run build_runner build --delete-conflicting-outputs` from the `app/` directory to generate the Drift boilerplate before launching the app.


## Reference Material
- Product requirements: [`docs/product_requirements.md`](docs/product_requirements.md)
- Architecture overview: [`docs/architecture_overview.md`](docs/architecture_overview.md)
- Flutter onboarding walkthrough: [`docs/flutter_getting_started.md`](docs/flutter_getting_started.md)

## High-level Goals
- Daily weight logging with configurable reminders and snooze options.
- Insightful dashboards (charts, projections, goal tracking) built with Flutter.
- Local-first storage with optional CSV export/import and Google Sheets sync.
- Accessible theming with light/dark modes and curated accent palettes.

## Next Steps
1. Expand the Drift data layer with DAOs/repositories and integrate it with Riverpod providers.
2. Flesh out the reminder scheduling flow and snooze actions backed by `flutter_local_notifications`.
3. Build dashboard, history, and settings flows iteratively, adding charts and data tables.
4. Add data portability features (CSV export/import, optional Google Sheets integration).
## Alpha Release
See docs/RELEASE_NOTES.md for current capabilities, install steps, and the near-term UI polish roadmap.
