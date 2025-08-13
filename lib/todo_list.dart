import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> _tasks = [];
  TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
      });
    }
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(_tasks));
  }

  void _addTask(String task) {
    if (task.trim().isEmpty) return;
    setState(() {
      _tasks.add({'title': task, 'done': false});
      _taskController.clear();
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _toggleComplete(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("📝 Add New Task"),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Type your task here...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addTask(_taskController.text);
              Navigator.pop(context);
            },
            child: Text("Add", style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _taskController.clear();
            },
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3BE85), // Match login/signup screen
      appBar: AppBar(
        title: const Text('Your Tasks',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,color: Colors.white,),
            tooltip: "Add Task",
            onPressed: _showAddTaskDialog,
          )
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(
        child: Text(
          "🧾 No tasks yet.\nTap + to add one!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: IconButton(
                icon: Icon(
                  task['done']
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task['done'] ? Colors.green : Colors.grey,
                ),
                onPressed: () => _toggleComplete(index),
              ),
              title: Text(
                task['title'],
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  decoration: task['done'] ? TextDecoration.lineThrough : null,
                  color: task['done'] ? Colors.grey : Colors.black,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteTask(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
