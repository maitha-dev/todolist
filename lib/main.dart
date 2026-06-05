import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  // Load tasks from database
  void _refreshTasks() async {
    final data = await dbHelper.getTasks();
    setState(() {
      tasks = data.map((item) {
        return {
          "id": item["id"],
          "title": item["title"],
          "done": item["done"] == 1,
        };
      }).toList();
    });
  }

  // Add task to database
  void _addTask() async {
    if (taskController.text.isEmpty) return;

    await dbHelper.insertTask({
      "title": taskController.text,
      "done": 0,
    });

    taskController.clear();
    _refreshTasks();
  }

  // Update task status in database
  void _toggleTask(int index) async {
    final task = tasks[index];
    await dbHelper.updateTask({
      "id": task["id"],
      "title": task["title"],
      "done": task["done"] ? 0 : 1,
    });
    _refreshTasks();
  }

  // Delete task from database
  void _deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Tasks To Do",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.cyan[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: "Enter a task",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text("Add Task"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: tasks[index]["done"],
                        activeColor: Colors.green,
                        onChanged: (value) {
                          _toggleTask(index);
                        },
                      ),
                      title: Text(
                        tasks[index]["title"],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: tasks[index]["done"]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: tasks[index]["done"]
                              ? Colors.grey
                                             : Colors.black,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteTask(tasks[index]["id"]);
                        },
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
