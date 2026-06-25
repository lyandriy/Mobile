import 'package:flutter/material.dart';
import '../models/diary_entry.dart';

class CreateEntryPage extends StatefulWidget {
  const CreateEntryPage({super.key});

  @override
  State<CreateEntryPage> createState() => _CreateEntryPageState();
}

class _CreateEntryPageState extends State<CreateEntryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _feelingController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _saveEntry() {
    final entry = DiaryEntry(
      title: _titleController.text,
      feeling: _feelingController.text,
      content: _contentController.text,
      date: DateTime.now(),
    );

    Navigator.pop(context, entry);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _feelingController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: _feelingController,
              decoration: const InputDecoration(
                labelText: 'Feeling',
              ),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}