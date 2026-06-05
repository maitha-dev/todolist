import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
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

  void _addTask() async {
    if (taskController.text.isEmpty) return;

    await dbHelper.insertTask({
      "title": taskController.text,
      "done": 0,
    });

    taskController.clear();
    _refreshTasks();
  }

  void _toggleTask(int index) async {
    final task = tasks[index];

    await dbHelper.updateTask({
      "id": task["id"],
      "title": task["title"],
      "done": task["done"] ? 0 : 1,
    });

    _refreshTasks();
  }

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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [


                  Image.asset(
                    "assets/images/task.png",
                    height: 100,
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 180,
                    width: 180,

                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      shape: BoxShape.circle,
                    ),
                    child:

                    const Icon(
                      Icons.add_task,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task),
                      SizedBox(width: 8),
                      Text(
                        "Task Manager",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      children: const [
                        Icon(
                          Icons.circle,
                          size: 60,
                          color: Colors.blue,
                        ),
                        Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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
                        onChanged: (value) {
                          _toggleTask(index);
                        },
                        activeColor: Colors.green,
                      ),
                      title: Text(
                        tasks[index]["title"],
                        style: TextStyle(
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