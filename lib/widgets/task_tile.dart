import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../views/screens/share_task_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: task.completed ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        leading: Checkbox(
          value: task.completed,
          onChanged: (val) {
            taskProvider.updateTask(Task(
              id: task.id,
              title: task.title,
              completed: val ?? false,
            ));
          },
        ),

        // ← SHARE button + edit/delete menu
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Share',
              icon: const Icon(Icons.share),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShareTaskScreen(task: task),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final ctrl = TextEditingController(text: task.title);
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Edit Task'),
                      content: TextField(
                        controller: ctrl,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'Task title'),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () {
                            final newTitle = ctrl.text.trim();
                            if (newTitle.isNotEmpty) {
                              taskProvider.updateTask(Task(
                                id: task.id,
                                title: newTitle,
                                completed: task.completed,
                              ));
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Task'),
                      content: const Text(
                          'Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        ElevatedButton(
                          child: const Text('Delete'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    taskProvider.deleteTask(task.id);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
