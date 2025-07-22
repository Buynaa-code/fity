# Google Sign-In Setup Guide

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable **Google Sign-In API**

## Step 2: Configure OAuth 2.0

### For Android:
1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth 2.0 Client IDs**
3. Select **Android**
4. Package name: `com.example.fity`
5. Get SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   # Copy the SHA1 from debug keystore
   ```

### For iOS:
1. Create **OAuth 2.0 Client ID** for iOS
2. Bundle ID: `com.example.fity`
3. Download `GoogleService-Info.plist`

### For Web:
1. Create **OAuth 2.0 Client ID** for Web application
2. Add authorized domains

## Step 3: Add Configuration Files

### Android:
1. Download `google-services.json` 
2. Place in `android/app/google-services.json`
3. Add to `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```
4. Add to `android/build.gradle.kts`:
   ```kotlin
   dependencies {
       classpath("com.google.gms:google-services:4.3.15")
   }
   ```

### iOS:
1. Download `GoogleService-Info.plist`
2. Add to `ios/Runner/GoogleService-Info.plist`
3. Update `ios/Runner/Info.plist` with REVERSED_CLIENT_ID

## Step 4: Update Code

Replace `YOUR_CLIENT_ID` in Info.plist with actual REVERSED_CLIENT_ID from GoogleService-Info.plist

## Step 5: Test

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..  # For iOS only
flutter run
```