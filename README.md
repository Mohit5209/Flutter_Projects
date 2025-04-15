# Flutter Projects Collection

This repository contains a collection of Flutter applications showcasing different features and implementations.

## Quick Links
- [Currency Converter App](currency_converter/)
- [Weather App](weather_app/)
- [Shopping App](shop_app/)

## Projects

### 1. Currency Converter App
A modern currency conversion application that converts USD to INR with support for both Material Design (Android) and Cupertino (iOS) interfaces.

**Features:**
- Real-time USD to INR conversion
- Material Design and Cupertino UI support
- Decimal number input support
- Responsive layout

[View Currency Converter README](currency_converter/README.md)

### 2. Weather App
A comprehensive weather application that provides real-time weather information for cities.

**Features:**
- Real-time temperature display
- Current weather conditions with dynamic icons
- Hourly weather forecast
- Additional weather metrics (humidity, wind speed, pressure)
- Pull-to-refresh functionality
- Dark theme support

[View Weather App README](weather_app/README.md)

### 3. Shopping App
A modern and user-friendly shopping application with comprehensive features for product browsing and cart management.

**Features:**
- Product browsing with detailed information
- Cart management with real-time price updates
- Search and filter products
- Modern UI with custom theme
- State management using Provider
- Responsive design
- Intuitive navigation

[View Shopping App README](shop_app/README.md)

## Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK
- Android Studio / VS Code
- Android Emulator / iOS Simulator (for testing)

### Installation

1. Clone the repository.

2. Navigate to the desired project directory:
```bash
cd Flutter_Projects/currency_converter  # For Currency Converter
# or
cd Flutter_Projects/weather_app        # For Weather App
# or
cd Flutter_Projects/shop_app          # For Shopping App
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Building Apps

### For Android
To build an APK file:
```bash
flutter build apk
```
The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

### For iOS
For the Currency Converter app, to switch to iOS design:
1. Open `lib/main.dart`
2. Change `MyApp` to `MyCupertinoApp` in the main function

## Contributing

Contributions are welcome! Please feel free to submit Pull Requests for any of the projects.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- The open-source community for their contributions