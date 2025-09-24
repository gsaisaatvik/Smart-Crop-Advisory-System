import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/pytorch_model_service.dart';
import '../detection/detection_result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final PyTorchModelService _modelService = PyTorchModelService();
  bool _isProcessing = false;
  bool _modelInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await _modelService.initializeModel();
      setState(() {
        _modelInitialized = true;
      });
      print('Model initialized successfully');
    } catch (e) {
      print('Model initialization failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Model initialization failed: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Automatically run prediction when image is selected
      if (_modelInitialized) {
        await _runPrediction();
      }
    }
  }

  Future<void> _runPrediction() async {
    if (_image == null || !_modelInitialized) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _modelService.predict(_image!);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetectionResultScreen(image: _image!, result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Prediction failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pest & Disease Detection"),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Model Status Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _modelInitialized
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _modelInitialized ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _modelInitialized ? Icons.check_circle : Icons.sync,
                    color: _modelInitialized ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _modelInitialized
                        ? 'Model Ready - ResNet 50 Multi-Crop Detection'
                        : 'Initializing Model...',
                    style: TextStyle(
                      color: _modelInitialized
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Image Display Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No image selected",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Take a photo or choose from gallery",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.contain),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Processing Indicator
            if (_isProcessing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Running ResNet 50 Model...',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _modelInitialized && !_isProcessing
                        ? () => _pickImage(ImageSource.camera)
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Take Photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _modelInitialized && !_isProcessing
                        ? () => _pickImage(ImageSource.gallery)
                        : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Manual Prediction Button (if image is selected but not processed)
            if (_image != null && !_isProcessing && _modelInitialized)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _runPrediction,
                  icon: const Icon(Icons.analytics),
                  label: const Text("Run Detection"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
