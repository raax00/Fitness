import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

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
          iconTheme: IconThemeData(color: Colors.blueAccent),
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
/// REAL BACKEND ENGINE (FILE, TERMINAL, DOWNLOAD)
/// ==========================================

class RealFileManager {
  late Directory projectRoot;

  Future<void> initProject(String projectName) async {
    final directory = await getApplicationDocumentsDirectory();
    projectRoot = Directory('${directory.path}/$projectName');
    
    if (!await projectRoot.exists()) {
      await projectRoot.create(recursive: true);
      await Directory('${projectRoot.path}/lib').create(recursive: true);
      await File('${projectRoot.path}/lib/main.dart').writeAsString(
        "import 'package:flutter/material.dart';\n\nvoid main() => runApp(MyApp());\n\nclass MyApp extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(home: Scaffold(body: Center(child: Text('Hello Raja!'))));\n  }\n}"
      );
      await File('${projectRoot.path}/pubspec.yaml').writeAsString(
        "name: $projectName\nenvironment:\n  sdk: '>=2.17.0 <4.0.0'\n"
      );
    }
  }

  Future<void> saveFile(String relativePath, String content) async {
    final file = File('${projectRoot.path}/$relativePath');
    await file.writeAsString(content);
  }

  Future<String> readFile(String relativePath) async {
    final file = File('${projectRoot.path}/$relativePath');
    if (await file.exists()) return await file.readAsString();
    return "";
  }
}

class RealTerminal {
  final Function(String) onOutput;
  RealTerminal({required this.onOutput});

  Future<void> executeCommand(String command, String workingDirectory) async {
    onOutput('\$ $command\n');
    try {
      final process = await Process.start(
        'sh', ['-c', command],
        workingDirectory: workingDirectory,
      );
      process.stdout.transform(utf8.decoder).listen((data) => onOutput(data));
      process.stderr.transform(utf8.decoder).listen((data) => onOutput('ERROR: $data'));
      final exitCode = await process.exitCode;
      onOutput('\n[Process exited with code $exitCode]\n');
    } catch (e) {
      onOutput('System Error: $e\n');
    }
  }
}

class RealDownloader {
  final Dio dio = Dio();

  Future<void> downloadTool(String url, String fileName, Function(double) onProgress) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/$fileName';
      
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) onProgress(received / total);
        },
      );
    } catch (e) {
      print("Download Error: $e");
    }
  }
}

/// ==========================================
/// UI SCREENS
/// ==========================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pro IDE", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildMenuCard(
                context, title: "Create Project", subtitle: "Start from a new template",
                icon: Icons.add_circle, color: Colors.blueAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateScreen())),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context, title: "Existing Project", subtitle: "Open from device storage",
                icon: Icons.folder, color: Colors.orange,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File Picker will open here"))),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context, title: "Settings & Setup", subtitle: "Download SDKs & configure build tools",
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

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final RealDownloader downloader = RealDownloader();
  final Map<String, double> downloadProgress = {
    'OpenJDK 17': 0.0,
    'Android SDK Tools': 0.0,
    'Flutter SDK': 0.0,
  };

  void _startRealDownload(String toolName) async {
    // Ye actual URLs aapko host karne padenge (ZIP files ke)
    String dummyUrl = "https://sabnzbd.org/tests/internetspeed/20MB.bin"; // Test file
    
    await downloader.downloadTool(dummyUrl, "$toolName.zip", (progress) {
      if (mounted) {
        setState(() => downloadProgress[toolName] = progress);
      }
    });
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
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tool, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    isDone 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          onPressed: progress > 0 ? null : () => _startRealDownload(tool),
                          child: Text(progress > 0 ? "${(progress * 100).toStringAsFixed(0)}%" : "Download"),
                        )
                  ],
                ),
                if (progress > 0 && !isDone) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: progress, color: Colors.blueAccent),
                ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({Key? key}) : super(key: key);
  final List<String> templates = const ["Empty Flutter App", "Bottom Navigation", "Login Screen UI", "Game UI Template"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Template")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkspaceScreen(projectName: "Project_${index + 1}"))),
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Center(child: Text(templates[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ),
          );
        },
      ),
    );
  }
}

