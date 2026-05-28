# CMake Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `build.bat` and vendored `libs/` with a cross-platform CMake build system using `find_package` for all dependencies.

**Architecture:** Single `emulator/CMakeLists.txt` defines one `casioemu` executable target. All dependencies (SDL2, SDL2_image, Lua 5.3, editline) are found via `find_package`. A custom `cmake/FindWinEditLine.cmake` handles wineditline on Windows. imgui stays vendored in `src/Gui/imgui/` and compiles inline as part of the executable.

**Tech Stack:** CMake 3.15+, C++20, SDL2 2.x, SDL2_image 2.x, Lua 5.3, wineditline (Windows) / libedit (Linux/macOS)

---

### Task 1: Create cmake/FindWinEditLine.cmake

**Files:**
- Create: `emulator/cmake/FindWinEditLine.cmake`

- [ ] **Step 1: Write the find module**

Create `emulator/cmake/FindWinEditLine.cmake` with this content:

```cmake
# FindWinEditLine.cmake — finds wineditline on Windows
#
# Imported target: WinEditLine::WinEditLine
# Result vars:     WinEditLine_FOUND  WinEditLine_INCLUDE_DIR  WinEditLine_LIBRARY

find_path(WinEditLine_INCLUDE_DIR
    NAMES editline/readline.h
)

find_library(WinEditLine_LIBRARY
    NAMES edit_static edit
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(WinEditLine
    REQUIRED_VARS WinEditLine_LIBRARY WinEditLine_INCLUDE_DIR
)

if(WinEditLine_FOUND AND NOT TARGET WinEditLine::WinEditLine)
    add_library(WinEditLine::WinEditLine UNKNOWN IMPORTED)
    set_target_properties(WinEditLine::WinEditLine PROPERTIES
        IMPORTED_LOCATION "${WinEditLine_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${WinEditLine_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(WinEditLine_INCLUDE_DIR WinEditLine_LIBRARY)
```

- [ ] **Step 2: Commit**

```bash
git add emulator/cmake/FindWinEditLine.cmake
git commit -m "build: add FindWinEditLine CMake module"
```

---

### Task 2: Create CMakeLists.txt

**Files:**
- Create: `emulator/CMakeLists.txt`

- [ ] **Step 1: Write CMakeLists.txt**

Create `emulator/CMakeLists.txt` with this content:

```cmake
cmake_minimum_required(VERSION 3.15)
project(CasioEmuX CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(SOURCES
    src/casioemu.cpp
    src/Emulator.cpp
    src/Logger.cpp
    src/Chipset/CPU.cpp
    src/Chipset/CPUArithmetic.cpp
    src/Chipset/CPUControl.cpp
    src/Chipset/CPULoadStore.cpp
    src/Chipset/CPUPushPop.cpp
    src/Chipset/Chipset.cpp
    src/Chipset/Coprocessor.cpp
    src/Chipset/InterruptSource.cpp
    src/Chipset/MMU.cpp
    src/Chipset/MMURegion.cpp
    src/Data/ModelInfo.cpp
    src/Peripheral/BCDCalc.cpp
    src/Peripheral/BatteryBackedRAM.cpp
    src/Peripheral/ExternalInterrupts.cpp
    src/Peripheral/Flash.cpp
    src/Peripheral/IOPorts.cpp
    src/Peripheral/Keyboard.cpp
    src/Peripheral/Miscellaneous.cpp
    src/Peripheral/Peripheral.cpp
    src/Peripheral/PowerSupply.cpp
    src/Peripheral/ROMWindow.cpp
    src/Peripheral/RealTimeClock.cpp
    src/Peripheral/Screen.cpp
    src/Peripheral/StandbyControl.cpp
    src/Peripheral/Timer.cpp
    src/Peripheral/TimerBaseCounter.cpp
    src/Peripheral/WatchdogTimer.cpp
    src/Gui/CodeViewer.cpp
    src/Gui/Command.cpp
    src/Gui/imgui/imgui.cpp
    src/Gui/imgui/imgui_draw.cpp
    src/Gui/imgui/imgui_impl_sdl2.cpp
    src/Gui/imgui/imgui_impl_sdlrenderer2.cpp
    src/Gui/imgui/imgui_tables.cpp
    src/Gui/imgui/imgui_widgets.cpp
)

add_executable(casioemu ${SOURCES})

target_compile_options(casioemu PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-pedantic>
    $<$<CXX_COMPILER_ID:MSVC>:/W4>
)

find_package(SDL2 REQUIRED)
find_package(SDL2_image REQUIRED)
find_package(Lua 5.3 REQUIRED)

target_include_directories(casioemu PRIVATE
    ${LUA_INCLUDE_DIR}
)

target_link_libraries(casioemu PRIVATE
    SDL2::SDL2
    SDL2::SDL2main
    SDL2_image::SDL2_image
    ${LUA_LIBRARIES}
)

if(WIN32)
    find_package(WinEditLine REQUIRED)
    target_link_libraries(casioemu PRIVATE WinEditLine::WinEditLine)
else()
    find_library(EDITLINE_LIB NAMES edit REQUIRED)
    find_path(EDITLINE_INCLUDE_DIR NAMES editline/readline.h histedit.h)
    if(EDITLINE_INCLUDE_DIR)
        target_include_directories(casioemu PRIVATE ${EDITLINE_INCLUDE_DIR})
    endif()
    target_link_libraries(casioemu PRIVATE ${EDITLINE_LIB})
endif()
```

