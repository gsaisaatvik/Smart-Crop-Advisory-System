# Smart Crop Advisory

An AI-powered Flutter application for crop advisory, pest detection, and farming guidance using a custom-trained ResNet 50 CNN model and Sarvam AI's multilingual capabilities.

## Features

- 🌱 **AI-Powered Disease Detection**: Take photos of crops to identify diseases and pests using a custom ResNet 50 model
- 🧠 **Multi-Crop Classification**: Supports 6 crop types (cotton, maize, rice, sugarcane, wheat, lentil) with 33 disease classes
- 📊 **Confidence Scoring**: Real-time confidence scores for disease predictions
- 💊 **Treatment Recommendations**: AI-generated treatment advice for detected diseases
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

3. **Configure API Key (Optional)**
   - Create a `.env` file in the project root
   - Add your Sarvam AI API key:
     ```
     SARVAM_API_KEY=your_actual_api_key_here
     ```
   - Get your API key from [Sarvam AI](https://sarvam.ai/)
   - **Note**: The disease detection works without API key using the local CNN model

4. **Model Setup**
   - Place your trained model file `multicrop_effb0_best.pt` in `assets/models/` directory
   - The model supports 33 classes across 6 crop types
   - Model input: 224x224 RGB images with ImageNet normalization

5. **Run the app**
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
│   ├── camera/          # Camera and image capture with CNN model integration
│   ├── chat/            # Chatbot interface
│   ├── detection/       # Disease detection results display
│   ├── history/         # Detection history
│   ├── home/            # Main navigation
│   └── weather/         # Weather advisory
├── services/
│   ├── api_client.dart           # HTTP client
│   ├── audio_tts_service.dart    # Text-to-speech
│   ├── local_db.dart             # Local database
│   ├── pytorch_model_service.dart # CNN model integration (ResNet 50)
│   └── sarvam_api.dart           # Sarvam AI integration
└── main.dart            # App entry point

assets/
└── models/
    └── multicrop_effb0_best.pt   # Trained CNN model file
```

## AI Model Integration

### CNN Model (ResNet 50)
- **Architecture**: ResNet 50 backbone with custom classification heads
- **Input**: 224x224 RGB images with ImageNet normalization
- **Output**: 33-class classification across 6 crop types
- **Classes**: 
  - **Cotton**: Fusarium, Healthy cotton leaf/plant, Mealybug, American bollworm, Diseased cotton leaf/plant, Thrips
  - **Lentil**: Ascochyta blight, Lentil Rust, Normal, Powdery Mildew
  - **Maize**: Blight, Common Rust, Gray Leaf Spot, Healthy
  - **Rice**: Bacterial Leaf Blight, Brown Spot, Healthy Rice Leaf, Leaf Blast, Leaf scald, Sheath Blight
  - **Sugarcane**: Bacterial Blights, Healthy, Mosaic, Red Rot, Rust, Yellow
  - **Wheat**: Brown rust, Healthy, Loose Smut, Septoria, Yellow rust

### Sarvam AI Integration
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

1. **Model Not Loading**
   - Ensure `multicrop_effb0_best.pt` is in `assets/models/` directory
   - Check model file size (~100-110 MB for ResNet 50)
   - Verify model file is not corrupted

2. **API Key Not Working**
   - Ensure `.env` file exists and contains valid API key
   - Check network connectivity
   - Verify API key permissions
   - **Note**: Disease detection works without API key

3. **Camera Not Working**
   - Check device permissions
   - Ensure camera is not used by another app
   - For web: Use HTTPS

4. **Audio Recording Issues**
   - Grant microphone permissions
   - Check device audio settings
   - For web: Use HTTPS and modern browser

5. **Low Prediction Accuracy**
   - Ensure images are clear and well-lit
   - Crop images to focus on leaves/plants
   - Check if image contains the supported crop types

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

- **Custom ResNet 50 Model**: Trained specifically for multi-crop disease detection
- [Sarvam AI](https://sarvam.ai/) for multilingual AI capabilities
- [Flutter](https://flutter.dev/) for the cross-platform framework
- [PyTorch](https://pytorch.org/) for the deep learning framework
- Open source community for various packages

## Model Performance

- **Architecture**: ResNet 50 with custom classification heads
- **Training**: Multi-crop dataset with 33 disease classes
- **Input Size**: 224x224 RGB images
- **Normalization**: ImageNet standard (mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
- **Output**: Single-stage classification to one of 33 classes
- **Model Size**: ~100-110 MB (ResNet 50 + classification heads)