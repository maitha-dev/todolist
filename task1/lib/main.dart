import 'package:flutter/material.dart';

void main() {
  runApp(const WidgetPlaygroundApp());
}

class WidgetPlaygroundApp extends StatelessWidget {
  const WidgetPlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Widget Playground',
      home: const PlaygroundScreen(),
    );
  }
}

class PlaygroundScreen extends StatelessWidget {
  const PlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Widget Playground"),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // images
            Image.network(
              "https://picsum.photos/400/200",
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20),

            // text
            const Text(
              "Welcome to Flutter",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // container
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "This is a Container widget",
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // rows and icons
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home, size: 40),
                Icon(Icons.favorite, size: 40, color: Colors.red),
                Icon(Icons.settings, size: 40),
              ],
            ),

            const SizedBox(height: 30),

            // stacks
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
                  height: 180,
                  color: Colors.orange,
                ),
                const Text(
                  "This is the Stack Widget",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // columns
            const Column(
              children: [
                Text("Column Item 1"),
                SizedBox(height: 10),
                Text("Column Item 2"),
                SizedBox(height: 10),
                Text("Column Item 3"),
              ],
            ),

            const SizedBox(height: 30),

            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade100,
              child: const Text(
                "Flutter Learning Journey",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}