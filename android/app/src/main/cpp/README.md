# iperf3 Native Library Setup

This directory contains the JNI bridge code for integrating iperf3 into the Android app.

## Current Status

⚠️ **The native iperf3 library is NOT currently enabled in the build.**

The CMake build configuration is commented out in `android/app/build.gradle.kts` to allow the app to compile without the native library.

## To Enable iperf3 Support

### Step 1: Download and Set Up iperf3 Source

Run the setup script to download iperf3 source code:

```bash
cd /Users/dominicpham/rgnets/ATT-FE-Tool/android/app/src/main/cpp
chmod +x setup_iperf3.sh
./setup_iperf3.sh
```

This will:
- Download iperf3 v3.19 source code
- Extract it to `iperf3/` directory
- Create necessary Android configuration files

### Step 2: Create Required Directory Structure

The build expects files in a `native/` directory at the project root:

```bash
cd /Users/dominicpham/rgnets/ATT-FE-Tool
mkdir -p native/iperf3
mkdir -p native/src
```

### Step 3: Copy iperf3 Files

Copy the downloaded iperf3 source to the expected location:

```bash
cp -r android/app/src/main/cpp/iperf3/* native/iperf3/
```

### Step 4: Create Bridge Implementation

You need to create `native/src/iperf3_bridge.c` and `native/src/iperf3_bridge.h` files.

These files should contain the platform-agnostic C bridge code that wraps iperf3 functionality.

### Step 5: Uncomment Build Configuration

Edit `android/app/build.gradle.kts` and uncomment the following sections:

1. In `defaultConfig`:
```kotlin
externalNativeBuild {
    cmake {
        cppFlags += "-std=c++14"
        arguments += listOf(
            "-DANDROID_STL=c++_shared"
        )
    }
}

ndk {
    abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86", "x86_64")
}
```

2. At the end of the `android` block:
```kotlin
externalNativeBuild {
    cmake {
        path = file("src/main/cpp/CMakeLists.txt")
        version = "3.22.1"
    }
}
```

### Step 6: Build the App

```bash
flutter clean
flutter build apk --debug
```

## Files in This Directory

- **CMakeLists.txt** - CMake build configuration for native library
- **iperf3_jni.cpp** - JNI wrapper that connects Kotlin/Java to native iperf3
- **setup_iperf3.sh** - Script to download and configure iperf3 source
- **README.md** - This file

## Alternative: Use Without Native Library

The Flutter/Dart code is ready to use, but without the native library, calls to iperf3 will fail.

You can:
1. Use the app with the iperf3 UI disabled
2. Connect to an external iperf3 server over the network (when implemented)

## Notes

- The `native/` directory is added to `.gitignore` to avoid committing large source files
- iperf3 source code is downloaded from the official GitHub repository
- The implementation supports both TCP and UDP protocols
- Real-time progress callbacks are supported via EventChannel
