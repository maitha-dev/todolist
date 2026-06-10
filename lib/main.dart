import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

void main() {

  final provider = TaskProvider();
  provider.loadTasks();

  runApp(
    ChangeNotifierProvider(
      create: (_) => provider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: TodoPage(
        isDark: isDark,
        onThemeChanged: (value) {
          setState(() {
            isDark = value;
          });
        },
      ),
    );
  }
}

class TodoPage extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const TodoPage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController taskController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final tasks = provider.tasks;

    final completed = tasks.where((t) => t["done"] == true).length;
    final remaining = tasks.length - completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Tasks To Do",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              const Icon(Icons.dark_mode),
              Switch(
                value: widget.isDark,
                onChanged: (value) {
                  widget.onThemeChanged(value);
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Completed: $completed | Remaining: $remaining"),

            const SizedBox(height: 10),

            Form(
              key: _formKey,
              child: TextFormField(
                controller: taskController,
                decoration: const InputDecoration(
                  labelText: "Enter a task",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a task";
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    provider.addTask(taskController.text.trim());
                    taskController.clear();
                  }
                },
                child: const Text("Add Task"),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return ListTile(
                    leading: Checkbox(
                      value: task["done"] == true,
                      onChanged: (_) => provider.toggleTask(index),
                    ),
                    title: Text(task["title"]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.deleteTask(task["id"]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}