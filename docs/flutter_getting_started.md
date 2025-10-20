# Flutter Development Walkthrough

This guide helps you set up a full Flutter development environment and bootstrap the Daily Weight Tracker app. It assumes no prior Flutter experience and highlights tooling choices for Visual Studio Code (VS Code) as well as Android Studio.

## 1. Install Flutter and Core Tooling

1. **Download the Flutter SDK**
   - Visit <https://docs.flutter.dev/get-started/install> and choose your platform (Windows, macOS, or Linux).
   - Download the latest *stable* channel zip archive.
   - Extract the archive to a directory you control (e.g., `C:\src\flutter` on Windows or `~/development/flutter` on macOS/Linux).

2. **Add Flutter to your PATH**
   - Update your shell profile so that the `flutter/bin` directory is on the PATH.
   - Restart your terminal and run `flutter --version` to confirm.

3. **Install Android Studio (recommended even if you use VS Code)**
   - Download from <https://developer.android.com/studio>.
   - During installation, ensure the Android SDK, Android SDK Command-line Tools, and Android Emulator components are selected.
   - After installation, open Android Studio once so it can finish installing dependencies.

4. **Accept Android licenses**
   - Run `flutter doctor --android-licenses` and accept all prompts. This prevents build failures later.

5. **Install the Dart and Flutter extensions for VS Code**
   - In VS Code, open the Extensions panel (`Ctrl+Shift+X` / `Cmd+Shift+X`).
   - Search for "Flutter" and install the official Flutter extension (it installs the Dart extension automatically).

6. **(Optional) Install Xcode if you later want iOS support**
   - Not required for the Android-focused milestone but useful for the future.

### Why keep Android Studio around?
Even if you prefer VS Code, Android Studio provides:
- Device Manager to create Android emulators quickly.
- SDK Manager for managing build tools and system images.
- Additional profilers/debuggers you can invoke when needed.

## 2. Validate Your Environment

1. Open a terminal and run `flutter doctor`.
2. Review the output carefully. Each section should show a green check mark. If any section has issues, follow the linked instructions or the hints in the output to resolve them.
3. Ensure that `Chrome` or another web browser is listed only if you plan to run the Flutter web target. The primary device should be an Android emulator or a connected physical phone.

## 3. Clone and Explore This Repository

```bash
git clone <repo-url>
cd codex-pilot
```

- The planning documents live under `docs/`.
- The Flutter source will be created in `app/` (next step).

## 4. Create the Flutter Application Scaffold

1. From the repository root, run:
   ```bash
   flutter create app
   ```
   This generates a new Flutter project in `app/`.

2. Open the `app` folder in VS Code (`File > Open Folder` or `code app` from the terminal).

3. Launch VS Code in "workspace" mode by creating a `.code-workspace` file if you plan to keep docs and code side-by-side. This is optional but convenient.

## 5. Configure Baseline Dependencies

We will gradually add the packages referenced in the architecture document. For the first milestone, edit `app/pubspec.yaml` and add the following under `dependencies` or `dev_dependencies` as indicated:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_local_notifications: ^17.1.0
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.2
  drift: ^2.14.1
  drift_flutter: ^2.5.0
  sqlite3_flutter_libs: ^0.5.21
  fl_chart: ^0.68.0
  csv: ^6.0.0
  googleapis: ^12.0.0
  google_sign_in: ^6.2.1
  intl: ^0.19.0

dev_dependencies:
  drift_dev: ^2.14.1
  build_runner: ^2.4.9
  flutter_lints: ^4.0.0
```

After editing, run:
```bash
flutter pub get
```
This fetches the packages and ensures the project still builds.

## 6. Prepare Emulators or Devices

### Using Android Studio (Device Manager)
1. Open **Android Studio** > **More Actions** > **Device Manager**.
2. Click **Create Device** and choose a phone profile (Pixel 6 is a good baseline).
3. Pick the latest stable system image that matches the minimum SDK in the project (API 33 or above recommended).
4. Finish the wizard and press the play icon to launch the emulator.

### Using a Physical Android Device
1. Enable **Developer Options** and **USB Debugging** on your phone.
2. Connect via USB (or Wi-Fi debugging on Android 11+).
3. Run `flutter devices` to confirm the phone appears.

## 7. Run the Starter App

From the `app/` directory:
```bash
flutter run
```
Select the emulator/phone if prompted. You should see the default Flutter counter app. This confirms your toolchain is ready.

To stop the app, press `q` in the terminal or use the stop button in VS Code/Android Studio.

## 8. Recommended VS Code Workflow

1. **Use the Flutter extension’s commands**
   - `Ctrl+Shift+P` / `Cmd+Shift+P` and type `Flutter:` to access commands like *Launch Emulator*, *Create New Project*, *Run Flutter Doctor*, etc.

2. **Dart DevTools integration**
   - When you run the app from VS Code (`F5`), click the "Dart DevTools" button in the status bar to open debugging tools (widget inspector, performance, memory).

3. **Hot Reload vs. Hot Restart**
   - `r` in the terminal or the **Hot Reload** button applies most UI changes instantly.
   - `Shift+R` or **Hot Restart** resets the app state without a full rebuild.

4. **Code actions and formatting**
   - VS Code automatically formats Dart files when you save if `editor.formatOnSave` is enabled.
   - Use quick fixes (`Ctrl+.` / `Cmd+.`) to apply suggestions from the Dart analyzer.

## 9. Alternative: Android Studio/IntelliJ Workflow

If you prefer a full IDE:

1. Install the Flutter and Dart plugins from **Android Studio > Settings > Plugins**.
2. Open the `app/` project and let the IDE index files.
3. Use the **Run** or **Debug** buttons to start the app. Android Studio also offers layout inspectors, performance profilers, and device file explorers.
4. Consider enabling **Material 3 preview** and **Compose Multiplatform** (if you later explore Kotlin UI) for design references.

## 10. Next Steps After Bootstrap

You now have a stock Flutter app that runs. The goal of this section is to convert that blank slate into the project structure we designed. Treat this as a guided checklist you can follow in order.

### 10.1 Organize the Project Structure

1. Inside `app/lib/`, remove the default `main.dart` content **only after** you copy a backup (e.g., rename to `main_counter_backup.dart`) so you can refer to Flutter’s starter example later.
2. Create the following folders to mirror the architecture document:
   ```text
   app/lib/
     core/
       routing/
       theme/
       utils/
     features/
       dashboard/
       history/
       log_entry/
       settings/
     data/
       local/
       sync/
   ```
3. Add a `main.dart` that only wires the app shell (imports will be filled in later). A minimal placeholder is fine for now:
   ```dart
   import 'package:flutter/material.dart';

   void main() {
     runApp(const PlaceholderApp());
   }

   class PlaceholderApp extends StatelessWidget {
     const PlaceholderApp({super.key});

     @override
     Widget build(BuildContext context) {
       return const MaterialApp(
         home: Scaffold(
           body: Center(child: Text('Daily Weight Tracker bootstrap')), 
         ),
       );
     }
   }
   ```

### 10.2 Initialize Riverpod and GoRouter

1. Add `hooks_riverpod` to `pubspec.yaml` if you prefer Hooks; otherwise, continue with `flutter_riverpod` alone.
2. In `core/routing/app_router.dart`, declare a basic router:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:go_router/go_router.dart';

   final routerProvider = Provider<GoRouter>((ref) {
     return GoRouter(
       initialLocation: '/dashboard',
       routes: [
         GoRoute(
           path: '/dashboard',
           builder: (context, state) => const DashboardPage(),
         ),
       ],
     );
   });
   ```
