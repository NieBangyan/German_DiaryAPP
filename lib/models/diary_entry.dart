import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime createdAt;

  DiaryEntry({
    required this.date,
    required this.content,
    required this.createdAt,
  });
}