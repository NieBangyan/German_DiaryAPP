import 'package:dio/dio.dart';

class AIService {
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  
  // 你的 API Key
  static const String _apiKey = 'sk-e03e06ae435842d5afeb7462cf960d54';

  final Dio _dio = Dio();

  Future<AIResult> correctDiary(String diaryContent) async {
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

If there are multiple errors, list them as bullet points.
Keep the response short and focused.
''',
            },
            {
              'role': 'user',
              'content': diaryContent,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
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