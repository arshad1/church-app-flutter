# Church App

A production-ready Flutter boilerplater application using GetX.

## Structure

The project is organized into the following structure:

- **lib/app/data**: Contains models, providers (API clients), and services.
- **lib/app/modules**: Contains the screens/pages. Each module follows the Controller-View-Binding pattern.
- **lib/app/routes**: Defines application routes and navigation.
- **lib/app/core**: Core utilities, constants, and theme definitions.
- **lib/main.dart**: Entry point of the application.

## State Management

This project uses [GetX](https://pub.dev/packages/get) for state management, navigation, and dependency injection.

## Responsiveness

[flutter_screenutil](https://pub.dev/packages/flutter_screenutil) is configured in `main.dart` to handle responsiveness across different screen sizes.

## Local Storage

[get_storage](https://pub.dev/packages/get_storage) is initialized for fast, key-value storage.

## Getting Started

1.  Run `flutter pub get` to install dependencies.
2.  Run `flutter run` to start the application.