- [ ] **Step 2: Commit**

```bash
git add emulator/CMakeLists.txt
git commit -m "build: add CMakeLists.txt"
```

---

### Task 3: Install prerequisites and verify configure

No code changes in this task — just verifying the configure step succeeds before touching the old build system.

**Install deps first (once per machine):**

Windows (MSYS2 MinGW64 shell):
```bash
pacman -S mingw-w64-x86_64-cmake \
          mingw-w64-x86_64-SDL2 \
          mingw-w64-x86_64-SDL2_image \
          mingw-w64-x86_64-lua53 \
          mingw-w64-x86_64-wineditline
```

Linux (Ubuntu/Debian):
```bash
sudo apt install cmake libsdl2-dev libsdl2-image-dev liblua5.3-dev libedit-dev
```

macOS (Homebrew):
```bash
brew install cmake sdl2 sdl2_image lua@5.3 libedit
```

- [ ] **Step 1: Run configure from the `emulator/` directory**

On Windows, run this from the MSYS2 MinGW64 shell (not CMD or PowerShell):
```bash
cmake -B build -S . -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
```

On Linux/macOS:
```bash
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
```

- [ ] **Step 2: Verify output shows all packages found**

Expected lines in output (exact paths vary by platform):
```
-- Found SDL2: .../SDL2Config.cmake
-- Found SDL2_image: ...
-- Found Lua: ...
-- Found WinEditLine: ...   (Windows only)
-- Configuring done
-- Build files have been written to: .../emulator/build
```

If `Could NOT find SDL2` appears: you are not in the MSYS2 MinGW64 shell, or the package was not installed. Do not continue until configure is clean.

---

### Task 4: Verify build

- [ ] **Step 1: Build**

```bash
cmake --build build
```

Expected final lines:
```
[100%] Linking CXX executable casioemu.exe
[100%] Built target casioemu
```

- [ ] **Step 2: Run the executable to confirm it starts**

```bash
./build/casioemu.exe
```

Expected: emulator launches or prints usage. If you get a "DLL not found" error, copy the SDL2 DLLs from your MSYS2 installation next to the executable:
```bash
cp /mingw64/bin/SDL2.dll /mingw64/bin/SDL2_image.dll build/
```

Then re-run `./build/casioemu.exe`.

---

### Task 5: Remove build.bat, libs/, dlls/

Only do this after Task 4 passes.

**Files:**
- Delete: `emulator/build.bat`
- Delete: `emulator/libs/` (entire directory)
- Delete: `emulator/dlls/` (entire directory)

- [ ] **Step 1: Stage deletions**

```bash
git rm emulator/build.bat
git rm -r emulator/libs/
git rm -r emulator/dlls/
```

- [ ] **Step 2: Commit**

```bash
git commit -m "build: remove build.bat, vendored libs, and vendored dlls"
```

---

### Task 6: Update README.md

**Files:**
- Modify: `emulator/README.md`

- [ ] **Step 1: Replace README content**

Replace the entire contents of `emulator/README.md` with:

```markdown
# Emulator

## Prerequisites

**Windows (MSYS2 MinGW64 shell):**
```bash
pacman -S mingw-w64-x86_64-cmake \
          mingw-w64-x86_64-SDL2 \
          mingw-w64-x86_64-SDL2_image \
          mingw-w64-x86_64-lua53 \
          mingw-w64-x86_64-wineditline
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt install cmake libsdl2-dev libsdl2-image-dev liblua5.3-dev libedit-dev
```

**macOS (Homebrew):**
```bash
brew install cmake sdl2 sdl2_image lua@5.3 libedit
```

## Build

```bash
cmake -B build -S .
cmake --build build
```

On Windows, run these commands from the MSYS2 MinGW64 shell and add `-G "MinGW Makefiles"`:
```bash
cmake -B build -S . -G "MinGW Makefiles"
cmake --build build
```

The built executable is `build/casioemu.exe` (Windows) or `build/casioemu` (Linux/macOS).

On Windows, copy the SDL2 DLLs next to the executable before running it:
```bash
cp /mingw64/bin/SDL2.dll /mingw64/bin/SDL2_image.dll build/
```

## Notes

The memory editor is modified so SFRs are accessible.
Edit `src/Gui/Command.cpp` to change the range of the memory editor.
```

- [ ] **Step 2: Commit**

```bash
git add emulator/README.md
git commit -m "docs: update README with CMake build instructions"
```
