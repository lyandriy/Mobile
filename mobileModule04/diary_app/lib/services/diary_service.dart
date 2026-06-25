import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/diary_entry.dart';

class DiaryService {
  final SupabaseClient _client = Supabase.instance.client;

  String _getUserEmail() {
    final email = _client.auth.currentUser?.email;

    if (email == null) {
      throw Exception('User is not logged in');
    }

    return email;
  }

  Future<List<DiaryEntry>> getEntries() async {
    final userEmail = _getUserEmail();

    final data = await _client
        .from('diary_entries')
        .select()
        .eq('user_email', userEmail)
        .order('date', ascending: false);

    return data.map<DiaryEntry>((map) {
      return DiaryEntry.fromMap(map);
    }).toList();
  }

  Future<void> addEntry(DiaryEntry entry) async {
    final userEmail = _getUserEmail();

    final entryWithUser = DiaryEntry(
      userEmail: userEmail,
      title: entry.title,
      feeling: entry.feeling,
      content: entry.content,
      date: entry.date,
    );

    await _client.from('diary_entries').insert(entryWithUser.toMap());
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    if (entry.id == null) {
      return;
    }

    await _client
        .from('diary_entries')
        .delete()
        .eq('id', entry.id!);
  }
}