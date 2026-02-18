import 'package:flutter/material.dart';
import 'database_helper.dart';

class Topic {
  const Topic({required this.id, required this.name});

  final int id;
  final String name;

  factory Topic.fromMap(Map<String, Object?> map) {
    return Topic(
      id: map['id'] as int,
      name: map['topic'] as String,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Topic> _topics = <Topic>[];
  bool _isLoading = true;
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await DatabaseHelper.instance.database;
    await _loadTopics();
  }

  Future<void> _loadTopics() async {
    final List<Map<String, Object?>> rows = await DatabaseHelper.instance.getTopics();

    if (!mounted) {
      return;
    }

    setState(() {
      _topics = rows.map(Topic.fromMap).toList();
      _isLoading = false;
    });
  }

  Future<void> _addTopic(String topicName) async {
    final String trimmed = topicName.trim();

    if (trimmed.isEmpty) {
      return;
    }

    await DatabaseHelper.instance.insertTopic(trimmed);
    await _loadTopics();
  }

  Future<void> _showAddTopicDialog() async {
    _topicController.clear();

    final String? topicToAdd = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Topic'),
          content: TextField(
            controller: _topicController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Enter topic name',
            ),
            onSubmitted: (String value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(_topicController.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (mounted && topicToAdd != null && topicToAdd.isNotEmpty) {
      await _addTopic(topicToAdd);
    }
  }

  Future<void> _deleteTopic(int topicId) async {
    await DatabaseHelper.instance.deleteTopic(topicId);
    await _loadTopics();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        actions: <Widget>[
          IconButton(
            onPressed: _showAddTopicDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add topic',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFEFF2FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _topics.isEmpty
              ? const Center(
                  child: Text('No topics yet. Tap + to add one.'),
                )
              : ListView.separated(
                  itemCount: _topics.length,
                  padding: const EdgeInsets.all(12),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final Topic topic = _topics[index];
                    return Card(
                      child: ListTile(
                        title: Text(topic.name),
                        trailing: IconButton(
                          onPressed: () => _deleteTopic(topic.id),
                          icon: const Icon(Icons.close),
                          tooltip: 'Delete topic',
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/flashcards',
                            arguments: topic,
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
