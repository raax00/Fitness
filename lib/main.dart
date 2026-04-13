import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
// Workspace Screen ko import karna zaroori hai
import 'WorkspaceScreen.dart';

void main() {
  runApp(const IDEApp());
}

class IDEApp extends StatelessWidget {
  const IDEApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pro Flutter IDE',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pro IDE", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuCard(
                context, title: "Create Project", subtitle: "Start from a new template",
                icon: Icons.add_circle, color: Colors.blueAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkspaceScreen(projectName: "My_New_App"))),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context, title: "Settings", subtitle: "Download SDKs",
                icon: Icons.settings, color: Colors.grey,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
            ])),
          ],
        ),
      ),
    );
  }
}

// --- SETUP SCREEN (DOWNLOADER) ---
class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final Map<String, double> downloadProgress = {'OpenJDK 17': 0.0, 'Flutter SDK': 0.0};

  void _startDownload(String toolName) async {
    // Ye Dio package use karke real download karega
    final dio = Dio();
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/$toolName.zip';
    
    String dummyUrl = "https://sabnzbd.org/tests/internetspeed/20MB.bin"; 
    
    try {
      await dio.download(dummyUrl, savePath, onReceiveProgress: (rec, total) {
        if (total != -1) setState(() => downloadProgress[toolName] = rec / total);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup SDKs")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: downloadProgress.keys.map((tool) {
          double progress = downloadProgress[tool]!;
          return Card(
            color: const Color(0xFF1A1A1A),
            child: ListTile(
              title: Text(tool),
              subtitle: progress > 0 && progress < 1.0 ? LinearProgressIndicator(value: progress) : null,
              trailing: progress == 1.0 ? const Icon(Icons.check, color: Colors.green) : IconButton(icon: const Icon(Icons.download), onPressed: () => _startDownload(tool)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
