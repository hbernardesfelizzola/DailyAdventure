# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build
xcodebuild -scheme DailyAdventure -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all unit tests
xcodebuild test -scheme DailyAdventure -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:DailyAdventureTests

# Run all UI tests
xcodebuild test -scheme DailyAdventure -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:DailyAdventureUITests

# Run a single test suite or test
xcodebuild test -scheme DailyAdventure -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:DailyAdventureTests/AdventureDayBoundaryTests
xcodebuild test -scheme DailyAdventure -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:DailyAdventureTests/AdventureDayBoundaryTests/sameCalendarDayTrueForDifferentClockTimesOnSameGMTDay
```

## Architecture

The app follows MVVM with a single shared ViewModel. There are no external package dependencies — only Apple frameworks.

### Data flow

`QuestViewModel` (the sole `@Observable @MainActor` ViewModel) owns two pieces of state:
- `todayAdventure: DailyAdventure` — the current day's adventure, kept in sync with `StorageService`
- `history: [DailyAdventure]` — past days (newest first), loaded once and persisted on rollover

All persistence goes through `StorageService.shared` which reads/writes to `UserDefaults` via JSON encoding, using keys `"todayAdventure"` and `"adventureHistory"`.

### Day rollover

`AdventureDayBoundary` encapsulates the calendar-day comparison logic. On every `.active` scene phase, `QuestViewModel.checkAndResetIfNeeded()` checks if `todayAdventure.date` belongs to a different calendar day. If so, it archives the previous day (only if `shouldArchiveToAdventureLog` is true — i.e., it had any quests, completions, or feedback) and creates a fresh `DailyAdventure`. `historyReplacingCalendarDay` ensures no duplicate entries for the same calendar day in the log.

### Notifications & deep linking

`NotificationService` schedules two repeating `UNCalendarNotificationTrigger` notifications (morning → Today tab, evening → Progress tab). Settings are persisted in `UserDefaults` with keys like `morningReminderEnabled`, `morningReminderHour`, etc. On app launch and every `.active` scene phase, `syncScheduledNotificationsWithSettings()` reconciles the live schedule with those stored values.

`NotificationTapRouter` is a `UNUserNotificationCenterDelegate` that translates tapped notification identifiers into `pendingTabIndex` (an `@Observable` `Int?`), which `MainTabView` consumes to switch tabs. Tab indices: 0=Log, 1=Today, 2=Progress, 3=Settings (see `MainTab` enum in `NotificationTapRouter.swift`).

### Quest model

A `DailyAdventure` holds a free-text `mainQuest` string plus an array of `Quest` structs for side quests. Completed quests are tracked in a separate `completedQuests` array (by copying the `Quest` value). The main quest is wrapped into a `Quest` with `isMainQuest: true` when marked complete. Side quests each carry a `QuestCategory` (`.work`, `.health`, `.relationship`).

`DayCompletionLevel` (`.empty` / `.partial` / `.complete`) is a computed property on `DailyAdventure` derived from `completedQuests`. It drives all completion visuals — icons in the Adventure Log, the 7-day grid in Progress, and the streak calculation. A day counts as `.partial` with ≥1 quest completed; `.complete` requires 100%.

### Analytics

`QuestViewModel` exposes four read-only computed properties for the Progress tab:
- `currentStreak` / `excellenceInStreak` — consecutive days with ≥1 completion, and how many of those were 100%, computed in a single pass via `streakInfo`
- `totalDaysAdventured` — historical count of days with any completion
- `last7Days` — array of `(date, DayCompletionLevel)` for the grid, gaps filled as `.empty`
- `categoryStats: [CategoryStat]` — per-category added/completed counts across all history (data layer kept for future use, not currently shown in UI)

### Main quest UX

`ContentView` uses a local `@State var mainQuestDraft` as the TextField binding. The ViewModel is only updated on `onSubmit` (pressing done), so intermediate keystrokes do not affect `showMainQuestCard`. The card is shown whenever `viewModel.todayAdventure.mainQuest` is non-empty, making it persist across tab navigation. The xmark on the card is always visible — it uncompletes the quest if needed and clears both the ViewModel and the draft.

### Theme & accessibility

`Theme` is a caseless enum of static constants. `Theme.isHighContrast` reads `UserDefaults` at call time (not cached), so all computed color properties (`titleDenim`, `background`, `cardBackground`, category colors) re-evaluate on every access. All colors support dark mode via `UIColor` adaptive initializers.

### Testing

Unit tests use **Swift Testing** (`@Suite`, `@Test`, `#expect`) — not XCTest. UI tests use XCUITest and require the `--ui-testing` launch argument, which skips onboarding and the 2.5 s loading delay.
