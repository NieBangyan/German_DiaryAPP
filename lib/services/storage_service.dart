import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry.dart';

class StorageService {
  static const String _diaryBox = 'diary_box';
  static const String _wrongWordsBox = 'wrong_words_box';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DiaryEntryAdapter());  // Register adapter for custom data type
    await Hive.openBox<DiaryEntry>(_diaryBox);
    await Hive.openBox(_wrongWordsBox);
  }

  // Get diary box instance
  static Box<DiaryEntry> get diaryBox => Hive.box<DiaryEntry>(_diaryBox);

  // Get wrong words box instance
  static Box get wrongWordsBox => Hive.box(_wrongWordsBox);

  // Save diary. Overwrite if a record exists for the same date
  static Future<void> saveDiary(String date, String content) async {
    final entry = DiaryEntry(
      date: date,
      content: content,
      createdAt: DateTime.now(),
    );
    await diaryBox.put(date, entry);  // Use date as the storage key
  }

  // Fetch diary by specified date
  static DiaryEntry? getDiary(String date) {
    return diaryBox.get(date);
  }

  // Check if diary exists for the given date
  static bool isChecked(String date) {
    return diaryBox.containsKey(date);
  }

  // Get all dates with diary records for calendar marking
  static List<String> getCheckedDates() {
    return diaryBox.keys.cast<String>().toList();
  }

  // Save wrong word record
  static Future<void> saveWrongWord(String word, String context) async {
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    await wrongWordsBox.put(key, {
      'word': word,
      'context': context,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Get all saved wrong words
  static List<Map<String, dynamic>> getWrongWords() {
    return wrongWordsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // Delete wrong word after review
  static Future<void> deleteWrongWord(String key) async {
    await wrongWordsBox.delete(key);
  }
}