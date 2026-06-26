import 'package:flutter/material.dart';
import '../models/diary_entry.dart';

class EntryDetailPage extends StatelessWidget {
  const EntryDetailPage({
    super.key,
    required this.entry,
  });

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feeling: ${entry.feeling}'),
            const SizedBox(height: 10),
            Text('Date: ${entry.date}'),
            const SizedBox(height: 20),
            Text(entry.content),
          ],
        ),
      ),
    );
  }
}