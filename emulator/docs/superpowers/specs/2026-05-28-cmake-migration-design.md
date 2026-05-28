# CMake Migration Design

**Date:** 2026-05-28
**Scope:** Replace `emulator/build.bat` with a cross-platform CMake build system.

---

## Goal

Replace the single-shot `build.bat` (MinGW-only, no incremental builds, hardcoded paths) with a proper CMake setup that works on Windows, Linux, and macOS. All dependencies become external `find_package` dependencies; no vendored libs.

---

## Structure

Two new files, one deletion:

```
emulator/
  CMakeLists.txt           ← main build definition (new)
  cmake/
    FindWinEditLine.cmake  ← custom find module for wineditline (new)
  build.bat                ← deleted
```

### CMakeLists.txt

- `cmake_minimum_required(VERSION 3.15)`
- `project(CasioEmuX CXX)`
- `CMAKE_CXX_STANDARD 20` (was `-std=c++2a`)
- Default `CMAKE_BUILD_TYPE` → `Release`
- Single `casioemu` executable target
- All ~30 `.cpp` sources listed explicitly, including imgui files in `src/Gui/imgui/`

imgui compiles inline as part of the executable — no separate static lib target.

---

## Dependencies

All resolved via `find_package`. Users install dependencies externally (MSYS2/pacman on Windows, apt/brew on Linux/macOS).

| Dependency | CMake call | Linked target |
|---|---|---|
| SDL2 2.x | `find_package(SDL2 REQUIRED)` | `SDL2::SDL2`, `SDL2::SDL2main` |
| SDL2_image 2.x | `find_package(SDL2_image REQUIRED)` | `SDL2_image::SDL2_image` |
| Lua 5.3 | `find_package(Lua 5.3 REQUIRED)` | `${LUA_LIBRARIES}` + `${LUA_INCLUDE_DIR}` |
| editline | platform-conditional (see below) | varies |

### Platform-conditional editline

```cmake
if(WIN32)
    find_package(WinEditLine REQUIRED)
    target_link_libraries(casioemu PRIVATE WinEditLine::WinEditLine)
else()
    find_library(EDITLINE_LIB NAMES edit REQUIRED)
    find_path(EDITLINE_INCLUDE_DIR NAMES editline/readline.h histedit.h)
    target_include_directories(casioemu PRIVATE ${EDITLINE_INCLUDE_DIR})
    target_link_libraries(casioemu PRIVATE ${EDITLINE_LIB})
endif()
```

### FindWinEditLine.cmake

Searches for wineditline's `edit_static` library and include directory. Creates imported target `WinEditLine::WinEditLine`. Standard find module pattern with `find_library` / `find_path` / `find_package_handle_standard_args`.

---

## Compile Flags

Applied via generator expressions so they don't break MSVC:

```cmake
target_compile_options(casioemu PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-pedantic>
    $<$<CXX_COMPILER_ID:MSVC>:/W4>
)
```

---

## Build Usage

Out-of-source build:

```sh
# Configure
cmake -B build -S emulator/ -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build
```

Windows with MSYS2 MinGW:

```sh
cmake -B build -S emulator/ -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

No install target. No test target. Project runs from `emulator/` with `dlls/` alongside the executable (unchanged).

---

## What Gets Deleted

- `emulator/build.bat` — replaced entirely by CMake
- `emulator/libs/` — all vendored libraries removed; users install deps externally
- `emulator/dlls/` — contained `SDL2.dll` / `SDL2_image.dll` for the vendored libs; obsolete after migration. On Windows, users copy DLLs from their SDL2 installation (e.g., MSYS2 `bin/`) next to the built executable.
