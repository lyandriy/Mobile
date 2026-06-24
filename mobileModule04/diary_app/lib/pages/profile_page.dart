import 'package:flutter/material.dart';
import '../models/diary_entry.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<DiaryEntry> _entries = [
    DiaryEntry(
      title: 'First entry',
      feeling: '😊',
      content: 'Today I started my diary app.',
      date: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
      ),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];

          return ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.feeling),
          );
        },
      ),
    );
  }
}