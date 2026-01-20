# Native Code Architecture

This directory contains shared native code used by both Android and iOS platforms.

## Architecture

```
native/
├── src/
│   ├── iperf3_bridge.c      # Shared C bridge (used by Android & iOS)
│   └── iperf3_bridge.h      # Bridge header
└── iperf3/
    └── src/                  # iperf3 library source files (33 files)
```

## Features

### Optimizations (vs flutter-jni)
- ✅ **Build optimization flags**: `-O3 -ffast-math -funroll-loops`
- ✅ **Block size control**: 8th parameter for packet size customization
- ✅ **Connection timeout**: 5000ms timeout to prevent hanging
- ✅ **iOS gateway detection**: Full `getifaddrs()` implementation

### From flutter-jni
- ✅ **Diagnostic logging**: Extensive post-test diagnostics
- ✅ **3-path error handling**: Detects cancelled, success, server-busy, and failure states
- ✅ **Thread-safe cancellation**: Mutex-protected with proper signal handling
- ✅ **Stream verification**: Logs all streams and interval data

## Platform Integration

### Android
- **Location**: `android/app/src/main/cpp/`
- **Integration**: `CMakeLists.txt` references `${NATIVE_DIR}/src/` and `${NATIVE_DIR}/iperf3/src/`
- **JNI wrapper**: `iperf3_jni.cpp` (platform-specific)

### iOS
- **Location**: `ios/Runner/`
- **Integration**: Symlinks to `../../native/src/` and `../../native/iperf3/src/`
- **Objective-C wrapper**: `Iperf3MethodChannelHandler.m` (platform-specific)

## Building

### Android
The Android build automatically includes the shared native code via CMake:
```cmake
set(NATIVE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../native)
set(IPERF3_SRC_DIR ${NATIVE_DIR}/iperf3/src)
```

### iOS
iOS uses symlinks to reference the shared code:
```bash
ios/Runner/iperf3_bridge.c -> ../../native/src/iperf3_bridge.c
ios/Runner/iperf3_bridge.h -> ../../native/src/iperf3_bridge.h
ios/Runner/iperf3/         -> ../../native/iperf3/src/
```

## Error Handling

The bridge implements 4-path error detection:

1. **User cancelled**: `was_cancelled == true`
2. **True success**: `result_code == 0 && i_errno == 0`
3. **Server busy**: `result_code == 0 && i_errno != 0` (e.g., errno 121)
4. **Actual failure**: `result_code != 0`

## Diagnostic Logging

Post-test diagnostics include:
- Final test state
- Error errno and message
- Stream creation verification
- Bytes sent/received per stream
- Packet counts for UDP
- JSON interval data

## Performance

Optimized build flags provide significant performance improvements:
- **-O3**: Maximum compiler optimization
- **-ffast-math**: Aggressive floating-point optimizations
- **-funroll-loops**: Better CPU pipeline utilization
- **-fomit-frame-pointer**: More available registers

## Maintenance

When updating iperf3 or the bridge:
1. Update files in `/native/src/` or `/native/iperf3/src/`
2. Changes automatically apply to both Android and iOS
3. No platform-specific modifications needed

## Credits

Architecture inspired by [flutter-jni](https://github.com/Dominicpham03/flutter-jni-)
Optimizations and features from ATT-FE-Tool
Best of both worlds! 🚀
