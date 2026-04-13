import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Deep dark premium look
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: CupertinoColors.activeBlue),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// ==========================================
/// 1. HOME SCREEN
/// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pro IDE", style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Responsive for tablets/web
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildMenuCard(
                context,
                title: "Create Project",
                subtitle: "Start from a new template",
                icon: CupertinoIcons.add_circled_solid,
                color: CupertinoColors.activeBlue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateScreen())),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: "Existing Project",
                subtitle: "Open from device storage",
                icon: CupertinoIcons.folder_solid,
                color: CupertinoColors.systemOrange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File Picker will open here")));
                },
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: "Settings & Setup",
                subtitle: "Download SDKs & configure build tools",
                icon: CupertinoIcons.settings_solid,
                color: CupertinoColors.systemGrey,
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
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// 2. SETTINGS / SETUP SCREEN (DOWNLOADER)
/// ==========================================
class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final Map<String, double> downloadProgress = {
    'OpenJDK 17': 0.0,
    'Android SDK (Cmd Tools)': 0.0,
    'Flutter SDK (Stable)': 0.0,
  };

  void _downloadTool(String toolName) async {
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (mounted) {
        setState(() {
          downloadProgress[toolName] = i / 100;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Build Tools Setup")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: downloadProgress.keys.map((tool) {
          double progress = downloadProgress[tool]!;
          bool isDone = progress == 1.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tool, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    isDone 
                      ? const Icon(CupertinoIcons.checkmark_seal_fill, color: CupertinoColors.systemGreen)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CupertinoColors.activeBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: progress > 0 ? null : () => _downloadTool(tool),
                          child: Text(progress > 0 ? "Downloading" : "Download"),
                        )
                  ],
                ),
                if (progress > 0 && !isDone) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      color: CupertinoColors.activeBlue,
                      minHeight: 6,
                    ),
                  )
                ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// ==========================================
/// 3. TEMPLATE CHOOSER SCREEN
/// ==========================================
class TemplateScreen extends StatelessWidget {
  const TemplateScreen({Key? key}) : super(key: key);
  final List<String> templates = const ["Empty Flutter App", "Bottom Navigation", "Login Screen UI", "Game UI Template"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Template")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkspaceScreen(projectName: templates[index]))),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Center(
                child: Text(templates[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ==========================================
/// 4. MAIN WORKSPACE (EDITOR + TERMINAL + FILES)
/// ==========================================
class WorkspaceScreen extends StatefulWidget {
  final String projectName;
  const WorkspaceScreen({Key? key, required this.projectName}) : super(key: key);

  @override
  _WorkspaceScreenState createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  // File Explorer State
  List<String> projectFiles = ['lib/main.dart', 'lib/utils.dart', 'pubspec.yaml'];
  String selectedFile = 'lib/main.dart';
  
  // Editor State
  TextEditingController codeController = TextEditingController();
  
  // Terminal State
  List<String> terminalOutput = ["Welcome to ProIDE Termux Emulator.", "Type 'flutter build apk' to compile."];
  TextEditingController terminalInput = TextEditingController();
  bool isTerminalOpen = true;

  @override
  void initState() {
    super.initState();
    codeController.text = "import 'package:flutter/material.dart';\n\nvoid main() {\n  runApp(MyApp());\n}";
  }

  void _addNewFile(String type) {
    setState(() {
      projectFiles.add('lib/new_$type.dart');
      terminalOutput.add("\$ Created new $type");
    });
  }

  void _handleTerminalCommand(String command) {
    if (command.trim().isEmpty) return;
    setState(() {
      terminalOutput.add("\$ $command");
      if (command == "clear") {
        terminalOutput.clear();
      } else if (command.contains("flutter build apk")) {
        terminalOutput.add("> Compiling APK... (Simulated)");
        terminalOutput.add("> Checking SDK paths...");
        terminalOutput.add("> Build Successful: build/app/outputs/flutter-apk/app-release.apk");
      } else {
        terminalOutput.add("bash: $command: command not found");
      }
      terminalInput.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.play_arrow_solid, color: CupertinoColors.systemGreen),
            tooltip: "Run App",
            onPressed: () => _handleTerminalCommand("flutter run"),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.hammer_fill, color: Colors.orange),
            tooltip: "Build APK",
            onPressed: () => _handleTerminalCommand("flutter build apk"),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.terminal, color: isTerminalOpen ? CupertinoColors.activeBlue : Colors.grey),
            onPressed: () => setState(() => isTerminalOpen = !isTerminalOpen),
          ),
        ],
      ),
      // Drawer is used for mobile file manager, on tablet it's a Row
      drawer: isWideScreen ? null : Drawer(child: _buildFileManager()),
      body: Row(
        children: [
          if (isWideScreen)
            SizedBox(
              width: 250,
              child: _buildFileManager(),
            ),
          if (isWideScreen) const VerticalDivider(width: 1, color: Colors.black),
          
          Expanded(
            child: Column(
              children: [
                // Code Editor
                Expanded(
                  flex: 3,
                  child: Container(
                    color: const Color(0xFF121212),
                    child: TextField(
                      controller: codeController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 15, color: Colors.white),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                
                // Terminal (Termux Emulator UI)
                if (isTerminalOpen)
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.black, // True black for terminal
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: const Color(0xFF202020),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            width: double.infinity,
                            child: const Text("Terminal (bash)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: terminalOutput.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  terminalOutput[index],
                                  style: const TextStyle(color: CupertinoColors.systemGreen, fontFamily: 'monospace', fontSize: 13),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              children: [
                                const Text("\$ ", style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                                Expanded(
                                  child: TextField(
                                    controller: terminalInput,
                                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    onSubmitted: _handleTerminalCommand,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Android Studio Style File Manager
  Widget _buildFileManager() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16).copyWith(top: 40),
            color: const Color(0xFF121212),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("PROJECT FILES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                Row(
                  children: [
                    InkWell(onTap: () => _addNewFile('file'), child: const Icon(CupertinoIcons.doc_badge_plus, size: 20)),
                    const SizedBox(width: 12),
                    InkWell(onTap: () => _addNewFile('folder'), child: const Icon(CupertinoIcons.folder_badge_plus, size: 20)),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: projectFiles.length,
              itemBuilder: (context, index) {
                String file = projectFiles[index];
                bool isSelected = selectedFile == file;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    file.endsWith('.dart') ? CupertinoIcons.doc_text_fill : CupertinoIcons.settings,
                    color: isSelected ? CupertinoColors.activeBlue : Colors.grey,
                    size: 20,
                  ),
                  title: Text(file, style: TextStyle(color: isSelected ? CupertinoColors.activeBlue : Colors.white, fontSize: 14)),
                  selected: isSelected,
                  selectedTileColor: Colors.white.withOpacity(0.05),
                  onTap: () {
                    setState(() {
                      selectedFile = file;
                      // Yaha pe selected file ka text load hoga
                      codeController.text = "// Viewing $file\n\n// Code goes here...";
                    });
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context); // Close drawer on mobile
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
