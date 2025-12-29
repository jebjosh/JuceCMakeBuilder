#!/bin/bash

# =============================================================================
# DX10 Build Script
# Cross-platform build helper for macOS, Windows (via Git Bash/MSYS2), and Linux
# =============================================================================

set -e

# Configuration
BUILD_DIR="build"
BUILD_TYPE="Release"
JUCE_PATH=""
ALWAYS_CLEAN=true  # Always clean build directory

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "  DX10 FM Synthesizer - Build Script"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

show_help() {
    echo "Usage: ./build.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -c, --clean         Clean build directory before building"
    echo "  -d, --debug         Build in Debug mode (default: Release)"
    echo "  -j, --juce PATH     Specify path to JUCE framework"
    echo "  -g, --generator GEN Specify CMake generator"
    echo "  -x, --xcode         Generate Xcode project (macOS only)"
    echo "  -v, --vs            Generate Visual Studio solution (Windows only)"
    echo "  --configure-only    Only configure, don't build"
    echo ""
    echo "Examples:"
    echo "  ./build.sh                    # Standard release build"
    echo "  ./build.sh -c                 # Clean build"
    echo "  ./build.sh -d                 # Debug build"
    echo "  ./build.sh -j ~/JUCE          # Use JUCE from ~/JUCE"
    echo "  ./build.sh -x                 # Generate Xcode project"
    echo ""
}

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    PLATFORM="macOS" ;;
        Linux*)     PLATFORM="Linux" ;;
        CYGWIN*|MINGW*|MSYS*) PLATFORM="Windows" ;;
        *)          PLATFORM="Unknown" ;;
    esac
    print_info "Detected platform: $PLATFORM"
}

# Parse command line arguments
CLEAN_BUILD=false
CONFIGURE_ONLY=false
CMAKE_GENERATOR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -d|--debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        -j|--juce)
            JUCE_PATH="$2"
            shift 2
            ;;
        -g|--generator)
            CMAKE_GENERATOR="$2"
            shift 2
            ;;
        -x|--xcode)
            CMAKE_GENERATOR="Xcode"
            shift
            ;;
        -v|--vs)
            CMAKE_GENERATOR="Visual Studio 17 2022"
            shift
            ;;
        --configure-only)
            CONFIGURE_ONLY=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main build process
main() {
    print_header
    detect_platform
    
    # Always clean the build directory
    print_info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    print_success "Build directory cleaned"
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    
    # Prepare CMake arguments
    CMAKE_ARGS="-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
    
    if [ -n "$JUCE_PATH" ]; then
        CMAKE_ARGS="$CMAKE_ARGS -DJUCE_PATH=$JUCE_PATH"
    fi
    
    if [ -n "$CMAKE_GENERATOR" ]; then
        CMAKE_ARGS="$CMAKE_ARGS -G \"$CMAKE_GENERATOR\""
    fi
    
    # Configure
    print_info "Configuring CMake ($BUILD_TYPE)..."
    cd "$BUILD_DIR"
    
    if [ -n "$CMAKE_GENERATOR" ]; then
        eval cmake .. $CMAKE_ARGS -G "$CMAKE_GENERATOR"
    else
        eval cmake .. $CMAKE_ARGS
    fi
    
    print_success "CMake configuration complete"
    
    if [ "$CONFIGURE_ONLY" = true ]; then
        print_info "Configuration only - skipping build"
        exit 0
    fi
    
    # Build
    print_info "Building DX10..."
    
    # Determine number of parallel jobs
    if [ "$PLATFORM" = "macOS" ]; then
        JOBS=$(sysctl -n hw.ncpu)
    elif [ "$PLATFORM" = "Linux" ]; then
        JOBS=$(nproc)
    else
        JOBS=4
    fi
    
    cmake --build . --config "$BUILD_TYPE" --parallel "$JOBS"
    
    print_success "Build complete!"
    
    # Print output locations
    echo ""
    print_info "Build outputs:"
    
    if [ "$PLATFORM" = "macOS" ]; then
        echo "  VST3:       $BUILD_DIR/DX10_artefacts/$BUILD_TYPE/VST3/DX10.vst3"
        echo "  AU:         $BUILD_DIR/DX10_artefacts/$BUILD_TYPE/AU/DX10.component"
        echo "  Standalone: $BUILD_DIR/DX10_artefacts/$BUILD_TYPE/Standalone/DX10.app"
    elif [ "$PLATFORM" = "Windows" ]; then
        echo "  VST3:       $BUILD_DIR/DX10_artefacts/$BUILD_TYPE/VST3/DX10.vst3"
        echo "  Standalone: $BUILD_DIR/DX10_artefacts/$BUILD_TYPE/Standalone/DX10.exe"
    else
        echo "  VST3:       $BUILD_DIR/DX10_artefacts/$BUILD_TYPE/VST3/DX10.vst3"
        echo "  Standalone: $BUILD_DIR/DX10_artefacts/$BUILD_TYPE/Standalone/DX10"
    fi
    
    echo ""
}

main
