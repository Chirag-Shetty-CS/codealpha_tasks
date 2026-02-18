import 'package:flutter/material.dart';
import 'database_helper.dart';

class FlashcardPlayPage extends StatefulWidget {
  const FlashcardPlayPage({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  final int topicId;
  final String topicName;

  @override
  State<FlashcardPlayPage> createState() => _FlashcardPlayPageState();
}

class _FlashcardPlayPageState extends State<FlashcardPlayPage> {
  List<Map<String, Object?>> _qna = <Map<String, Object?>>[];
  bool _isLoading = true;
  int _currentIndex = 0;

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
      _qna = rows.reversed.toList();
      _currentIndex = 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasQuestions = _qna.isNotEmpty;
    final bool canGoBack = hasQuestions && _currentIndex > 0;
    final bool canGoForward = hasQuestions && _currentIndex < _qna.length - 1;
    final String currentQuestion = hasQuestions
        ? (_qna[_currentIndex]['question'] as String? ?? '')
        : 'No questions available for this topic.';
    final String positionText = hasQuestions
        ? '${_currentIndex + 1}/${_qna.length}'
        : '0/0';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: constraints.maxHeight * 0.60,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                currentQuestion,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: hasQuestions ? 28 : 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: canGoBack
                                ? () {
                                    setState(() {
                                      _currentIndex -= 1;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Previous question',
                          ),
                          const SizedBox(width: 12),
                          Text(
                            positionText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: canGoForward
                                ? () {
                                    setState(() {
                                      _currentIndex += 1;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_forward),
                            tooltip: 'Next question',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
