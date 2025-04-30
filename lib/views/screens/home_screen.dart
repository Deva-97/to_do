import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  void _addTask() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    final newTask = Task(id: '', title: title, completed: false);
    Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter the task',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: taskProvider.tasks.isEmpty
                ? const Center(child: Text('No tasks yet'))
                : ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                return TaskTile(task: taskProvider.tasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
