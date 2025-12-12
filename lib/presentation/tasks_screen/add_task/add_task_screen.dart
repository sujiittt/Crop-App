// lib/presentation/screens/add_task_screen.dart
import 'package:flutter/material.dart';
import 'add_task_sheet.dart';

class AddTaskScreen extends StatelessWidget {
  static const routeName = '/add-task';
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: const SingleChildScrollView(
        child: AddTaskSheet(),
      ),
    );
  }
}

