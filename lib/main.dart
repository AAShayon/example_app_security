import 'package:flutter/material.dart';
import 'security/security_manager.dart';
import 'example_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SecurityManager.initialize();
  } catch (e) {
    runApp(const SecurityBlockedApp());
    return;
  }

  runApp(const MyApp());
}

class SecurityBlockedApp extends StatelessWidget {
  const SecurityBlockedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('App blocked due to security risk')),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure API Module Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const ExamplePage(),
    );
  }
}
