# HealthSync

A comprehensive health management Flutter application with a refreshing green theme that helps users organize and manage their medical documents including prescriptions, test reports, and healthcare information.

## Features

- 📸 **Document Capture**: Take photos or import images of prescriptions and test reports
- 🔍 **Text Recognition**: Extract and search text from medical documents using ML Kit
- 💾 **Local Storage**: Secure offline storage using Hive database
- 🏥 **Organization**: Categorize documents by type (prescriptions, test reports)
- 🔍 **Interactive Viewer**: Zoom and pan through document images
- 🌐 **Quick Search**: Search extracted text directly on Google
- 🎨 **Modern UI**: Clean green-themed interface for a fresh, healthy feel

## Screenshots

![App Preview](assets/branding.png)

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.5)
- Dart SDK
- Android/iOS development setup

### Installation

1. Clone the repository:
```bash
git clone https://github.com/hasanalbanna012/healthsync.git
cd healthsync
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter packages pub run build_runner build
```

4. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── prescription.dart     # Prescription model
│   └── test_report.dart      # Test report model
├── pages/                    # App screens
│   └── home_page.dart        # Main home screen
├── services/                 # Business logic
│   └── text_detector.dart    # ML Kit text recognition
└── widgets/                  # Reusable components
    ├── bottom_nav_bar.dart   # Bottom navigation
    └── image_viewer.dart     # Image viewing widget
```

## Technologies Used

- **Flutter**: Cross-platform mobile development
- **Hive**: Lightweight NoSQL database for local storage
- **Google ML Kit**: Text recognition from images
- **Image Picker**: Camera and gallery integration
- **URL Launcher**: External link handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions, please open an issue on GitHub.
