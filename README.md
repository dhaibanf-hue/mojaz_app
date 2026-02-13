# Moujaz App (موجز)

This is a Flutter application for summarizing books, based on the provided web design.

## Features
- **Onboarding Flow**: Introduction slides.
- **Authentication**: Login and Register screens (UI only).
- **Home Screen**:
  - Horizontal Book Categories.
  - Recommended Books.
  - Category-based lists.
  - Search Bar (Visual).
- **Book Details**: Comprehensive book info with "About" and "Target Audience" sections.
- **Audio Player**: Smart audio player with synchronized transcript and playback controls.

## Project Structure
- `lib/main.dart`: Entry point.
- `lib/constants.dart`: App colors and dummy data.
- `lib/models/`: Data models (Book, Author).
- `lib/screens/`: All application screens.

## How to Run
1. Ensure you have Flutter installed.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to start the app on your emulator or device.

## Notes
- State management is local (using `setState`).
- Backend integration is mocked (simulated delays).
- Localization is set to RTL for Arabic support.
