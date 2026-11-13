# Funny Age Calculator: Project Design

## 1. Concept
A one-screen age calculator that treats your birthday as a punchline. You enter a
date; it returns your exact age plus a stack of absurd "life stats", each with a
one-line joke. Goal: something you screenshot and send to friends.

**Audience:** anyone with a phone. Casual, shareable, zero sign-up.
**Principles:** instant result, no accounts, no network, no permissions, works offline.

## 2. Platform and tech choices
| Decision | Choice | Why |
|---|---|---|
| Framework | Flutter (Dart) | One codebase builds Android and iOS |
| State | `StatefulWidget` | One screen; a state library would be overkill |
| Dependencies | None beyond Flutter | Smaller app, fewer build failures |
| Backend / storage | None | Nothing to persist; privacy by default |
| Build | GitHub Actions | Produces APK (Linux) and iOS app (macOS runner) without local setup |

## 3. Features
**Must have**
- Birthday picker (1900 to today)
- Exact age: years, months, days
- Funny roast line that depends on age bracket
- Stat cards: days on Earth, live seconds counter, next-birthday countdown,
  heartbeats, breaths, time asleep, full moons, km around the Sun, weekday born, star sign
- "Copy my stats to brag" (clipboard)

**Nice touches (included)**
- Bouncing cake mascot, staggered card entrance animation
- Birthday-today message
- Feb 29 handling

**Out of scope for v1:** accounts, ads, notifications, sharing images, localisation, dark theme tuning.

## 4. User flow
```
Open app -> Tap "pick your birthday" -> Date picker -> Tap "Calculate my age"
        -> Age banner + roast -> Scroll stat cards -> Copy stats / change date
```
Calculate with no date: snackbar nudge. Changing the date clears old results.

## 5. Screen layout (single screen)
```
+--------------------------+
|           (cake)         |  bouncing emoji
|   How Old Are You        |
|      (Really)?           |
|  Enter birthday. Roast.  |
|                          |
| +----------------------+ |
| | [ pick birthday   ]  | |  outlined button -> date picker
| | [ Calculate my age ] | |  filled button
| +----------------------+ |
|                          |
| +----------------------+ |  purple banner
| |      YOU ARE         | |
| | 25 yrs, 3 mo, 12 d   | |
| |   roast line         | |
| +----------------------+ |
| [emoji] LABEL            |  stat cards x10
|         Big value        |
|         joke             |
| ...                      |
| [ Copy my stats ]        |
| footnote disclaimer      |
+--------------------------+
```

## 6. Visual design
- **Palette:** seed purple `#7C4DFF`, accent amber `#FFC400`; background gradient from
  the primary container tint to warm cream `#FFF3C4`.
- **Type:** Material 3 defaults. Heavy weights (800/900) for numbers and headlines.
- **Shape:** 16 to 24 px rounded corners, flat cards with a faint purple outline.
- **Motion:** 1.4 s looping bounce on the mascot; cards slide up 40 px and fade in
  with an overshoot curve, staggered 90 ms apart.
- **Tone of copy:** playful teasing, never about appearance, health conditions or identity.

## 7. Architecture
```
lib/
  main.dart               app entry + theme
  age_logic.dart          pure Dart maths (no Flutter) -> unit tested
  jokes.dart              every joke string, easy to edit
  screens/home_screen.dart  UI + state + 1-second ticker
  widgets/stat_card.dart  reusable animated card
test/
  age_logic_test.dart     unit tests
```
**Data model:** `AgeResult` (immutable) holds years/months/days, total days, next
birthday, weekday, star sign, plus computed getters for the fun numbers.

## 8. Calculation rules
- Whole months = largest n where `birth + n months <= today`, clamping the day
  (31 Jan + 1 month = 28 Feb). Days = the remainder. This avoids negative-day bugs.
- All date maths is done in UTC dates only, so daylight-saving shifts cannot
  change a day count.
- Feb 29 birthdays are celebrated on 28 Feb in non-leap years.
- Fun numbers (approximations, labelled "approx." in the UI):
  heartbeats = days x 103,680 (72 bpm); breaths = days x 23,040 (16/min);
  asleep = days / 3; full moons = days / 29.53; Sun travel = days x 2.57 million km.

## 9. Edge cases
| Case | Behaviour |
|---|---|
| Birthday today | "It's your birthday!" card, 0 days |
| Born today | 0 years 0 months 0 days, still works |
| Future date | Blocked by picker (`lastDate = today`); logic also throws |
| Feb 29 | Handled as above |
| Date earlier than 1900 | Not selectable |
| Midnight rollover while open | Live counter keeps ticking; day-based stats refresh on next Calculate |

## 10. Testing
- Unit tests (`flutter test`) cover: exact birthday, day borrowing across short months,
  year boundary, leap days, next-birthday rollover, Feb 29, future date, weekday and zodiac, number formatting.
- Manual: run on one small and one large phone; check the picker, scrolling, and rotation.
- CI runs `flutter analyze` and `flutter test` before building the APK.

## 11. Release checklist
1. Replace the default launcher icon (e.g. `flutter_launcher_icons`).
2. Android: create an upload keystore and configure `android/key.properties`
   (the CI APK is signed with debug keys, fine for sideloading, not the Play Store).
3. iOS: set a bundle ID and team in Xcode, then archive for TestFlight/App Store
   (requires an Apple Developer account and a Mac).
4. Add a privacy policy line: "This app collects no data."