3. Update `main.dart` to use `ProviderScope` and the router (note the additional imports):
   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';

   void main() {
     runApp(const ProviderScope(child: AppBootstrap()));
   }

   class AppBootstrap extends ConsumerWidget {
     const AppBootstrap({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final router = ref.watch(routerProvider);
       return MaterialApp.router(
         routerConfig: router,
         theme: lightTheme,
         darkTheme: darkTheme,
       );
     }
   }
   ```
4. For now, create placeholder widgets (`DashboardPage`, etc.) that render `Scaffold(body: Center(child: Text('...')))`. This keeps routing functioning until the real UI exists.

### 10.3 Implement Theme Management

1. Under `core/theme/`, create:
   - `app_theme.dart` with `ThemeData` definitions for light/dark variants.
   - `theme_controller.dart` with a `StateNotifier` or `Notifier` that exposes the selected theme mode and secondary color choice.
2. Store user preferences via `SharedPreferences` initially, or go straight to Drift once the database layer is ready.
3. Wire the controller into Riverpod so `AppBootstrap` can read the `ThemeMode` and selected color.

### 10.4 Create the Drift Database Skeleton

1. In `data/local/app_database.dart`, declare the Drift database and tables described in the architecture document:
   ```dart
   @DriftDatabase(tables: [WeightEntries, Goals, ReminderConfigs, ThemePrefs])
   class AppDatabase extends _$AppDatabase {
     AppDatabase() : super(_openConnection());
     @override
     int get schemaVersion => 1;
   }
   ```
2. Define each table in separate files (e.g., `weight_entries_table.dart`) to keep the schema tidy.
3. Run `flutter pub run build_runner build` to generate the `.g.dart` files. Commit both the schema files and generated code.
4. Expose repositories/providers in `data/local` that return typed APIs (`WeightEntryRepository`, `GoalRepository`, etc.).

### 10.5 Stub Notification Scheduling

1. Create `features/log_entry/services/reminder_service.dart` with a class that wraps `flutter_local_notifications`.
2. Implement methods for:
   - `scheduleDailyReminder(ReminderConfig config)`
   - `cancelReminder(int id)`
   - `snoozeReminder(Duration delta)`
3. Use Riverpod providers to bridge the service with the stored `ReminderConfig`. Start with logging statements before wiring real scheduling logic to validate that flows are triggered correctly.

### 10.6 Build Feature Screens Incrementally

1. **Dashboard** – start with cards showing today’s weight, trend placeholder text, and action buttons to log weight or view history.
2. **Log Entry Modal** – create a `showModalBottomSheet` with a numeric input, date picker, and notes field. Connect it to the repository to insert/update entries.
3. **History** – display a `PaginatedDataTable` or `ListView` with past entries; later, add `fl_chart` graphs with trends versus goals.
4. **Settings** – expose reminder schedule controls, theme selection, and export/import actions.

### 10.7 Enable CSV Export/Import (Foundation)

1. Create a `CsvService` in `data/sync/` that can:
   - Export all `weight_entries` to a temporary directory.
   - Parse a CSV file and insert/update entries.
2. For now, expose these actions via buttons in the Settings screen. Actual Google Drive sync can build on this later.

### 10.8 Track Progress with Source Control

1. Commit after each major subsection above (project structure, Riverpod wiring, database setup, etc.).
2. Use `git status` often to make sure generated files are included/excluded correctly (consider adding `lib/**.g.dart` to `.gitignore` only if they can be regenerated reliably; otherwise, commit them).

At the end of these steps you will have the foundational architecture in place and can move on to implementing the detailed user stories from `docs/product_requirements.md`. Keep referring back to the architecture and requirements documents as you flesh out each milestone. If you encounter issues, the `flutter doctor -v` output and the official docs are invaluable troubleshooting aids.

