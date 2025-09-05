import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task3/models/task_model.dart';
import 'package:task3/provider/task_provider.dart';


class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    if (_user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<TaskProvider>(context, listen: false).fetchTasks(_user!.uid);
      });
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty && _user != null) {
      Provider.of<TaskProvider>(context, listen: false)
          .addTask(_user!.uid, _taskController.text);
      _taskController.clear();
      FocusScope.of(context).unfocus(); // Keyboard hide karo
    }
  }

  void _deleteTask(String taskId) {
    if (_user != null) {
      Provider.of<TaskProvider>(context, listen: false)
          .deleteTask(_user!.uid, taskId);
    }
  }

  void _toggleTask(String taskId) {
    if (_user != null) {
      Provider.of<TaskProvider>(context, listen: false)
          .toggleTask(_user!.uid, taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: _user == null
          ? _buildLoginPrompt()
          : Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              // Add Task Section
              _buildAddTaskSection(taskProvider),

              // Loading Indicator
              if (taskProvider.isLoading)
                const LinearProgressIndicator(),

              // Tasks List
              Expanded(
                child: _buildTasksList(taskProvider),
              ),

              // Statistics
              _buildStatistics(taskProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Please login to manage tasks',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskSection(TaskProvider taskProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Add new task',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _taskController.clear(),
                ),
              ),
              onSubmitted: (_) => _addTask(),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _addTask,
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(TaskProvider taskProvider) {
    if (taskProvider.tasks.isEmpty && !taskProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 64, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No tasks yet!\nAdd your first task above.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return _buildTaskItem(task);
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: Key(task.id),
      background: Container(color: Colors.red),
      secondaryBackground: Container(color: Colors.blue),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _toggleTask(task.id);
          return false; // Delete nahi karna, just toggle
        }
        return true; // Delete karo
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _deleteTask(task.id);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) => _toggleTask(task.id),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: task.isCompleted ? Colors.grey : Colors.black,
            ),
          ),
          trailing: Text(
            '${task.createdAt.day}/${task.createdAt.month}',
            style: TextStyle(
              color: task.isCompleted ? Colors.green : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(TaskProvider taskProvider) {
    final completedTasks = taskProvider.tasks
        .where((task) => task.isCompleted)
        .length;
    final totalTasks = taskProvider.tasks.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalTasks),
          _buildStatItem('Completed', completedTasks),
          _buildStatItem('Pending', totalTasks - completedTasks),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}