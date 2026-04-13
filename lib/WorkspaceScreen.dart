import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ==========================================
// 1. C++ NATIVE ENGINE (FFI BRIDGE)
// ==========================================
typedef ExecuteNativeCommandC = Pointer<Utf8> Function(Pointer<Utf8> command);
typedef ExecuteNativeCommandDart = Pointer<Utf8> Function(Pointer<Utf8> command);

class NativeEngine {
  late DynamicLibrary _lib;
  late ExecuteNativeCommandDart _executeNativeCommand;
  bool isInitialized = false;

  NativeEngine() {
    try {
      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libnative_engine.so');
        _executeNativeCommand = _lib
            .lookup<NativeFunction<ExecuteNativeCommandC>>('execute_native_command')
            .asFunction();
        isInitialized = true;
      }
    } catch (e) {
      print("Native Engine Load Error: \$e");
      // App crash hone se bachane ke liye catch kiya gaya hai
    }
  }

  String runCommand(String command) {
    if (!isInitialized) return "Error: C++ Engine (.so) is not loaded or compiled.";
    
    // Dart String ko C++ Pointer me convert karna
    final cmdPointer = command.toNativeUtf8();
    
    // C++ function call karna
    final resultPointer = _executeNativeCommand(cmdPointer);
    
    // Pointer se wapas Dart String banana
    final result = resultPointer.toDartString();
    
    // Memory leak rokne ke liye pointer free karna
    malloc.free(cmdPointer);
    
    return result;
  }
}


// ==========================================
// 2. UPDATED WORKSPACE SCREEN WITH TERMINAL
// ==========================================
class WorkspaceScreen extends StatefulWidget {
  final String projectName;
  const WorkspaceScreen({Key? key, required this.projectName}) : super(key: key);

  @override
  _WorkspaceScreenState createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  // UI States
  TextEditingController codeController = TextEditingController();
  List<String> terminalOutput = [];
  TextEditingController terminalInput = TextEditingController();
  bool isTerminalOpen = true;

  // ✅ State ke andar NativeEngine variable initialize kiya
  final NativeEngine _nativeEngine = NativeEngine();

  @override
  void initState() {
    super.initState();
    terminalOutput.add("Welcome to ProIDE Terminal.");
    if (_nativeEngine.isInitialized) {
      terminalOutput.add("✅ C++ Native Engine Loaded Successfully!");
    } else {
      terminalOutput.add("⚠️ Warning: C++ Engine not loaded. Did you run CMake build?");
    }
  }

  // ✅ Terminal command function updated with C++ connection
  void _handleTerminalCommand(String command) {
    if (command.trim().isEmpty) return;
    
    if (command == "clear") {
      setState(() {
        terminalOutput.clear();
      });
      terminalInput.clear();
      return;
    }

    // Command UI pe dikhayein
    setState(() {
      terminalOutput.add('\$ $command');
    });

    // C++ engine ko command bhejein aur wait karein
    String nativeResult = _nativeEngine.runCommand(command);
    
    // Result wapas aane par Terminal output me add karein
    setState(() {
      terminalOutput.add('> C++ Response: $nativeResult');
    });

    terminalInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          IconButton(
            icon: Icon(Icons.terminal, color: isTerminalOpen ? Colors.blueAccent : Colors.grey),
            onPressed: () => setState(() => isTerminalOpen = !isTerminalOpen),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Code Editor Area
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
                  hintText: "Write your code here...",
                  hintStyle: TextStyle(color: Colors.white38)
                ),
              ),
            ),
          ),
          
          // 2. Terminal Area
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
                      child: const Text("Terminal (Native C++)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: terminalOutput.length,
                        itemBuilder: (context, index) => Text(
                          terminalOutput[index], 
                          style: TextStyle(
                            color: terminalOutput[index].startsWith('\$') ? Colors.white : Colors.greenAccent, 
                            fontFamily: 'monospace', 
                            fontSize: 13
                          )
                        ),
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
    );
  }
}
