import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'entry_detail_page.dart';
import '../services/diary_service.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<DiaryEntry> _entries = [];
  final DiaryService _diaryService = DiaryService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _userName = '';

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

  Map<String, double> _calculateFeelings() {
    Map<String, int> counts = {};

    for (DiaryEntry entry in _entries) {
      if (counts.containsKey(entry.feeling)) {
        counts[entry.feeling] = counts[entry.feeling]! + 1;
      } else {
        counts[entry.feeling] = 1;
      }
    }

    Map<String, double> percentages = {};

    for (String feeling in counts.keys) {
      percentages[feeling] =
          counts[feeling]! * 100 / _entries.length;
    }

    return percentages;
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
    final user = Supabase.instance.client.auth.currentUser;

    _userName =
    user?.userMetadata?['full_name'] ??
    user?.userMetadata?['name'] ??
    user?.email ??
    'User';
  }

  @override
  Widget build(BuildContext context) {
    final lastTwoEntries = _entries.take(2).toList();
    final feelings = _calculateFeelings();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              await Navigator.pushNamed(context, '/agenda');
              await _loadEntries();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
          
              if (!context.mounted) {
                return;
              }
          
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Hello, $_userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text('Total entries: ${_entries.length}'),

              ...feelings.entries.map((entry) {
                return Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(1)}%',
                );
              }),

              const SizedBox(height: 20),

              const Text(
                'Last 2 entries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              ...lastTwoEntries.map((entry) {
                return ListTile(
                  title: Text(entry.title),
                  subtitle: Text('${entry.date} - ${entry.feeling}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _diaryService.deleteEntry(entry);
                      await _loadEntries();
                    },
                  ),
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
                );
              }),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final DiaryEntry? newEntry =
              await Navigator.pushNamed(context, '/create') as DiaryEntry?;

          if (!context.mounted) {
            return;
          }

          if (newEntry != null) {
            await _diaryService.addEntry(newEntry);
            await _loadEntries();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}