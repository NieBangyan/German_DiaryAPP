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

  void _openDiaryEditor(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final existingDiary = StorageService.getDiary(dateStr);

    if (selectedDate.isAfter(todayDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot write a diary for a future date.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedDate.isBefore(todayDate)) {
      _openDiaryViewer(date, existingDiary?.content ?? 'Empty');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEditor(
          date: date,
          existingContent: existingDiary?.content ?? '',
        ),
      ),
    ).then((_) {
      _refreshCalendar();
    });
  }

  void _openDiaryViewer(DateTime date, String content) {
    final isEmpty = content == 'Empty';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📖 ${DateFormat('yyyy-MM-dd').format(date)}'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: isEmpty
                ? const Center(
                    child: Text(
                      '📭 Empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Text(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  Widget _buildDayCell(DateTime date, bool isSelected, bool isToday) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final isChecked = _checkedDates.containsKey(dateStr);

    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isChecked
            ? Border.all(
                color: Colors.green,
                width: 2.5,
              )
            : null,
        color: isSelected
            ? Colors.blue
            : isToday && !isSelected
                ? Colors.blueAccent.withOpacity(0.3)
                : Colors.transparent,
      ),
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : isChecked
                  ? Colors.green.shade700
                  : Colors.black87,
          fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📓 German Diary'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              _openDiaryEditor(selected);
            },
            calendarStyle: const CalendarStyle(
              defaultDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
              weekendDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
              outsideDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          
            calendarBuilders: CalendarBuilders(
             
              defaultBuilder: (context, date, _) {
                final isToday = isSameDay(date, DateTime.now());
                
                if (!isToday && !isSameDay(date, _selectedDay)) {
                  return _buildDayCell(date, false, false);
                }
                return null;
              },
             
              todayBuilder: (context, date, _) {
                
                if (isSameDay(date, _selectedDay)) {
                  return null;
                }
                return _buildDayCell(date, false, true);
              },
              selectedBuilder: (context, date, _) {
                return _buildDayCell(date, true, isSameDay(date, DateTime.now()));
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📝 ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _checkedDates.containsKey(
                    DateFormat('yyyy-MM-dd').format(_selectedDay),
                  )
                      ? '✅ Checked in'
                      : '⭕ Not checked in',
                  style: TextStyle(
                    color: _checkedDates.containsKey(
                      DateFormat('yyyy-MM-dd').format(_selectedDay),
                    )
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
          _openDiaryEditor(DateTime.now());
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}