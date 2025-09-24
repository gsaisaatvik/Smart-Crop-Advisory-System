# Setup Guide

## Environment Configuration

1. **Create a `.env` file** in the project root with the following content:
   ```
   SARVAM_API_KEY=your_actual_api_key_here
   ```

2. **Get your Sarvam AI API key** from [Sarvam AI](https://sarvam.ai/)

3. **Replace `your_actual_api_key_here`** with your actual API key

## Important Notes

- The `.env` file is gitignored for security
- Never commit your actual API key to version control
- For production, use environment variables or secure key management

## Demo Mode

If no API key is provided, the app will run in demo mode with limited functionality:
- Chat responses will be placeholder text
- Audio features will be disabled
- All other features will work normally

## Troubleshooting

### API Key Issues
- Ensure the `.env` file is in the project root
- Check that the API key is valid and active
- Verify network connectivity

### Missing Dependencies
Run `flutter pub get` to install all required packages.

### Platform-Specific Issues
- **Android**: Ensure all permissions are granted
- **iOS**: Check Info.plist permissions
- **Web**: Use HTTPS for camera/microphone access
