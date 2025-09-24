import 'package:flutter/material.dart';

class DetectionResultScreen extends StatelessWidget {
  const DetectionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Disease: TBD'),
            SizedBox(height: 8),
            Text('Confidence: --'),
            SizedBox(height: 16),
            Text('Recommendations:'),
          ],
        ),
      ),
    );
  }
}

