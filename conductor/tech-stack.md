# Technology Stack: CCExtractor

## 1. Programming Languages
- **C (Primary):** The core engine and legacy modules are written in C (C99/GNU99).
- **Rust (Strategic):** Used for selected safety-critical components and as an experimental target for incremental migration.
- **C++:** Utilized in specific modules and for certain dependency integrations.
- **Python:** Used for auxiliary tools, build scripts, and test automation.

## 2. Build & Dependency Management
- **CMake:** A supported cross-platform build system, particularly for modern and Windows-oriented builds.
- **Autotools (GNU Make/Autoconf):** Supported for traditional Unix-like environments.
- **MSVC Toolchain:** Supported compiler environment for native Windows builds.
- **Vcpkg:** Used primarily for managing third-party C/C++ dependencies, especially on Windows.
- **Cargo:** Manages Rust dependencies and the `ccx_rust` library build.

## 3. Core Libraries & Frameworks
- **Media Processing:** FFmpeg (demuxing/decoding), GPAC (ISO/MP4 handling).
- **Caption Handling:** ZVBI (Teletext/DVB decoding), lib_ccx (Internal core logic).
- **OCR Engine:** Tesseract and Leptonica for extracting burned-in subtitles.
- **System Utilities:** Freetype (font rendering), Zlib (compression), Libpng, Utf8proc (Unicode handling), Libcurl (network transfers).

## 4. Architecture & Integration
- **Hybrid C/Rust Architecture:** Rust components are compiled into a static library (`ccx_rust`) and linked into the C codebase via a well-defined Foreign Function Interface (FFI) boundary.
- **Modular Library (lib_ccx):** Core extraction logic is encapsulated in `lib_ccx` to enable reuse and support structured refactoring and migration.
