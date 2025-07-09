# Calories Tracker

A Flutter app for tracking calories and maintaining a healthy lifestyle.

## Features

- **Profile Image Upload**: Users can upload profile pictures from camera or gallery
- Dashboard with calorie tracking
- Water intake tracking
- Progress visualization

## Getting Started

### Prerequisites
- Flutter SDK (^3.7.0)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Image Upload Feature
The app includes a profile image upload feature that allows users to:
- Take a photo using the device camera
- Select an image from the device gallery
- View the selected image in the profile section

**Permissions Required:**
- Camera access (for taking photos)
- Photo library access (for selecting images)

**Usage:**
1. Navigate to the Profile section
2. Tap the edit icon on the profile picture
3. Choose between Camera or Gallery
4. Select or capture your desired image
5. The profile picture will be updated automatically

## Flutter gen to generate assets
Run: `dart run build_runner watch --delete-conflicting-outputs`