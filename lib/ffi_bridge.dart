import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

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
    }
  }

  String runCommand(String command) {
    if (!isInitialized) return "Error: C++ Engine (.so) is not loaded.";
    final cmdPointer = command.toNativeUtf8();
    final resultPointer = _executeNativeCommand(cmdPointer);
    final result = resultPointer.toDartString();
    malloc.free(cmdPointer);
    return result;
  }
}
