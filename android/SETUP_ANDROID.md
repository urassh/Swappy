# Swappy Android Setup (Kotlin)

This project is a minimal Android app scaffold. Follow the steps below to install the Android toolchain and launch the sample app.

## 1) Install Android Studio + SDK
- Install the latest Android Studio.
- During first launch, install the SDK (Android 14 / API 34) and Platform Tools.

## 2) Open the project
- Open this folder as a project in Android Studio.
- When prompted, set Gradle JDK to 17 (Android Studio "Embedded JDK" is fine).
- Let Android Studio download Gradle and required SDK components.

## 3) Create an emulator (or connect a device)
- Android Studio -> Device Manager -> Create Device -> Pixel 6 (or similar).
- Use a system image like API 34 (Google APIs).

## 4) Run the app
- Select the emulator/device and press Run.

## Optional: CLI setup (advanced)
If you prefer CLI, install SDK command-line tools and then:

- Install packages:
  sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools" "emulator" "system-images;android-34;google_apis;arm64-v8a"
- Create an emulator:
  avdmanager create avd -n Pixel_API_34 -k "system-images;android-34;google_apis;arm64-v8a"
- Build/install:
  ./gradlew installDebug

Note: If the Gradle wrapper files are missing or out of date, run `gradle wrapper` after installing Gradle, or let Android Studio regenerate them during sync.
