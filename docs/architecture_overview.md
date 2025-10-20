# Daily Weight Tracker App - Architecture Overview

## Technical Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod or Flutter's built-in `ChangeNotifier` for simple modules; Riverpod chosen for testability and modularity.
- **Local Storage**: Drift (SQLite ORM) for structured data + shared_preferences for lightweight settings.
- **Notifications**: flutter_local_notifications with Android-specific scheduling.
- **Charts**: fl_chart for interactive line charts and sparklines.
- **Google Drive Integration**: Google Sheets API via googleapis + oauth2, gated behind optional setup wizard.
- **CSV Export/Import**: csv package for serialization.

## High-level Architecture
```
┌─────────────────────────┐
│        Presentation      │
│  - Screens (Flutter UI)  │
│  - Widgets & Themes      │
│  - Routing (GoRouter)    │
└────────────┬────────────┘
             │
┌────────────▼────────────┐
│     State Management     │
│  - Riverpod providers    │
│  - View models / usecases│
└────────────┬────────────┘
             │
┌────────────▼────────────┐
│        Domain Layer      │
│  - Entities (WeightEntry,│
│    Goal, ReminderConfig) │
│  - Services (TrendCalc,  │
│    ReminderScheduler)    │
└────────────┬────────────┘
             │
┌────────────▼────────────┐
│        Data Layer        │
│  - Repositories          │
│  - Data Sources          │
│    • Local (Drift)       │
│    • Remote (Sheets API) │
│    • CSV adapters        │
└──────────────────────────┘
```

## Data Model Draft
- `WeightEntry`
  - id (uuid)
  - date (DateTime, unique per day)
  - weightKg (double)
  - note (optional)
  - source (manual | import | google_sheet)
- `Goal`
  - targetWeightKg (double)
  - startWeightKg (double)
  - targetDate (optional)
- `ReminderConfig`
  - reminderTime (TimeOfDay)
  - enabledWeekdays (Set<Weekday>)
  - snoozeOptions (default [5,10,30])
- `ThemePrefs`
  - brightness (light|dark|system)
  - accentColorId (enum referencing predefined palette)

## Key Flows
### Daily Logging
1. Notification triggered at configured time.
2. If no weight logged today, deep link opens log screen.
3. On submit, entry stored locally (Drift) and UI providers updated.
4. Sync queue flagged for Sheets export if integration enabled.

### Reminder Scheduling
- Use `flutter_local_notifications` zoned scheduling.
- Riverpod provider exposes scheduler; reschedules whenever reminder config changes or when today's log is completed.
- Snooze actions implemented via notification action buttons.

### Data Sync with Google Sheets
1. User connects Google account via OAuth (optional).
2. App creates or reuses designated sheet with predefined schema.
3. Background isolate handles push/pull sync to avoid blocking UI.
4. Conflict resolution: latest timestamp wins (Drift vs Sheet).
5. Provide manual “sync now” and status feedback in settings.

### CSV Export/Import
- Export: query Drift, convert to list, serialize to CSV, share/save using `share_plus` or file picker.
- Import: parse CSV, validate schema, insert/update entries (respecting unique date).

## Module Breakdown (MVP scope)
1. **App Shell & Navigation**
   - Splash/loading screen
   - Tabs: Dashboard, History, Settings
2. **Dashboard**
   - Today's weight card + quick log button
   - Goal summary, projected goal date
   - Trend line chart (last 30 days) & trend status indicator
3. **History**
   - Table view of entries (sortable, filterable)
   - Secondary chart for longer timeframe
   - Edit/Delete actions per row
4. **Logging Flow**
   - Modal/bottom sheet for entry input
   - Support date override for past entries
5. **Settings**
   - Reminder configuration + snooze defaults
   - Theme selection (light/dark/system + accent palette)
   - Data management (export/import CSV, connect Google Sheets)

## Testing Strategy
- Unit tests for domain services (trend calculations, reminder scheduler logic).
- Widget tests for critical flows (logging modal, dashboard cards).
- Integration tests for storage (Drift queries) and CSV roundtrip.

## Milestones
1. **Foundation**: Flutter project setup, theming, navigation skeleton, local storage schema.
2. **Core Logging**: Weight entry CRUD, reminder scheduling, dashboard basics.
3. **Analytics**: Charts, trend projections, goal management.
4. **Data Portability**: CSV export/import.
5. **Google Sheets Sync** (optional milestone once MVP stable).

