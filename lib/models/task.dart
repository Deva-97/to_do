class Task {
  final String id;
  final String title;
  final bool completed;

  Task({required this.id, required this.title, this.completed = false});

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'], title: json['title'], completed: json['completed'],
  );

  Map<String, dynamic> toJson() => {'title': title, 'completed': completed};
}