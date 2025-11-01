import 'package:flutter/material.dart';
import 'package:task_manager_app/models/task_model.dart';
import 'package:task_manager_app/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();
  List<TaskModel> _tasks = [];
  bool _loading = false;

  List<TaskModel> get tasks => _tasks;
  bool get loading => _loading;

  Future<void> loadTasks() async {
    _loading = true;
    notifyListeners();
    try {
      _tasks = await _service.fetchTasks();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title, String description) async {
    _loading = true;
    notifyListeners();
    try {
      final newTask = await _service.addTask(title, description);
      _tasks.insert(0, newTask);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    _loading = true;
    notifyListeners();
    try {
      await _service.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel t) async {
    _loading = true;
    notifyListeners();
    try {
      final updated = await _service.updateTask(t);
      final idx = _tasks.indexWhere((e) => e.id == updated.id);
      if (idx != -1) _tasks[idx] = updated;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
