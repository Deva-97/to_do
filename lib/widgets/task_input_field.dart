import 'package:flutter/material.dart';

class TaskInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const TaskInputField({
    required this.controller,
    required this.onAdd,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter task',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
