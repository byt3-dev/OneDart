import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

/// Load kernel32.dll
final ffi.DynamicLibrary _kernel32 = ffi.DynamicLibrary.open('kernel32.dll');

/// FFI typedefs
typedef _BeginUpdateResourceWNative = ffi.IntPtr Function(
  ffi.Pointer<ffi.Uint16>, // LPWSTR
  ffi.Int32,
);
typedef _BeginUpdateResourceWDart = int Function(
  ffi.Pointer<ffi.Uint16>,
  int,
);

typedef _UpdateResourceWNative = ffi.Int32 Function(
  ffi.IntPtr,
  ffi.Pointer<ffi.Uint16>, // type
  ffi.Pointer<ffi.Uint16>, // name
  ffi.Uint16,
  ffi.Pointer<ffi.Void>,
  ffi.Uint32,
);
typedef _UpdateResourceWDart = int Function(
  int,
  ffi.Pointer<ffi.Uint16>,
  ffi.Pointer<ffi.Uint16>,
  int,
  ffi.Pointer<ffi.Void>,
  int,
);

typedef _EndUpdateResourceWNative = ffi.Int32 Function(
  ffi.IntPtr,
  ffi.Int32,
);
typedef _EndUpdateResourceWDart = int Function(
  int,
  int,
);

/// Bind kernel32 functions
final _beginUpdateResourceW = _kernel32.lookupFunction<
    _BeginUpdateResourceWNative,
    _BeginUpdateResourceWDart>('BeginUpdateResourceW');

final _updateResourceW = _kernel32.lookupFunction<
    _UpdateResourceWNative,
    _UpdateResourceWDart>('UpdateResourceW');

final _endUpdateResourceW = _kernel32.lookupFunction<
    _EndUpdateResourceWNative,
    _EndUpdateResourceWDart>('EndUpdateResourceW');

class IcoEmbed {
  static Future<void> embed({
    required String exePath,
    required String iconPath,
  }) async {
    if (!Platform.isWindows) return;

    final iconFile = File(iconPath);
    if (!iconFile.existsSync()) {
      throw Exception('Icon not found: $iconPath');
    }

    final iconData = iconFile.readAsBytesSync();

    // Convert path to UTF-16
    final exePtr = exePath.toNativeUtf16().cast<ffi.Uint16>();

    // Open EXE for resource editing
    final hUpdate = _beginUpdateResourceW(exePtr, 0);
    if (hUpdate == 0) {
      calloc.free(exePtr);
      throw Exception('Failed to open EXE for patching');
    }

    // Allocate unmanaged memory for icon bytes
    final lpData = calloc<ffi.Uint8>(iconData.length);
    lpData.asTypedList(iconData.length).setAll(0, iconData);

    // Use string resource type/name ("3" = RT_ICON, "1" = ID)
    final typePtr = '3'.toNativeUtf16().cast<ffi.Uint16>();
    final namePtr = '1'.toNativeUtf16().cast<ffi.Uint16>();

    try {
      final result = _updateResourceW(
        hUpdate,
        typePtr,
        namePtr,
        0, // language neutral
        lpData.cast<ffi.Void>(),
        iconData.length,
      );

      if (result == 0) {
        throw Exception('Failed to write icon resource');
      }

      final endResult = _endUpdateResourceW(hUpdate, 0);
      if (endResult == 0) {
        throw Exception('Failed to commit icon resource');
      }

      print('✅ Custom Resource Hacker: Icon injected successfully!');
} finally {
  calloc.free(lpData);
  calloc.free(exePtr);
  calloc.free(typePtr);
  calloc.free(namePtr);
}
  }
}
