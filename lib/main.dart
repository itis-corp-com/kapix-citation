import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/citation_chat_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KapixCitationApp(),
    ),
  );
}

class KapixCitationApp extends StatelessWidget {
  const KapixCitationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KāPix Citation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CitationChatScreen(),
    );
  }
}
