# Admissions playtest — 0.2.0

Prepared on 1 October 2026 from the current Godot 4.7.2 project. These are trial builds for reviewers, not store releases. The game works offline and needs no account.

## Windows desktop

Download the [Windows ZIP](../downloads/Ashfall-Road-0.2.0-playtest-Windows.zip), extract it, and run `ashfall-road.exe`. Keep `ashfall-road.pck` beside the executable. This build is for 64-bit Windows and does not need Godot installed. The executable is unsigned, so Windows may identify its publisher as unknown.

## Android

Download the [Android ZIP](../downloads/Ashfall-Road-0.2.0-playtest-Android.zip), extract it, and open `ashfall-road-debug.apk` on an Android 7.0 or newer arm64 or x86_64 device. Android may ask you to allow installation from the app used to open the APK. This package is debug-signed for trial installation and is not a Google Play release.

## Artwork status

The screenshots in the README show the playable build. Some enemy and survivor portraits and some item icons are temporary or still awaiting final art. The Feral Dogs portrait shown in the combat screenshot is included.

## Verification

- Godot's automated suite: **3,645 assertions, 0 failures**, using a writable local data folder.
- Windows export: launched headlessly and exited with code 0.
- Android export: APK Signature Schemes v2 and v3 verified; minimum SDK 24 and target SDK 36.
- Both ZIP files were extracted and their game binaries matched the originals byte for byte by SHA-256.

| Archive | Size | SHA-256 |
|---|---:|---|
| `Ashfall-Road-0.2.0-playtest-Windows.zip` | 60,480,450 bytes | `0FAFDD17446A1E02A9AA4D0D6C83C67151E2ADB117607FFB3FC6D42BE9DC5A5A` |
| `Ashfall-Road-0.2.0-playtest-Android.zip` | 79,376,194 bytes | `F437D305FEE3C3813EEE2720D04928352A69E88BA3EB735C073A55BDDC7A3434` |
