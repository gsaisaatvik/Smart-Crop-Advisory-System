# Smart Crop Advisory

An AI-powered Flutter application for crop advisory, pest detection, and farming guidance using Sarvam AI's multilingual capabilities.

## Features

- 🌱 **Pest & Disease Detection**: Take photos of crops to identify diseases and pests
- 🌤️ **Weather Advisory**: Get weather-based farming recommendations
- 💬 **Multilingual Chatbot**: Chat with AI in multiple Indian languages (English, Hindi, Tamil, Telugu, Kannada, Malayalam, Marathi, Gujarati)
- 🎤 **Voice Input**: Record audio messages for hands-free interaction
- 🔊 **Text-to-Speech**: Listen to AI responses in your preferred language
- 📱 **Cross-Platform**: Runs on Android, iOS, and Web

## Setup Instructions

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd smart_crop_advisory
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Create a `.env` file in the project root
   - Add your Sarvam AI API key:
     ```
     SARVAM_API_KEY=your_actual_api_key_here
     ```
   - Get your API key from [Sarvam AI](https://sarvam.ai/)

4. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For iOS (macOS only)
   flutter run -d ios
   
   # For Web
   flutter run -d web-server --web-port 8080
   ```

## Platform-Specific Setup

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Permissions: Camera, Microphone, Storage, Internet

### iOS
- Minimum iOS: 11.0
- Permissions: Camera, Microphone, Photo Library

### Web
- Modern browsers with WebRTC support
- HTTPS required for camera and microphone access

## Project Structure

```
lib/
├── features/
│   ├── camera/          # Camera and image capture
│   ├── chat/            # Chatbot interface
│   ├── detection/       # Disease detection results
│   ├── history/         # Detection history
│   ├── home/            # Main navigation
│   └── weather/         # Weather advisory
├── services/
│   ├── api_client.dart      # HTTP client
│   ├── audio_tts_service.dart # Text-to-speech
│   ├── local_db.dart        # Local database
│   └── sarvam_api.dart      # Sarvam AI integration
└── main.dart            # App entry point
```

## API Integration

This app integrates with Sarvam AI for:
- **Chat Completions**: Multilingual conversations
- **Speech-to-Text**: Audio transcription
- **Text-to-Speech**: Voice responses

## Development

### Adding New Features
1. Create feature folder in `lib/features/`
2. Add service classes in `lib/services/`
3. Update navigation in `main.dart`

### Testing
```bash
flutter test
```

### Building for Production
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Troubleshooting

### Common Issues

1. **API Key Not Working**
   - Ensure `.env` file exists and contains valid API key
   - Check network connectivity
   - Verify API key permissions

2. **Camera Not Working**
   - Check device permissions
   - Ensure camera is not used by another app
   - For web: Use HTTPS

3. **Audio Recording Issues**
   - Grant microphone permissions
   - Check device audio settings
   - For web: Use HTTPS and modern browser

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review Flutter documentation

## Acknowledgments

- [Sarvam AI](https://sarvam.ai/) for AI capabilities
- [Flutter](https://flutter.dev/) for the framework
- Open source community for various packages