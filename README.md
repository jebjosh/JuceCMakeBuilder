# DX10 FM Synthesizer

A classic FM synthesizer plugin built with JUCE 8, inspired by the legendary DX series.

## Supported Formats

| Platform | VST3 | AU | Standalone |
|----------|------|-----|------------|
| macOS    | ✓    | ✓   | ✓          |
| Windows  | ✓    | —   | ✓          |
| Linux    | ✓    | —   | ✓          |

macOS builds are Universal Binaries supporting both Intel (x86_64) and Apple Silicon (arm64).

## Prerequisites

- **CMake** 3.22 or later
- **C++17** compatible compiler:
  - macOS: Xcode 12+ or Clang 10+
  - Windows: Visual Studio 2019+ or MSVC 19.20+
  - Linux: GCC 9+ or Clang 10+
- **JUCE 8** (automatically downloaded if not provided)
- **Ninja** (recommended) or Make

### Platform-Specific Requirements

**macOS:**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CMake and Ninja via Homebrew
brew install cmake ninja
```

**Windows:**
```powershell
# Install via winget
winget install Kitware.CMake
winget install Ninja-build.Ninja

# Or use Visual Studio's built-in CMake
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install build-essential cmake ninja-build
sudo apt install libasound2-dev libcurl4-openssl-dev libfreetype6-dev
sudo apt install libx11-dev libxcomposite-dev libxcursor-dev libxext-dev
sudo apt install libxinerama-dev libxrandr-dev libxrender-dev
sudo apt install libwebkit2gtk-4.0-dev libglu1-mesa-dev
```

## Project Structure

```
DX10/
├── CMakeLists.txt         # Main CMake configuration
├── CMakePresets.json      # Build presets for different platforms
├── build.sh               # Build script (macOS/Linux)
├── build.bat              # Build script (Windows)
├── Source/                # Source files
│   ├── PluginProcessor.cpp
│   ├── PluginProcessor.h
│   ├── PluginEditor.cpp
│   ├── PluginEditor.h
│   ├── CustomLookAndFeel.h
│   └── RotaryKnobWithLabel.h
└── JUCE/                  # JUCE framework (optional, auto-downloaded)
```

## Building

### Quick Start

**macOS/Linux:**
```bash
chmod +x build.sh
./build.sh
```

**Windows (Command Prompt):**
```batch
build.bat
```

### Using CMake Presets (Recommended)

The project includes presets for common configurations:

```bash
# List available presets
cmake --list-presets

# macOS Universal Binary (Release)
cmake --preset macos-release
cmake --build --preset macos-release

# Windows Release
cmake --preset windows-release
cmake --build --preset windows-release

# Generate Xcode project (macOS)
cmake --preset macos-xcode-release

# Generate Visual Studio solution (Windows)
cmake --preset windows-vs2022
```

### Manual CMake Build

```bash
# Create build directory
mkdir build && cd build

# Configure (Release by default)
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build . --config Release --parallel

# Or with Ninja (faster)
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release
ninja
```

### Build Options

| Option | Description | Default |
|--------|-------------|---------|
| `CMAKE_BUILD_TYPE` | Build type (Release/Debug) | Release |
| `JUCE_PATH` | Path to JUCE framework | Auto-download |
| `CMAKE_OSX_ARCHITECTURES` | macOS architectures | x86_64;arm64 |
| `CMAKE_OSX_DEPLOYMENT_TARGET` | Minimum macOS version | 10.13 |

Example with custom JUCE path:
```bash
cmake .. -DJUCE_PATH=/path/to/JUCE -DCMAKE_BUILD_TYPE=Release
```

## Build Outputs

After building, plugins are located in:

```
build/DX10_artefacts/Release/
├── VST3/
│   └── DX10.vst3
├── AU/                    # macOS only
│   └── DX10.component
└── Standalone/
    └── DX10.app           # or DX10.exe on Windows
```

## Installing Plugins

### macOS

```bash
# VST3
cp -R build/DX10_artefacts/Release/VST3/DX10.vst3 ~/Library/Audio/Plug-Ins/VST3/

# AU
cp -R build/DX10_artefacts/Release/AU/DX10.component ~/Library/Audio/Plug-Ins/Components/

# Restart your DAW or run:
killall -9 AudioComponentRegistrar
```

### Windows

```powershell
# VST3 (User)
copy build\DX10_artefacts\Release\VST3\DX10.vst3 "$env:LOCALAPPDATA\Programs\Common\VST3\"

# VST3 (System-wide, requires admin)
copy build\DX10_artefacts\Release\VST3\DX10.vst3 "C:\Program Files\Common Files\VST3\"
```

### Linux

```bash
# VST3
cp -R build/DX10_artefacts/Release/VST3/DX10.vst3 ~/.vst3/
```

## Development

### Debug Build

```bash
./build.sh -d        # macOS/Linux
build.bat -d         # Windows
```

### Clean Build

```bash
./build.sh -c        # macOS/Linux
build.bat -c         # Windows
```

### IDE Projects

**Xcode (macOS):**
```bash
./build.sh -x
open build/DX10.xcodeproj
```

**Visual Studio (Windows):**
```batch
build.bat -v
start build\DX10.sln
```

## Troubleshooting

### macOS: "DX10.component" cannot be opened

This is due to Gatekeeper. To fix:
```bash
xattr -cr ~/Library/Audio/Plug-Ins/Components/DX10.component
```

### Windows: CMake can't find compiler

Ensure Visual Studio Build Tools are installed, or run from a Developer Command Prompt.

### Linux: Missing dependencies

Install all required development packages:
```bash
sudo apt install libfreetype6-dev libx11-dev libxcomposite-dev libxcursor-dev
```

### JUCE download fails

Specify a local JUCE installation:
```bash
cmake .. -DJUCE_PATH=/path/to/your/JUCE
```

## License

Copyright (c) 2024 JEbjosh. All rights reserved.

## Credits

- Built with [JUCE](https://juce.com/)
- Inspired by the Yamaha DX series synthesizers
