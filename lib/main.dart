import 'package:flutter/material.dart';
import 'homepage.dart';
import 'flashcardlist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/flashcards') {
          final Topic topic = settings.arguments as Topic;
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => FlashcardListPage(
              topicId: topic.id,
              topicName: topic.name,
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
