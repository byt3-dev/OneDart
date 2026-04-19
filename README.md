# 🧭 OneDart

**Compile Dart to a standalone EXE — fast, simple, and native.**

OneDart is a lightweight Dart‑to‑native compiler that transforms your `.dart` files into portable Windows executables.  
It’s designed for developers who want to ship Dart apps without requiring the Dart SDK or runtime.

---

## 🚀 Features

- **Icon embedding** — add `.ico` files directly to your binary  
- **Cross‑compilation** — build for Linux from Windows (experimental)  
- **Fast builds** — minimal overhead, instant startup  
- **Self‑hosting** — OneDart can compile itself  

---

## ⚙️ Usage

```bash
onedart your_dart_file.dart -o your_dart_file.exe -i path_to_icon
