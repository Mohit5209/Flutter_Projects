# Bakasur Chat Application

A modern chat application built with Flutter that provides an intuitive interface for conversing with an AI chatbot.

## Features

- 💬 Real-time chat interface
- 🌓 Dark/Light theme toggle
- 🔄 Clear conversation history
- 🤖 AI-powered responses
- 📱 Responsive design

## Prerequisites

Before running this application, make sure you have the following installed:

- Flutter SDK
- Dart SDK
- A compatible IDE (VS Code, Android Studio, etc.)
- A running backend server at `http://127.0.0.1:5000`

## Getting Started

1. Clone the repository:
```bash
cd bakasur
```

2. Install dependencies:
```bash
flutter pub get
```

3. Make sure your backend server is running at `http://127.0.0.1:5000`

4. Run the application:
```bash
flutter run
```

## Project Structure

- `lib/main.dart` - Application entry point and theme configuration
- `lib/home_page.dart` - Main chat interface implementation
- `assets/images/` - Contains application images including the chatbot avatar

## API Integration

The application communicates with a backend server at `http://127.0.0.1:5000/chat`. The API expects:

- Method: POST
- Headers: `Content-Type: application/json`
- Body: `{"message": "user message"}`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