class WorkspaceScreen extends StatefulWidget {
  final String projectName;
  const WorkspaceScreen({Key? key, required this.projectName}) : super(key: key);

  @override
  _WorkspaceScreenState createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final RealFileManager fileManager = RealFileManager();
  late RealTerminal terminal;
  
  List<String> projectFiles = ['lib/main.dart', 'pubspec.yaml'];
  String selectedFile = 'lib/main.dart';
  String currentPath = "";
  
  TextEditingController codeController = TextEditingController();
  List<String> terminalOutput = [];
  TextEditingController terminalInput = TextEditingController();
  bool isTerminalOpen = true;

  @override
  void initState() {
    super.initState();
    terminal = RealTerminal(onOutput: (data) {
      if (mounted) setState(() => terminalOutput.add(data));
    });
    _initProjectData();
  }

  Future<void> _initProjectData() async {
    await fileManager.initProject(widget.projectName);
    String mainCode = await fileManager.readFile('lib/main.dart');
    setState(() {
      currentPath = fileManager.projectRoot.path;
      codeController.text = mainCode;
      terminalOutput.add("Project initialized at $currentPath\n");
    });
  }

  void _saveCurrentFile() async {
    await fileManager.saveFile(selectedFile, codeController.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$selectedFile saved!")));
  }

  void _addNewFile(String type) async {
    String newFile = type == 'file' ? 'lib/new_file.dart' : 'lib/new_folder/';
    setState(() => projectFiles.add(newFile));
    if (type == 'file') await fileManager.saveFile(newFile, "// New Dart File");
  }

  void _handleTerminalCommand(String command) {
    if (command.trim().isEmpty) return;
    if (command == "clear") {
      setState(() => terminalOutput.clear());
      terminalInput.clear();
      return;
    }
    // Asli command phone ke OS par run ho raha hai
    terminal.executeCommand(command, currentPath);
    terminalInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          IconButton(icon: const Icon(Icons.save, color: Colors.white), tooltip: "Save File", onPressed: _saveCurrentFile),
          IconButton(icon: const Icon(Icons.play_arrow, color: Colors.green), tooltip: "Run App", onPressed: () => _handleTerminalCommand("flutter run")),
          IconButton(icon: const Icon(Icons.build, color: Colors.orange), tooltip: "Build APK", onPressed: () => _handleTerminalCommand("flutter build apk")),
          IconButton(
            // ✅ BUGS FIXED: Changed CupertinoIcons.terminal to Icons.terminal
            icon: Icon(Icons.terminal, color: isTerminalOpen ? Colors.blueAccent : Colors.grey),
            onPressed: () => setState(() => isTerminalOpen = !isTerminalOpen),
          ),
        ],
      ),
      drawer: isWideScreen ? null : Drawer(child: _buildFileManager()),
      body: Row(
        children: [
          if (isWideScreen) SizedBox(width: 250, child: _buildFileManager()),
          if (isWideScreen) const VerticalDivider(width: 1, color: Colors.black),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: const Color(0xFF121212),
                    child: TextField(
                      controller: codeController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 15, color: Colors.white),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.all(16), border: InputBorder.none),
                    ),
                  ),
                ),
                if (isTerminalOpen)
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.black,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: const Color(0xFF202020),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            width: double.infinity,
                            child: const Text("Terminal (sh)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: terminalOutput.length,
                              itemBuilder: (context, index) => Text(terminalOutput[index], style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 13)),
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
                                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
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
                    // ✅ BUGS FIXED: Replaced non-existent CupertinoIcons with standard Icons
                    InkWell(onTap: () => _addNewFile('file'), child: const Icon(Icons.note_add, size: 20)),
                    const SizedBox(width: 12),
                    InkWell(onTap: () => _addNewFile('folder'), child: const Icon(Icons.create_new_folder, size: 20)),
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
                  leading: Icon(file.endsWith('.dart') ? Icons.insert_drive_file : Icons.folder, color: isSelected ? Colors.blueAccent : Colors.grey, size: 20),
                  title: Text(file, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.white, fontSize: 14)),
                  selected: isSelected,
                  selectedTileColor: Colors.white.withOpacity(0.05),
                  onTap: () async {
                    String content = await fileManager.readFile(file);
                    setState(() {
                      selectedFile = file;
                      codeController.text = content;
                    });
                    if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
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
