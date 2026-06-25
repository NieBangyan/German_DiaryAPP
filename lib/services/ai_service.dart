import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  late final String _apiKey;

  AIService() {
    _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      print('⚠️ Warning: DEEPSEEK_API_KEY not found in .env file');
    }
  }

  final Dio _dio = Dio();

  Future<AIResult> correctDiary(String diaryContent) async {
    if (_apiKey.isEmpty) {
      return AIResult(
        success: false,
        error: 'API Key not configured. Please check .env file.',
      );
    }

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': '''
You are a German teacher. Correct the user's German diary entry.

Respond in English. Keep it brief and clear with this format:

**Original:** [show the incorrect sentence]

**Correction:** [show the corrected version]

**Why:** [short explanation of the error]

if the sentence is correct,don't need to provide response,dont list the original sentence,dont need to do any thing.
Rules:
1. output the corrected version of the full diary entry.
2. Keep the same sentence structure, just fix grammar, spelling, and word order.

''',
            },
            {
              'role': 'user',
              'content': diaryContent,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return AIResult(
        success: true,
        content: content,
      );
    } on DioException catch (e) {
      return AIResult(
        success: false,
        error: 'Network error: ${e.message}',
      );
    } catch (e) {
      return AIResult(
        success: false,
        error: 'Unexpected error: $e',
      );
    }
  }
}

class AIResult {
  final bool success;
  final String? content;
  final String? error;

  AIResult({
    required this.success,
    this.content,
    this.error,
  });
}