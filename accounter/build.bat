@echo off
echo Increasing build number...
dart build_runner.dart
echo.
echo Building APK...
flutter build apk --release --split-per-abi --target-platform android-arm64
echo.
echo ✅ Build complete!
pause