import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task.dart';

class SharedTaskDetailScreen extends StatelessWidget {
  final String taskId;
  const SharedTaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);

    return Scaffold(
      appBar: AppBar(title: const Text('Shared Task')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text('Task not found'));

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final task = Task.fromJson({...data, 'id': taskId});
          final controller = TextEditingController(text: task.title);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Task title'),
                  onSubmitted: (val) {
                    docRef.update({
                      'title': controller.text.trim(),
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Completed'),
                  value: task.completed,
                  onChanged: (val) {
                    docRef.update({'completed': val});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
