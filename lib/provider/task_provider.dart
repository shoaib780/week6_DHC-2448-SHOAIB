import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      _tasks = querySnapshot.docs.map((doc) {
        return Task.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tasks: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String userId, String title) async {
    try {
      final newTask = Task(
        id: '',
        title: title,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .add(newTask.toFirestore());

      newTask.id = docRef.id;
      _tasks.insert(0, newTask);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding task: $e');
      }
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
    }
  }

  Future<void> toggleTask(String userId, String taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final newStatus = !task.isCompleted;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': newStatus});

      task.isCompleted = newStatus;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
    }
  }
}