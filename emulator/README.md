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
