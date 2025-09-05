class Task {
  String id;
  String title;
  bool isCompleted;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  factory Task.fromFirestore(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
    };
  }
}