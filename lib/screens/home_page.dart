import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../widgets/diary_editor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late Map<String, bool> _checkedDates;

  @override
  void initState() {
    super.initState();
    _loadCheckedDates();
  }

  void _loadCheckedDates() {
    final dates = StorageService.getCheckedDates();
    _checkedDates = {for (var d in dates) d: true};
  }

  void _refreshCalendar() {
    _loadCheckedDates();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 German Diary'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // calendar
          TableCalendar(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day), 
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              // Open diary editor after tapping the date
              _openDiaryEditor(selected);
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
           // Mark checked dates
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final dateStr = DateFormat('yyyy-MM-dd').format(date);
                if (_checkedDates.containsKey(dateStr)) {
                  return Positioned(
                    bottom: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          // Today's status prompt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📝 ${DateFormat('yyyy/MM/dd').format(_selectedDay)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _checkedDates.containsKey(DateFormat('yyyy-MM-dd').format(_selectedDay))
                      ? '✅ Checked'
                      : '⭕ Unchecked',
                  style: TextStyle(
                    color: _checkedDates.containsKey(DateFormat('yyyy-MM-dd').format(_selectedDay))
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openDiaryEditor(_selectedDay);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _openDiaryEditor(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final existingDiary = StorageService.getDiary(dateStr);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEditor(
          date: date,
          existingContent: existingDiary?.content ?? '',
        ),
      ),
    ).then((_) {
      // Refresh calendar on return
      _refreshCalendar();
    });
  }
}