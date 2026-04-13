# Minimum CMake version required
cmake_minimum_required(VERSION 3.4.1)

# Humari C++ library ka naam 'native_engine' hoga
add_library(
        native_engine
        SHARED
        native_engine.cpp)

# Android ke logcat me C++ errors dekhne ke liye log library link karein
find_library(
        log-lib
        log)

target_link_libraries(
        native_engine
        ${log-lib})
