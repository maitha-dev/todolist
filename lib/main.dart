
import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
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
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController taskController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final data = await dbHelper.getTasks();
    setState(() {
      tasks = data.map((e) => {
        "id": e["id"],
        "title": e["title"],
        "done": e["done"] == 1,
      }).toList();
    });
  }

  void _addTask() async {
    if (!_formKey.currentState!.validate()) return;

    await dbHelper.insertTask({
      "title": taskController.text.trim(),
      "done": 0,
    });

    taskController.clear();
    _loadTasks();
  }

  void _toggleTask(int index) async {
    final task = tasks[index];
    await dbHelper.updateTask({
      "id": task["id"],
      "title": task["title"],
      "done": task["done"] ? 0 : 1,
    });
    _loadTasks();
  }

  void _deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    _loadTasks();
  }

  Widget _card(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                onChanged: widget.onThemeChanged,
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/task.png",
                    height: MediaQuery.of(context).size.width * 0.25,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Task Manager",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Manage your daily tasks easily",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                int columns = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _card("Total", tasks.length.toString(), Icons.list),
                    _card("Completed", completed.toString(), Icons.check_circle),
                    _card("Remaining", remaining.toString(), Icons.pending),
                    _card("Pending", remaining.toString(), Icons.access_time),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: "Enter a task",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                onPressed: _addTask,
                child: const Text("Add Task"),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: task["done"],
                        onChanged: (_) => _toggleTask(index),
                      ),
                      title: Text(
                        task["title"],
                        style: TextStyle(
                          decoration: task["done"]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(task["id"]),
                      ),
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

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
}
