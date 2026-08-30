# Project status

## Complete in this repository

- Godot 4.7.2 Compatibility project with a portrait 540 × 960 design viewport.
- Full deterministic journey loop: survivor selection, 6 regions × 5 drawn events, checkpoints, and 3-stage finale.
- Data-driven definitions for all regions, events, choices, outcomes, items, adversaries, and conditions.
- Visible D20 math with automatic natural 1 and natural 20 behavior.
- Health, Hunger, Fatigue, Radiation, threshold penalties, weight, equipment, ammo, consumables, conditions, travel, rest, death, and victory.
- One active JSON run, atomic replacement, backup recovery, migrations, autosaves, prepared-roll recovery, death marker, profile, history, settings, and cached entitlements.
- Portrait UI for menu, candidates, journey, outcome, inventory, checkpoint, death/victory, tutorial, settings, accessibility, store catalog, and privacy summary.
- Seven portrait backgrounds, vector app icon, generated UI sounds, optional haptics, and reduced-motion behavior.
- Android debug and release export presets; Android 12+ and legacy backup-rule resources exclude active-run files.
- Offline-safe advertising and billing service boundaries and a type-checked Firebase purchase-verification function.
- Automated domain/content/save suite. Current result: 147 assertions, 0 failures.
- Signed debug APK generated at `builds/android/ashfall-road-debug.apk` and verified with Android's `apksigner`.
- Debug-signed API 36 AAB generated through the custom Gradle template at `builds/android/ashfall-road-debug.aab`; both selective backup XML resources are packaged.

## Installed on this PC

- Godot 4.7.2 Standard: `C:\Users\ASUS\Applications\Godot-4.7.2`.
- Matching export templates in the Godot user template directory.
- Android Studio Quail 3 Patch 1.
- Temurin OpenJDK 17.0.20.1.
- Android SDK Platforms 35 and 36, Build-Tools 35.0.1/36.0.0, command-line tools 23.0, Platform-Tools/ADB 37.0.1, NDK r28b, and CMake 3.10.2.

## External work that cannot be completed without accounts, credentials, plugins, devices, or testers

- Connect a USB-debugging Android phone and install the generated APK. No device was attached during implementation.
- Choose the permanent reverse-domain package name before the first Play upload; `com.yourstudio.ashfallroad` is deliberately a placeholder.
- Install and pin compatible AdMob/UMP and Google Play Billing Godot plugins, then connect their callbacks to the existing facades.
- Create AdMob, Firebase/Google Cloud, and Play Console apps; insert test IDs first and production IDs only for release.
- Create the four non-consumable Play products and deploy the verification function.
- Generate and securely back up the release upload key. Keystore secrets must never be committed.
- Human balance, accessibility, low-end-device, consent, billing, closed-test, policy, and store-listing work.
- Recruit at least 12 continuously opted-in closed testers for 14 days; recruit 15–20 to keep a buffer.

The project is a content-complete first implementation, not a production-certified release. Do not enable real ads or payments until the plugin isolation tests and policy checklist pass.
