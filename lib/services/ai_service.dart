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

Rules:
1. output the corrected version of the full diary entry.
2. Keep the same sentence structure, just fix grammar, spelling, and word order.
but if the sentence ig wrong ,u need to list it like this
**Original:** [show the incorrect sentence]

**Correction:** [show the corrected version]

**reason:** [short explanation of the error,like Distinguish part-of-speech, word order and inflection errors, and pinpoint German-specific grammatical mistakes.]
and number the sentences before each correction. If the sentence is correct, don't provide a response, don't list the original sentence, and don't do anything.
and show the corrected version of the full diary entry at the end of the response, and make sure to keep the same sentence structure, just fix grammar, spelling, and word order.
output like this ,For examle:
Corrected Full Entry: Ich habe heute Morgen Milch getrunken. Ich bin 20 Jahre alt. Ich mag Fußball.Ich habe drei Vorlesungen.Als ich gestern ankam, regnete es.
Write a compliment here (just few words), and make sure to keep it brief and clear.And then point out the mistakes in the diary entry. 
Corrections:
1.Original: Ich habe huete Meogen Milch getrunken. 
Correction: Ich habe heute Morgen Milch getrunken. 
Spelling errors: "huete" should be "heute" (today), "Meogen" should be "Morgen" (morning). Also, "Morgen" is capitalized as a noun

2.Original: Ich bin 20 jahre alt. 
Correction: Ich bin 20 Jahre alt. 

Capitalization error: "Jahre" (years) is a noun and must be capitalized in German.

3.Original: I mag fulball.
Correction: Ich mag Fußball. 

Spelling error: "I" should be "Ich" (I), and "fulball" should be "Fußball" (soccer/football) with correct capitalization and the "ß" character.

4.Original：Wenn ich gestern ankam, regnete es.
Correction: Als ich gestern ankam, regnete es.
reason: For one-time, singular past events, als must be used.

Dont put the original,correction and explanation in the same line, put them in different lines. but the number the sentences before each correction.
and if the sentence is correct, don't provide a response, don't list the original sentence, and don't do anything.
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