# askcam

A new Flutter project.

## Cloudinary config (Gallery uploads)

Run with Cloudinary unsigned upload config:

```bash
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=dncfxydui --dart-define=CLOUDINARY_UPLOAD_PRESET=itjfaoc8
```

If you build a release:

```bash
flutter build apk --dart-define=CLOUDINARY_CLOUD_NAME=dncfxydui --dart-define=CLOUDINARY_UPLOAD_PRESET=itjfaoc8
```

## Windows release build cleanup (Kotlin cache)

```powershell
flutter clean
Remove-Item -Recurse -Force android\.gradle
Remove-Item -Recurse -Force android\app\build
flutter pub get
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
