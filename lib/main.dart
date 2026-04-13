import 'package:flutter/material.dart';

void main() {
  runApp(CloudIDEApp());
}

class CloudIDEApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Local IDE',
      // Premium dark theme 
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
        // ✅ BUG FIXED HERE: Changed CardTheme to CardThemeData
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
        ),
      ),
      home: HomeScreen(),
    );
  }
}

/// ---------------- 1. HOME SCREEN ----------------
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter IDE", style: TextStyle(fontWeight: FontWeight.w600))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHomeOption(
              context, 
              title: "Create Project", 
              subtitle: "Start a new Flutter app", 
              icon: Icons.add_box_rounded, 
              color: Colors.blueAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateScreen())),
            ),
            const SizedBox(height: 20),
            _buildHomeOption(
              context, 
              title: "Existing Project", 
              subtitle: "Open project from internal storage", 
              icon: Icons.folder_open_rounded, 
              color: Colors.orangeAccent,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File Picker open hoga...")));
              },
            ),
            const SizedBox(height: 20),
            _buildHomeOption(
              context, 
              title: "Settings", 
              subtitle: "Download SDKs & configure IDE", 
              icon: Icons.settings_rounded, 
              color: Colors.grey,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeOption(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white54)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// ---------------- 2. SETTINGS SCREEN (DOWNLOADER) ----------------
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double jdkProgress = 0.0;
  double sdkProgress = 0.0;
  double flutterProgress = 0.0;

  void _startDownload(String type) async {
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      setState(() {
        if (type == 'JDK') jdkProgress = i / 100;
        if (type == 'SDK') sdkProgress = i / 100;
        if (type == 'FLUTTER') flutterProgress = i / 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings & Tools")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Required Tools", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white54)),
          const SizedBox(height: 10),
          _buildDownloadCard("OpenJDK 17", "Required to compile Java code", jdkProgress, () => _startDownload('JDK')),
          _buildDownloadCard("Android SDK", "Command-line tools & Build tools", sdkProgress, () => _startDownload('SDK')),
          _buildDownloadCard("Flutter SDK", "Framework to build Flutter apps", flutterProgress, () => _startDownload('FLUTTER')),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(String title, String desc, double progress, VoidCallback onDownload) {
    bool isDownloaded = progress == 1.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                  ],
                ),
                isDownloaded
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: progress > 0 ? null : onDownload,
                        child: Text(progress > 0 ? "Downloading..." : "Download"),
                      )
              ],
            ),
            if (progress > 0 && progress < 1.0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress, backgroundColor: Colors.white12, color: Colors.blueAccent),
            ]
          ],
        ),
      ),
    );
  }
}

/// ---------------- 3. TEMPLATE SELECTION ----------------
class TemplateScreen extends StatelessWidget {
  final templates = ["Counter App", "To-Do App", "Login UI", "Blank Project"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Template")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.2
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EditorScreen(templateName: templates[index])));
            },
            child: Card(
              child: Center(
                child: Text(templates[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------- 4. OFFLINE EDITOR SCREEN ----------------
class EditorScreen extends StatefulWidget {
  final String templateName;
  const EditorScreen({required this.templateName});

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  TextEditingController codeController = TextEditingController();
  String consoleOutput = "Terminal Ready...";

  @override
  void initState() {
    super.initState();
    codeController.text = '''
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('${widget.templateName}')),
        body: Center(child: Text('Building offline!')),
      ),
    );
  }
}
''';
  }

  void _runOfflineBuild() async {
    setState(() {
      consoleOutput = "Checking tools...\n";
    });
    
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      consoleOutput += "Validating JDK and Android SDK paths...\n";
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      consoleOutput += "Running flutter build apk --release...\n(This would use Process.run in real app)\n";
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      consoleOutput += "✅ Build successful! APK saved in internal storage.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templateName),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 28),
            tooltip: "Run/Build Offline",
            onPressed: _runOfflineBuild,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: codeController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Text(
                  "> $consoleOutput",
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
