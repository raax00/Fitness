#include <stdint.h>
#include <string>
#include <stdlib.h>

// "C" linkage zaroori hai taaki Dart isko pehchan sake
extern "C" {

    // Yeh function Dart se call hoga
    __attribute__((visibility("default"))) __attribute__((used))
    const char* execute_native_command(const char* command) {
        
        // Asli shell me command execute karna (System level)
        // Note: Future me aap yaha 'proot' ka source code integrate karenge
        std::string result = "Native Execution Started for: ";
        result += command;
        
        // System command execute (For testing)
        // int status = system(command); 
        
        // Dart ko result wapas bhejna
        char *res = (char *)malloc(result.size() + 1);
        memcpy(res, result.c_str(), result.size() + 1);
        return res;
    }

}
