# Prayer Time App

A Flutter mobile application that displays prayer times and Islamic calendar information with advanced features and beautiful UI.

## Features

- Display daily prayer times for Sri Lanka
- Show Sunnath fasting times
- Islamic calendar with Hijri dates
- Prayer time lookup for any date
- Travel mode for prayer time adjustments
- Local notifications for prayer times
- Dark/Light theme support
- Offline functionality

## Screenshots

[Add screenshots here]

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Android Studio / Xcode
- Android SDK / iOS development tools
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/prayer-time.git
cd prayer-time
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Building the App

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ipa --release
```

## Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── calendar_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── prayer_time_service.dart
│   └── notification_service.dart
├── models/
│   └── prayer_time.dart
└── widgets/
    └── prayer_time_card.dart
```

## Dependencies

- flutter_local_notifications: ^16.3.0
- shared_preferences: ^2.2.2
- provider: ^6.1.1
- intl: ^0.19.0
- http: ^1.2.0

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter)

Project Link: [https://github.com/yourusername/prayer-time](https://github.com/yourusername/prayer-time)
