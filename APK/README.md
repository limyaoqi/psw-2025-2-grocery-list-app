# APK Distribution

This directory contains the release APK for the Grocery List App.

## Building the APK

To build the release APK:

```bash
flutter build apk --release
```

Then copy the generated APK:

```bash
# Windows
copy "build\app\outputs\flutter-apk\app-release.apk" "APK\app-release.apk"

# macOS/Linux
cp build/app/outputs/flutter-apk/app-release.apk APK/app-release.apk
```

## Installation

### From APK file

1. Enable "Install from Unknown Sources" on your Android device
2. Download `app-release.apk` from this directory
3. Tap the APK file to install

### From Google Play Store

_Not currently published_

## APK Information

- **Target SDK**: Android 5.0+ (API 21+)
- **Architecture**: Universal (arm64-v8a, armeabi-v7a, x86_64)
- **Size**: ~20MB (estimated)
- **Permissions**: Internet access for Firebase features

## Security Note

This APK is built from source code in this repository. Always verify the source before installing APK files.
