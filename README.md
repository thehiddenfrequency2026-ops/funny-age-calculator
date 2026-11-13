# Funny Age Calculator 🎂

A one-screen Flutter app (Android + iOS) that tells you your exact age and roasts you
with silly life stats. See [DESIGN.md](DESIGN.md) for the full project design.

## Get the APK and iOS app (no installs needed)

The easiest route is GitHub Actions, which builds both for you in the cloud.

1. Create a free account at github.com and a **new empty repository**.
2. Upload this whole folder (including the hidden `.github` folder) and commit to the `main` branch.
3. Open the **Actions** tab, then **Build Android APK and iOS app**, then **Run workflow**
   (it also runs automatically on every push).
4. After about 10 minutes, open the finished run and download the **Artifacts**:
   - `android-apk` contains `FunnyAgeCalculator.apk`
   - `ios-unsigned-ipa` contains `FunnyAgeCalculator-unsigned.ipa`

### Installing the Android APK
Copy the APK to your phone, open it, and allow "install from unknown sources" when asked.
It is signed with a debug key: fine for personal use, but the Play Store needs your own
release keystore (see DESIGN.md section 11).

### Installing the iOS app
Apple does not allow installing unsigned apps. Options:
- **Free:** sign and install the `.ipa` with Sideloadly or AltStore using your Apple ID
  (the app expires after 7 days and must be re-installed).
- **Paid ($99/year Apple Developer account):** open the project on a Mac in Xcode,
  set your team, and distribute through TestFlight or the App Store.

iOS apps can only be built on macOS, so there is no way around a Mac (or the cloud Mac used above).

## Build locally instead

Requires [Flutter](https://docs.flutter.dev/get-started/install) (stable). For iOS you also need a Mac with Xcode.

```bash
cd funny_age_calculator
cp -r lib /tmp/lib_bak && cp -r test /tmp/test_bak     # safety copy of our code
flutter create --platforms=android,ios --project-name funny_age_calculator --org com.funnyage .
rm -rf lib test && cp -r /tmp/lib_bak lib && cp -r /tmp/test_bak test
flutter pub get
flutter test
flutter run                         # run on a connected device or emulator
flutter build apk --release         # Android APK
flutter build ios --release         # iOS (Mac only; use --no-codesign for an unsigned build)
```

Note: `flutter create .` keeps existing files in most cases, but if it replaces `lib/main.dart`
or `test/`, copy this project's `lib/` and `test/` folders back over the generated ones
(the CI workflow does exactly this automatically).

## Project layout
```
lib/main.dart               app entry and theme
lib/age_logic.dart          age maths (pure Dart, unit tested)
lib/jokes.dart              all the jokes; edit or add your own here
lib/screens/home_screen.dart  the screen
lib/widgets/stat_card.dart  animated stat card
test/age_logic_test.dart    unit tests
.github/workflows/build.yml cloud build for APK and iOS
```

## Customising
- **Jokes:** edit `lib/jokes.dart`.
- **Colours:** change `seedColor` / `secondary` in `lib/main.dart`.
- **App name:** change `android:label` in `android/app/src/main/AndroidManifest.xml` and
  `CFBundleDisplayName` in `ios/Runner/Info.plist` after the platform folders are generated.
