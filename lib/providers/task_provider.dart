import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';

enum TaskFilter { all, completed, incomplete }

class TaskProvider extends ChangeNotifier {
  final _service = FirestoreService();
  List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;

  List<Task> get tasks {
    switch (_filter) {
      case TaskFilter.completed:
        return _tasks.where((t) => t.completed).toList();
      case TaskFilter.incomplete:
        return _tasks.where((t) => !t.completed).toList();
      default:
        return _tasks;
    }
  }

  TaskFilter get filter => _filter;

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void loadTasks() {
    _service.taskStream().listen((list) {
      _tasks = list;
      notifyListeners();
    });
  }

  Future<void> addTask(Task task) async {
    await _service.addTask(task);
  }

  Future<void> updateTask(Task task) async {
    await _service.updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _service.deleteTask(taskId);
  }

  Future<void> shareTask(Task task, String platform, String to) async {
    await _service.addShareRecord(task.id, platform, to);
  }
}