import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'entry_detail_page.dart';
import '../services/diary_service.dart';
import '../services/auth_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
        actions: [
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
        ? const Center(
          child: CircularProgressIndicator(),
        )
      : ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];

          return ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.feeling),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _diaryService.deleteEntry(entry);
                await _loadEntries();
              },
            ),
            onTap: (){
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
        },
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