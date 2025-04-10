# Currency Converter App

A Flutter application that converts USD (United States Dollar) to INR (Indian Rupee) with a modern and responsive user interface. The app supports both Material Design (Android) and Cupertino (iOS) design patterns.

## Features

- Real-time currency conversion from USD to INR
- Clean and intuitive user interface
- Support for both Android (Material Design) and iOS (Cupertino) platforms
- Decimal number input support
- Responsive layout that works on various screen sizes


## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio / VS Code
- Android Emulator / iOS Simulator (for testing)

### Installation

1. Clone the repository:

2. Navigate to the project directory:
```bash
cd Flutter_Projects/currency_converter
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Building the App

### For Android
To build an APK file:
```bash
flutter build apk
```
The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

### For iOS
To switch to iOS design:
1. Open `lib/main.dart`
2. Change `MyApp` to `MyCupertinoApp` in the main function

## Usage

1. Launch the app
2. Enter the amount in USD in the input field
3. Click the "Convert" button
4. View the converted amount in INR

## Project Structure

- `lib/main.dart` - Main application entry point
- `lib/currency_converter_material_page.dart` - Material Design implementation
- `lib/currency_converter_cupertino_page.dart` - Cupertino (iOS) implementation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

