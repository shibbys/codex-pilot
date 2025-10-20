# Daily Weight Tracker App - Product Requirements

## Vision
Create an Android-first companion app that helps users log their daily weight, stay accountable through gentle reminders, and understand their progress toward a weight goal using intuitive analytics and customizable theming.

## Target Platform
- Android (initial release as APK sideload)
- Flutter as primary framework (Dart language)
- Potential future expansion to other platforms leveraging Flutter's cross-platform capabilities

## Personas
1. **Self-driven weight loss tracker**
   - Wants lightweight app without subscriptions
   - Logs weight daily at home
   - Values quick access to historical data and progress insights
2. **Health coach & client setup** (future)
   - Coach monitors multiple users, needs export/import to spreadsheets
   - Uses Google Drive integration for shared data visibility

## Core User Stories
### Logging & Notifications
- As a user, I want to receive a reminder at my preferred time on selected weekdays so that I remember to log my weight.
- As a user, I want to snooze reminders by +5, +10, or +30 minutes or skip them entirely.
- As a user, I want reminders to automatically stop for the day once I have logged my weight.
- As a user, I want to manually enter or edit past weights so that my history is complete even when I miss a day.

### Data Visualization & Insights
- As a user, I want to view my weight history in a table so I can quickly browse daily values.
- As a user, I want to view my weight evolution in charts that compare actual weight to my goal.
- As a user, I want to see summary metrics (current weight, goal delta, trend direction, projected goal date) so I can understand progress at a glance.

### Data Management
- As a user, I want my data stored locally by default to ensure availability offline.
- As a user, I want to export my data to CSV so I can back it up or analyze it elsewhere.
- As a user, I want to re-import from CSV so I can restore historical data.
- As a user, I want to optionally sync with a Google Sheets spreadsheet so that my data is backed up and accessible from other devices.

## Non-functional Requirements
- Intuitive UX with minimal friction for daily logging.
- Theme customization with light/dark modes and a set of accessible accent color palettes.
- No cost dependencies (prefer open-source/free services).
- Architecture should support future enhancements like coach dashboards or additional analytics.

## Nice-to-have / Future Enhancements
- Automated trend analysis beyond linear projection (e.g., moving averages, anomalies).
- Social/accountability sharing features.
- Multi-user support within a single app install.
- Integration with smart scales via Bluetooth or third-party APIs.

