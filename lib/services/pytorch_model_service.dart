import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PyTorchModelService {
  static const String _modelPath = 'assets/models/multicrop_effb0_best.pt';
  static const String _modelFileName = 'multicrop_effb0_best.pt';

  // Model configuration based on your ResNet 50 specifications
  static const int modelInputSize = 224;
  static const List<double> imagenetMean = [0.485, 0.456, 0.406];
  static const List<double> imagenetStd = [0.229, 0.224, 0.225];

  // Flat labels from your trained model (33 classes)
  static const List<String> classLabels = [
    "cotton__Fusarium",
    "cotton__Healthy cotton leaf",
    "cotton__Healthy cotton plant",
    "cotton__Mealybug",
    "cotton__american bollworm",
    "cotton__diseased cotton leaf",
    "cotton__diseased cotton plant",
    "cotton__thrips",
    "lentil__Ascochyta blight",
    "lentil__Lentil Rust",
    "lentil__Normal",
    "lentil__Powdery Mildew",
    "maize__Blight",
    "maize__Common_Rust",
    "maize__Gray_Leaf_Spot",
    "maize__Healthy",
    "rice__Bacterial Leaf Blight",
    "rice__Brown Spot",
    "rice__Healthy Rice Leaf",
    "rice__Leaf Blast",
    "rice__Leaf scald",
    "rice__Sheath Blight",
    "sugarcane_cleaned_dataset__BacterialBlights",
    "sugarcane_cleaned_dataset__Healthy",
    "sugarcane_cleaned_dataset__Mosaic",
    "sugarcane_cleaned_dataset__RedRot",
    "sugarcane_cleaned_dataset__Rust",
    "sugarcane_cleaned_dataset__Yellow",
    "wheat_cleaned_dataset__Brown rust",
    "wheat_cleaned_dataset__Healthy",
    "wheat_cleaned_dataset__Loose Smut",
    "wheat_cleaned_dataset__Septoria",
    "wheat_cleaned_dataset__Yellow rust",
  ];

  /// Initialize the model by copying it to device storage
  Future<void> initializeModel() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${appDir.path}/$_modelFileName');

      if (!await modelFile.exists()) {
        // Copy model from assets to device storage
        final modelData = await rootBundle.load(_modelPath);
        await modelFile.writeAsBytes(modelData.buffer.asUint8List());
        print('Model copied to device storage: ${modelFile.path}');
      } else {
        print('Model already exists in device storage');
      }
    } catch (e) {
      throw Exception('Failed to initialize model: $e');
    }
  }

  /// Preprocess image for ResNet 50 model input
  Future<void> _preprocessImage(File imageFile) async {
    try {
      // Read image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to 224x224 (ResNet 50 input size)
      final resizedImage = img.copyResize(
        image,
        width: modelInputSize,
        height: modelInputSize,
      );

      // For now, just validate the image can be processed
      // In a real implementation, you would apply ImageNet normalization
      // and convert to the format expected by your PyTorch model
      print('Image resized to ${resizedImage.width}x${resizedImage.height}');
    } catch (e) {
      throw Exception('Image preprocessing failed: $e');
    }
  }

  /// Run single-stage inference: Direct classification to one of 33 classes
  Future<DetectionResult> predict(File imageFile) async {
    try {
      print('Starting prediction for image: ${imageFile.path}');

      // Preprocess image
      await _preprocessImage(imageFile);
      print('Image preprocessed successfully');

      // Simulate model inference delay (replace with actual PyTorch inference)
      await Future.delayed(const Duration(seconds: 3));

      // Single-stage classification (33-way softmax)
      final prediction = _simulateClassification();
      print(
        'Classification completed: ${prediction.className} (${prediction.confidence.toStringAsFixed(2)}%)',
      );

      // Parse crop and disease from the flat label
      final parsedResult = _parseFlatLabel(prediction.className);

      return DetectionResult(
        cropResult: CropResult(
          crop: parsedResult['crop']!,
          cropConfidence: prediction.confidence,
          cropProbs: [prediction.confidence], // Simplified for single-stage
        ),
        diseaseResult: DiseaseResult(
          disease: parsedResult['disease']!,
          confidence: prediction.confidence,
          top3: [
            DiseasePrediction(
              disease: parsedResult['disease']!,
              confidence: prediction.confidence,
            ),
          ],
        ),
        processingTime: 3.0,
      );
    } catch (e) {
      throw Exception('Prediction failed: $e');
    }
  }

  /// Simulate single-stage classification (33-way softmax)
  ClassPrediction _simulateClassification() {
    final random = DateTime.now().millisecondsSinceEpoch % classLabels.length;
    final classIndex = random;
    final confidence = (75.0 + (random % 25)).clamp(
      0.0,
      100.0,
    ); // 75-100% confidence

    return ClassPrediction(
      className: classLabels[classIndex],
      confidence: confidence,
      classIndex: classIndex,
    );
  }

  /// Parse flat label to extract crop and disease
  Map<String, String> _parseFlatLabel(String flatLabel) {
    // Handle different label formats
    String crop;
    String disease;

    if (flatLabel.contains('__')) {
      // Format: "crop__disease"
      final parts = flatLabel.split('__');
      crop = parts[0];
      disease = parts[1];
    } else if (flatLabel.contains('_cleaned_dataset__')) {
      // Format: "crop_cleaned_dataset__disease"
      final parts = flatLabel.split('_cleaned_dataset__');
      crop = parts[0];
      disease = parts[1];
    } else {
      // Fallback
      crop = 'unknown';
      disease = flatLabel;
    }

    // Clean up crop names
    crop = crop.replaceAll('_cleaned_dataset', '');

    return {'crop': crop, 'disease': disease};
  }

  /// Get treatment recommendations based on crop and disease
  String getTreatmentRecommendation(String crop, String disease) {
    final recommendations = {
      'lentil': {
        'Lentil Rust':
            'Apply fungicide containing tebuconazole. Remove infected plant debris. Improve air circulation.',
        'Ascochyta blight':
            'Use fungicide with azoxystrobin. Practice crop rotation. Remove infected debris.',
        'Powdery Mildew':
            'Apply sulfur-based fungicide. Ensure proper spacing. Avoid overhead watering.',
        'Normal':
            'Your lentil crop appears healthy! Continue regular monitoring and maintenance.',
      },
      'cotton': {
        'Fusarium':
            'Apply fungicide containing thiophanate-methyl. Improve drainage. Use resistant varieties.',
        'Healthy cotton leaf':
            'Your cotton leaf appears healthy! Continue regular monitoring.',
        'Healthy cotton plant':
            'Your cotton plant appears healthy! Continue regular monitoring.',
        'Mealybug':
            'Apply insecticide containing imidacloprid. Remove infected parts. Use beneficial insects.',
        'american bollworm':
            'Apply Bt-based insecticide. Use pheromone traps. Practice crop rotation.',
        'diseased cotton leaf':
            'Remove infected leaves. Apply appropriate fungicide based on specific disease.',
        'diseased cotton plant':
            'Remove infected plants. Apply appropriate treatment based on specific disease.',
        'thrips':
            'Apply insecticide containing spinosad. Use reflective mulch. Remove weeds.',
      },
      'maize': {
        'Blight':
            'Apply fungicide with chlorothalonil. Remove infected debris. Improve drainage.',
        'Common_Rust':
            'Apply fungicide with propiconazole. Remove infected leaves. Use resistant varieties.',
        'Gray_Leaf_Spot':
            'Use fungicide containing azoxystrobin. Improve air circulation. Practice crop rotation.',
        'Healthy':
            'Your maize crop appears healthy! Continue regular monitoring and maintenance.',
      },
      'rice': {
        'Bacterial Leaf Blight':
            'Apply copper-based bactericide. Improve drainage. Use resistant varieties.',
        'Brown Spot':
            'Use fungicide containing propiconazole. Ensure proper spacing. Practice crop rotation.',
        'Healthy Rice Leaf':
            'Your rice leaf appears healthy! Continue regular monitoring.',
        'Leaf Blast':
            'Apply fungicide with tricyclazole. Remove infected debris. Use resistant varieties.',
        'Leaf scald':
            'Apply fungicide containing azoxystrobin. Improve air circulation. Practice crop rotation.',
        'Sheath Blight':
            'Apply fungicide with validamycin. Remove infected debris. Improve drainage.',
      },
      'sugarcane': {
        'BacterialBlights':
            'Apply copper-based bactericide. Remove infected stalks. Improve drainage.',
        'Healthy':
            'Your sugarcane crop appears healthy! Continue regular monitoring and maintenance.',
        'Mosaic':
            'Remove infected plants. Use virus-free seed. Control aphid vectors.',
        'RedRot':
            'Apply fungicide containing thiophanate-methyl. Remove infected stalks. Practice crop rotation.',
        'Rust':
            'Apply fungicide with tebuconazole. Remove infected debris. Use resistant varieties.',
        'Yellow':
            'Check soil nutrients. Apply balanced fertilizer. Test soil pH.',
      },
      'wheat': {
        'Brown rust':
            'Apply fungicide containing tebuconazole. Remove infected leaves. Use resistant varieties.',
        'Healthy':
            'Your wheat crop appears healthy! Continue regular monitoring and maintenance.',
        'Loose Smut':
            'Use fungicide-treated seed. Practice crop rotation. Remove infected plants.',
        'Septoria':
            'Apply fungicide with azoxystrobin. Remove infected debris. Improve air circulation.',
        'Yellow rust':
            'Apply fungicide containing propiconazole. Remove infected debris. Use resistant varieties.',
      },
    };

    return recommendations[crop]?[disease] ??
        'Consult with a local agricultural expert for specific treatment recommendations for $crop $disease.';
  }
}

/// Data classes for two-stage prediction results
class DetectionResult {
  final CropResult cropResult;
  final DiseaseResult diseaseResult;
  final double processingTime;

  DetectionResult({
    required this.cropResult,
    required this.diseaseResult,
    required this.processingTime,
  });
}

class CropResult {
  final String crop;
  final double cropConfidence;
  final List<double> cropProbs;

  CropResult({
    required this.crop,
    required this.cropConfidence,
    required this.cropProbs,
  });
}

class DiseaseResult {
  final String disease;
  final double confidence;
  final List<DiseasePrediction> top3;

  DiseaseResult({
    required this.disease,
    required this.confidence,
    required this.top3,
  });
}

class DiseasePrediction {
  final String disease;
  final double confidence;

  DiseasePrediction({required this.disease, required this.confidence});
}

class ClassPrediction {
  final String className;
  final double confidence;
  final int classIndex;

  ClassPrediction({
    required this.className,
    required this.confidence,
    required this.classIndex,
  });
}
