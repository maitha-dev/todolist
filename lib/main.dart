import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

/// ROOT APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoPage(),
    );
  }
}

/// MAIN PAGE
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController taskController = TextEditingController();

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// LOAD TASKS
  void _loadTasks() async {
    final data = await dbHelper.getTasks();

    setState(() {
      tasks = data
          .map((e) => {
        "id": e["id"],
        "title": e["title"],
        "done": e["done"] == 1,
      })
          .toList();
    });
  }

  /// ADD TASK
  void _addTask() async {
    if (taskController.text.trim().isEmpty) return;

    await dbHelper.insertTask({
      "title": taskController.text.trim(),
      "done": 0,
    });

    taskController.clear();
    _loadTasks();
  }

  /// TOGGLE TASK
  void _toggleTask(int index) async {
    final task = tasks[index];

    await dbHelper.updateTask({
      "id": task["id"],
      "title": task["title"],
      "done": task["done"] ? 0 : 1,
    });

    _loadTasks();
  }

  /// DELETE TASK
  void _deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    _loadTasks();
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// HEADER (IMAGE + TITLE)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  /// IMAGE (TASK ILLUSTRATION)
                  Image.asset(
                    "assets/images/task.png",
                    height: MediaQuery.of(context).size.width * 0.25,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Task Manager",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Manage your daily tasks easily",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// DASHBOARD TITLE
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// DASHBOARD CARDS (GRID RESPONSIVE)
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

            /// INPUT FIELD
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: "Enter a task",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// ADD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask,
                child: const Text("Add Task"),
              ),
            ),

            const SizedBox(height: 10),

            /// TASK LIST
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

  /// DASHBOARD CARD WIDGET
  Widget _card(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(value),
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