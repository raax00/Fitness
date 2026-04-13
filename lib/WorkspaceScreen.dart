import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'ffi_bridge.dart';

// --- BACKEND ENGINES ---
class RealFileManager {
  late Directory projectRoot;

  Future<void> initProject(String projectName) async {
    final directory = await getApplicationDocumentsDirectory();
    projectRoot = Directory('${directory.path}/$projectName');
    if (!await projectRoot.exists()) {
      await projectRoot.create(recursive: true);
      await Directory('${projectRoot.path}/lib').create(recursive: true);
      await File('${projectRoot.path}/lib/main.dart').writeAsString(
        "import 'package:flutter/material.dart';\n\nvoid main() => runApp(MyApp());\n"
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

// --- UI SCREEN ---
class WorkspaceScreen extends StatefulWidget {
  final String projectName;
  const WorkspaceScreen({Key? key, required this.projectName}) : super(key: key);

  @override
  _WorkspaceScreenState createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final RealFileManager fileManager = RealFileManager();
  final NativeEngine _nativeEngine = NativeEngine();
  
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
    terminalOutput.add("Welcome to ProIDE Terminal.");
    if (_nativeEngine.isInitialized) {
      terminalOutput.add("✅ C++ Native Engine Loaded!");
    } else {
      terminalOutput.add("⚠️ C++ Engine not loaded (Waiting for CMake build).");
    }
    _initProjectData();
  }

  Future<void> _initProjectData() async {
    await fileManager.initProject(widget.projectName);
    String mainCode = await fileManager.readFile('lib/main.dart');
    setState(() {
      currentPath = fileManager.projectRoot.path;
      codeController.text = mainCode;
      terminalOutput.add("Project initialized at $currentPath");
    });
  }

  void _handleTerminalCommand(String command) {
    if (command.trim().isEmpty) return;
    if (command == "clear") {
      setState(() => terminalOutput.clear());
      terminalInput.clear();
      return;
    }

    setState(() => terminalOutput.add('\$ $command'));
    String nativeResult = _nativeEngine.runCommand(command);
    setState(() => terminalOutput.add('> C++ Response: $nativeResult'));
    terminalInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: () => fileManager.saveFile(selectedFile, codeController.text)),
          IconButton(icon: const Icon(Icons.play_arrow, color: Colors.green), onPressed: () => _handleTerminalCommand("flutter run")),
          // ✅ BUGS FIXED: Yaha se 'const' hata diya gaya hai
          IconButton(icon: Icon(Icons.terminal, color: isTerminalOpen ? Colors.blueAccent : Colors.grey), onPressed: () => setState(() => isTerminalOpen = !isTerminalOpen)),
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
                        children: [
                          Container(
                            color: const Color(0xFF202020),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            width: double.infinity,
                            child: const Text("Terminal", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
            child: const Text("PROJECT FILES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: projectFiles.length,
              itemBuilder: (context, index) {
                String file = projectFiles[index];
                bool isSelected = selectedFile == file;
                return ListTile(
                  dense: true,
                  leading: Icon(file.endsWith('.dart') ? Icons.insert_drive_file : Icons.settings, color: isSelected ? Colors.blueAccent : Colors.grey, size: 20),
                  title: Text(file, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.white, fontSize: 14)),
                  selected: isSelected,
                  selectedTileColor: Colors.white.withOpacity(0.05),
                  onTap: () async {
                    String content = await fileManager.readFile(file);
                    setState(() { selectedFile = file; codeController.text = content; });
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
