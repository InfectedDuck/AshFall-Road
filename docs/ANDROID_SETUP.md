# Windows and Android setup

This document records both the current machine state and the repeatable setup procedure. Godot's official Android export guide recommends OpenJDK 17, Android SDK Platform 35, Build-Tools 35.0.1, Platform-Tools 35.0.0 or newer, command-line tools, NDK r28b (`28.1.13356709`), and CMake `3.10.2.4988404`. This project also installs Platform 36 because Google Play requires new apps submitted from 31 August 2026 to target API 36.

Official references:

- <https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_android.html>
- <https://support.google.com/googleplay/android-developer/answer/11926878?hl=en>

## Current PC paths

- Godot editor: `C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64.exe`
- JDK 17: `C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot`
- Android SDK: `C:\Users\ASUS\AppData\Local\Android\Sdk`
- ADB: `C:\Users\ASUS\AppData\Local\Android\Sdk\platform-tools\adb.exe`
- Project: `C:\Users\ASUS\Desktop\TEXT RPG`
- Debug APK: `builds\android\ashfall-road-debug.apk`

Godot 4.7 auto-detected the JDK and Android SDK in Editor Settings. If those locations move, open Editor → Editor Settings → Export → Android and update Java SDK Path and Android SDK Path.

## Required SDK packages

In Android Studio, open More Actions → SDK Manager.

Under SDK Platforms, keep:

- Android 15 / API 35.
- Android 16 / API 36.

Under SDK Tools, enable Show Package Details and install:

- Android SDK Platform-Tools 35.0.0 or newer.
- Android SDK Build-Tools 35.0.1 and 36.0.0.
- Android SDK Command-line Tools (latest).
- NDK (Side by side) `28.1.13356709`.
- CMake `3.10.2.4988404`.

Do not replace JDK 17 with the old Java 8 installation. Godot's Java SDK Path must point directly at the JDK 17 directory.

## First phone test

1. On the phone, enable Developer options by tapping Build number seven times.
2. Enable USB debugging.
3. Connect a data-capable USB cable and accept the RSA authorization prompt on the phone.
4. In PowerShell, run `& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices`.
5. Confirm one device is listed as `device`, not `unauthorized`.
6. Install with `& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r ".\builds\android\ashfall-road-debug.apk"`.
7. Launch Ashfall Road and complete at least one event in airplane mode.

If Android reports a signing mismatch, uninstall the older debug copy of the same package before reinstalling. Uninstalling deletes its local saves.

## Rebuild the debug APK

From PowerShell in the project directory, run Godot's console executable with the `Android Debug` export preset. The preset emits an arm64 debug APK, signs it with Godot's debug keystore, and keeps Android backup disabled.

The package currently uses `com.yourstudio.ashfallroad`. Replace this placeholder in both export presets, Firebase, AdMob, and Play Console before the first store upload. A Play package ID is permanent after upload.

## Google Play AAB

1. In Godot choose Project → Install Android Build Template. This creates `android/build` for the Gradle export required by AAB and Android plugins.
2. Copy `platform/android/full_backup_content.xml` and `platform/android/data_extraction_rules.xml` into `android/build/res/xml/`.
3. Add these application attributes to the custom Android manifest:
   - `android:fullBackupContent="@xml/full_backup_content"`
   - `android:dataExtractionRules="@xml/data_extraction_rules"`
4. Confirm the generated Gradle config targets API 36 and uses minimum API 23 or higher.
5. Integrate the pinned billing and AdMob/UMP plugins only in this custom Gradle build.
6. Generate a release upload keystore outside this repository. Use the same password for the key and keystore because Godot's Android exporter expects that arrangement.
7. Back up the upload keystore and password in two secure locations.
8. Fill the Google Play AAB preset's release keystore fields locally; never commit credentials.
9. Increment version code for every Play upload, disable debug export, and export an AAB.
10. Upload to Play internal testing before closed testing.

Only `active_run.json`, its backup/temp file, and the death marker are excluded from Android backup/transfer. Profile and verified entitlement files may survive migration as designed.
