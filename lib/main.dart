import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Android IDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  TextEditingController controller = TextEditingController();
  
  String output = "Server se connect ho raha hai...";
  bool isBuilding = false;

  // Render API URL
  final String apiUrl = "https://android-builder-api.onrender.com";

  // Default Java code (Kyunki backend pe gradle java-application hai)
  final String defaultCode = '''
package com.example;

public class App {
    public String getGreeting() {
        return "Hello from Cloud IDE!";
    }

    public static void main(String[] args) {
        System.out.println(new App().getGreeting());
    }
}
''';

  @override
  void initState() {
    super.initState();
    controller.text = defaultCode;
    _checkServer();
  }

  // Check if server is awake
  Future<void> _checkServer() async {
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        setState(() => output = "✅ Server Ready: ${res.body}");
      }
    } catch (e) {
      setState(() => output = "❌ Server se connect nahi ho paya.");
    }
  }

  // Initialize Project on Cloud
  Future<void> createProject() async {
    setState(() => output = "Creating project on cloud...");
    try {
      final res = await http.post(Uri.parse("$apiUrl/create"));
      setState(() => output = "Create Response: ${res.body}");
    } catch (e) {
      setState(() => output = "Error: $e");
    }
  }

  // Send code to Cloud & Build
  Future<void> buildApk() async {
    setState(() {
      isBuilding = true;
      output = "Code bhej raha hai aur build start ho raha hai...\nIsme 1-2 minute lag sakte hain.";
    });

    try {
      final res = await http.post(
        Uri.parse("$apiUrl/build"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "code": controller.text // User ka code bhej rahe hain
        }),
      );

      if (res.statusCode == 200) {
        setState(() {
          output = "✅ Build Success!\n${res.body}";
        });
      } else {
        setState(() {
          output = "❌ Build Failed:\n${res.body}";
        });
      }
    } catch (e) {
      setState(() => output = "❌ Exception: $e");
    } finally {
      setState(() => isBuilding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Native Java Builder"),
        actions: [
          IconButton(
            tooltip: "Create Project",
            icon: Icon(Icons.create_new_folder, color: Colors.blueAccent),
            onPressed: createProject,
          ),
          isBuilding 
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
              )
            : IconButton(
                tooltip: "Build Code",
                icon: Icon(Icons.play_arrow, color: Colors.greenAccent),
                onPressed: buildApk,
              ),
        ],
      ),
      body: Column(
        children: [
          // Code Editor
          Expanded(
            flex: 3,
            child: Container(
              color: Color(0xFF1E1E1E),
              padding: EdgeInsets.all(12),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(border: InputBorder.none),
                style: TextStyle(fontFamily: 'monospace', fontSize: 15, color: Colors.white),
              ),
            ),
          ),
          // Output Console
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              padding: EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Text(
                  "> $output",
                  style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
