import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/diary_service.dart';
import '../models/diary_entry.dart';
import 'entry_detail_page.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _selectedDay = DateTime.now();
  List<DiaryEntry> _entries = [];
  final DiaryService _diaryService = DiaryService();
  bool _isLoading = true;

  Future<void> _loadEntries() async {
    final entries = await _diaryService.getEntries();

    if (!mounted) {
      return;
    }

    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  List<DiaryEntry> _entriesForSelectedDay() {
    return _entries.where((entry) {
      return isSameDay(_selectedDay, entry.date);
    }).toList();
  }
  

  @override
  Widget build(BuildContext context) {
    final selectedEntries = _entriesForSelectedDay();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: selectedEntries.length,
              itemBuilder: (context, index) {
                final entry = selectedEntries[index];

                return ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.feeling),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntryDetailPage(
                          entry: entry,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _diaryService.deleteEntry(entry);
                      await _loadEntries();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}