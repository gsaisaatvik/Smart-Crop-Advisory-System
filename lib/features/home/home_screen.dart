import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Crop Advisory')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HomeTile(
            icon: Icons.camera_alt,
            title: 'Pest & Disease Detection',
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed('/camera'); // 👈 goes to CameraScreen
            },
          ),
          _HomeTile(
            icon: Icons.history,
            title: 'History',
            onTap: () {
              Navigator.of(context).pushNamed('/history');
            },
          ),
          _HomeTile(
            icon: Icons.cloud,
            title: 'Weather Advisory',
            onTap: () {
              Navigator.of(context).pushNamed('/weather');
            },
          ),
          _HomeTile(
            icon: Icons.chat,
            title: 'Chatbot',
            onTap: () {
              Navigator.of(context).pushNamed('/chat');
            },
          ),
        ],
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HomeTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
