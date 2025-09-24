import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'features/chat/chat_screen.dart';
import 'features/chat/chat_provider.dart';
import 'features/weather/weather_screen.dart';
import 'features/history/history_screen.dart';
import 'features/camera/camera_screen.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  String? apiKey;
  try {
    await dotenv.load(fileName: ".env");
    apiKey = dotenv.env['SARVAM_API_KEY'];
  } catch (e) {
    print('Could not load .env file: $e');
  }

  // Fallback to environment variable or default
  apiKey ??= const String.fromEnvironment('SARVAM_API_KEY');

  if (apiKey.isEmpty) {
    print('Warning: SARVAM_API_KEY is missing! Using demo mode.');
    print('To fix this:');
    print('1. Create a .env file in the project root');
    print('2. Add: SARVAM_API_KEY=your_actual_api_key');
    print('3. Or set environment variable: SARVAM_API_KEY=your_actual_api_key');
    apiKey = 'demo_key'; // Fallback for demo purposes
  }

  runApp(MyApp(apiKey: apiKey));
}

class MyApp extends StatelessWidget {
  final String apiKey;
  const MyApp({required this.apiKey, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(apiKey),
      child: MaterialApp(
        title: 'Smart Crop Advisory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        routes: {
          '/camera': (context) => const CameraScreen(),
          '/history': (context) => const HistoryScreen(),
          '/weather': (context) => const WeatherScreen(),
          '/chat': (context) => const ChatScreen(),
        },
        supportedLocales: const [Locale('en'), Locale('hi'), Locale('ta')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to Smart Crop Advisory'),
            Text('Counter: $_counter'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
