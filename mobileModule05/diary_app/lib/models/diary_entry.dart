class DiaryEntry {
  final String title;
  final String feeling;
  final String content;
  final DateTime date;
  final String? id;
  final String? userEmail;

  DiaryEntry({
    required this.title,
    required this.feeling,
    required this.content,
    required this.date,
    this.id,
    this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_email': userEmail,
      'title': title,
      'feeling': feeling,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      userEmail: map['user_email'],
      title: map['title'],
      feeling: map['feeling'],
      content: map['content'],
      date: DateTime.parse(map['date']),
    );
  }
}