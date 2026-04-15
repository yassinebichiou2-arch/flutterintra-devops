@echo off
echo ============================================
echo   FlutterIntra - Firebase Setup Script
echo ============================================
echo.

echo [1/4] Installing FlutterFire CLI...
dart pub global activate flutterfire_cli

echo.
echo [2/4] Configuring Firebase for this project...
echo    - Make sure you are logged in: firebase login
echo    - Then run: flutterfire configure
echo.
echo    This will:
echo      * Let you select your Firebase project
echo      * Generate lib/firebase_options.dart automatically
echo      * Download google-services.json for Android
echo      * Download GoogleService-Info.plist for iOS
echo.

echo [3/4] After flutterfire configure, run:
echo    flutter pub get
echo.

echo [4/4] Then launch the app:
echo    flutter run
echo.
echo ============================================
echo   Firebase Console Setup Checklist:
echo ============================================
echo   1. Go to https://console.firebase.google.com
echo   2. Create project named "FlutterIntra"
echo   3. Authentication ^> Sign-in method ^> Enable Email/Password
echo   4. Firestore Database ^> Create database ^> Start in test mode
echo   5. Storage ^> Get started ^> Start in test mode
echo   6. Project Settings ^> Add Android app (package: com.example.FlutterIntra)
echo   7. Download google-services.json to android/app/
echo ============================================
pause

