import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class DiaryEditor extends StatefulWidget {
  final DateTime date;
  final String existingContent;

  const DiaryEditor({
    super.key,
    required this.date,
    required this.existingContent,
  });

  @override
  State<DiaryEditor> createState() => _DiaryEditorState();
}

class _DiaryEditorState extends State<DiaryEditor> {
  late TextEditingController _controller;
  bool _isLoading = false;
  String _aiResult = '';  // new state variable to hold AI result

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getAICorrection() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before asking AI to correct.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResult = '';  // clear previous AI result
    });

    try {
      final aiService = AIService();
      final result = await aiService.correctDiary(content);

      if (!mounted) return;

      if (result.success && result.content != null) {
        setState(() {
          _aiResult = result.content!;
        });
      } else {
        setState(() {
          _aiResult = '❌ Error: ${result.error ?? "Unknown error"}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiResult = '❌ Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _saveAndClose() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving')),
      );
      return;
    }
    final dateStr = DateFormat('yyyy/MM/dd').format(widget.date);
    StorageService.saveDiary(dateStr, _controller.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📝 ${DateFormat('yyyy/MM/dd').format(widget.date)}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _getAICorrection,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            tooltip: 'AI Correction',
          ),
          IconButton(
            onPressed: _saveAndClose,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
      
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✍️ Write your German diary entry for today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Heute habe ich...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveAndClose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('💾 Save Diary'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _getAICorrection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: const Text('AI Correct'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('🤖 AI is thinking...'),
                      ],
                    ),
                  )
                : _aiResult.isEmpty
                    ? const Center(
                        child: Text(
                          '🤖 Click "AI Correct" to get corrections',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          child: MarkdownBody(
                            data: _aiResult,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(fontSize: 14, height: 1.6),
                              listBullet: const TextStyle(fontSize: 14),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}