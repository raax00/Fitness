import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// C++ ke function ka signature
typedef ExecuteNativeCommandC = Pointer<Utf8> Function(Pointer<Utf8> command);
// Dart me us function ka signature
typedef ExecuteNativeCommandDart = Pointer<Utf8> Function(Pointer<Utf8> command);

class NativeEngine {
  late DynamicLibrary _lib;
  late ExecuteNativeCommandDart _executeNativeCommand;

  NativeEngine() {
    // Android par '.so' (Shared Object) library load karein
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libnative_engine.so');
    } else {
      throw UnsupportedError('Yeh engine sirf Android ke liye hai');
    }

    // C++ function ko Dart se connect karein
    _executeNativeCommand = _lib
        .lookup<NativeFunction<ExecuteNativeCommandC>>('execute_native_command')
        .asFunction();
  }

  // UI se call karne wala clean function
  String runCommand(String command) {
    // String ko C++ format me convert karein
    final cmdPointer = command.toNativeUtf8();
    
    // C++ function call karein
    final resultPointer = _executeNativeCommand(cmdPointer);
    
    // Memory free karein aur result string me convert karein
    final result = resultPointer.toDartString();
    malloc.free(cmdPointer);
    
    return result;
  }
}
