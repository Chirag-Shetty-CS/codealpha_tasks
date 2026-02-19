import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'flashcardplay.dart';

class FlashcardListPage extends StatefulWidget {
  const FlashcardListPage({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  final int topicId;
  final String topicName;

  @override
  State<FlashcardListPage> createState() => _FlashcardListPageState();
}

class _FlashcardListPageState extends State<FlashcardListPage> {
  List<Map<String, Object?>> _qna = <Map<String, Object?>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQnA();
  }

  Future<void> _loadQnA() async {
    final List<Map<String, Object?>> rows =
        await DatabaseHelper.instance.getQnAForTopic(widget.topicId);

    if (!mounted) {
      return;
    }

    setState(() {
      _qna = rows;
      _isLoading = false;
    });
  }

  Future<void> _showAddFlashcardDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext dialogContext) => const _AddFlashcardDialog(),
    );

    if (result != null) {
      final String question = result['question'] ?? '';
      final String answer = result['answer'] ?? '';

      if (question.isNotEmpty && answer.isNotEmpty) {
        await DatabaseHelper.instance.insertQnA(
          topicId: widget.topicId,
          question: question,
          answer: answer,
        );
        await _loadQnA();
      }
    }
  }

  Future<void> _deleteQuestion(int qnaId) async {
    await DatabaseHelper.instance.deleteTopicData(qnaId);
    await _loadQnA();
  }

  Future<void> _showEditFlashcardDialog(int qnaId) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext dialogContext) => const _EditFlashcardDialog(),
    );

    if (result != null) {
      await DatabaseHelper.instance.updateQnA(
        qnaId: qnaId,
        newQuestion: result['question'],
        newAnswer: result['answer'],
      );
      await _loadQnA();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName),
        backgroundColor: Colors.orangeAccent,
        actions: <Widget>[
          IconButton(
            onPressed: _showAddFlashcardDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add flashcard',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _qna.isEmpty
              ? const Center(
                  child: Text('No questions yet. Tap + to add one.'),
                )
              : ListView.separated(
                  itemCount: _qna.length,
                  padding: const EdgeInsets.all(12),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, Object?> row = _qna[index];
                    final int qnaId = row['id'] as int;
                    final String question = row['question'] as String? ?? '';

                    return Card(
                      child: ListTile(
                        title: Text(question),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: () => _showEditFlashcardDialog(qnaId),
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit flashcard',
                            ),
                            IconButton(
                              onPressed: () => _deleteQuestion(qnaId),
                              icon: const Icon(Icons.close),
                              tooltip: 'Delete question',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => FlashcardPlayPage(
                topicId: widget.topicId,
                topicName: widget.topicName,
              ),
            ),
          );
        },
        tooltip: 'Play flashcards',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class _AddFlashcardDialog extends StatefulWidget {
  const _AddFlashcardDialog();

  @override
  State<_AddFlashcardDialog> createState() => _AddFlashcardDialogState();
}

class _EditFlashcardDialog extends StatefulWidget {
  const _EditFlashcardDialog();

  @override
  State<_EditFlashcardDialog> createState() => _EditFlashcardDialogState();
}

class _EditFlashcardDialogState extends State<_EditFlashcardDialog> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop({
      'question': _questionController.text.trim(),
      'answer': _answerController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Flashcard'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _questionController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'New Question',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answerController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'New Answer',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddFlashcardDialogState extends State<_AddFlashcardDialog> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    final String question = _questionController.text.trim();
    final String answer = _answerController.text.trim();
    if (question.isNotEmpty && answer.isNotEmpty) {
      Navigator.of(context).pop({
        'question': question,
        'answer': answer,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Flashcard'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _questionController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Enter question',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answerController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Enter answer',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
