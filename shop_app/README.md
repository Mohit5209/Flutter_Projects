# Flutter Shopping App

A modern and user-friendly shopping application built with Flutter. This app provides a seamless shopping experience with features like product browsing, cart management, and a clean user interface.

## Features

- 🛍️ Browse through a curated list of products
- 🔍 View detailed product information
- 🛒 Add/remove items to/from cart
- 💰 Cart management with real-time price updates
- 🎨 Modern UI with custom theme
- 📱 Responsive design that works on various screen sizes
- 🔄 State management using Provider
- 🔎 Search products by name or description
- ⚡ Filter products by category or price range
- 👆 Intuitive navigation:
  - Tap product name to view details
  - Tap product image (CircleAvatar) in cart to view details
  - Easy access to cart from any screen


## Tech Stack

- Flutter
- Provider (for state management)
- Material Design

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- A physical device or emulator

### Installation

1. Clone this repository:
```bash
cd shop_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point and theme configuration
├── home_page.dart         # Main shopping page
├── product_list.dart      # Product listing implementation
├── product_detail_page.dart # Individual product view
├── cart_page.dart         # Shopping cart page
├── cart_provider.dart     # Cart state management
├── product_cart.dart      # Cart item widget
└── global_variables.dart  # Global app variables
```

## Theme Customization

The app uses a custom theme with:
- Primary color: Yellow (#FECE01)
- Custom font: Lato
- Consistent text styles across the app
- Custom app bar styling


## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- All contributors who help improve this app
