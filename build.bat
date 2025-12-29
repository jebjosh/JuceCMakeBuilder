@echo off
REM =============================================================================
REM DX10 Build Script for Windows
REM =============================================================================

setlocal enabledelayedexpansion

set BUILD_DIR=build
set BUILD_TYPE=Release
set JUCE_PATH=
set CMAKE_GENERATOR=
set CLEAN_BUILD=0
set CONFIGURE_ONLY=0

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :main
if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--help" goto :show_help
if /i "%~1"=="-c" (
    set CLEAN_BUILD=1
    shift
    goto :parse_args
)
if /i "%~1"=="--clean" (
    set CLEAN_BUILD=1
    shift
    goto :parse_args
)
if /i "%~1"=="-d" (
    set BUILD_TYPE=Debug
    shift
    goto :parse_args
)
if /i "%~1"=="--debug" (
    set BUILD_TYPE=Debug
    shift
    goto :parse_args
)
if /i "%~1"=="-j" (
    set JUCE_PATH=%~2
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--juce" (
    set JUCE_PATH=%~2
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-v" (
    set CMAKE_GENERATOR=Visual Studio 17 2022
    shift
    goto :parse_args
)
if /i "%~1"=="--vs" (
    set CMAKE_GENERATOR=Visual Studio 17 2022
    shift
    goto :parse_args
)
if /i "%~1"=="--configure-only" (
    set CONFIGURE_ONLY=1
    shift
    goto :parse_args
)
echo Unknown option: %~1
goto :show_help

:show_help
echo.
echo ==========================================
echo   DX10 FM Synthesizer - Windows Build
echo ==========================================
echo.
echo Usage: build.bat [options]
echo.
echo Options:
echo   -h, --help          Show this help message
echo   -c, --clean         Clean build directory before building
echo   -d, --debug         Build in Debug mode (default: Release)
echo   -j, --juce PATH     Specify path to JUCE framework
echo   -v, --vs            Generate Visual Studio 2022 solution
echo   --configure-only    Only configure, don't build
echo.
echo Examples:
echo   build.bat                    Standard release build
echo   build.bat -c                 Clean build
echo   build.bat -d                 Debug build
echo   build.bat -j C:\JUCE         Use JUCE from C:\JUCE
echo   build.bat -v                 Generate VS2022 solution
echo.
exit /b 0

:main
echo.
echo ==========================================
echo   DX10 FM Synthesizer - Windows Build
echo ==========================================
echo.

REM Clean if requested
if %CLEAN_BUILD%==1 (
    echo [INFO] Cleaning build directory...
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
    echo [OK] Build directory cleaned
)

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM Prepare CMake arguments
set CMAKE_ARGS=-DCMAKE_BUILD_TYPE=%BUILD_TYPE%

if not "%JUCE_PATH%"=="" (
    set CMAKE_ARGS=%CMAKE_ARGS% -DJUCE_PATH=%JUCE_PATH%
)

REM Configure
echo [INFO] Configuring CMake (%BUILD_TYPE%)...
cd "%BUILD_DIR%"

if not "%CMAKE_GENERATOR%"=="" (
    cmake .. %CMAKE_ARGS% -G "%CMAKE_GENERATOR%"
) else (
    cmake .. %CMAKE_ARGS%
)

if errorlevel 1 (
    echo [ERROR] CMake configuration failed!
    exit /b 1
)

echo [OK] CMake configuration complete

if %CONFIGURE_ONLY%==1 (
    echo [INFO] Configuration only - skipping build
    exit /b 0
)

REM Build
echo [INFO] Building DX10...
cmake --build . --config %BUILD_TYPE% --parallel

if errorlevel 1 (
    echo [ERROR] Build failed!
    exit /b 1
)

echo.
echo [OK] Build complete!
echo.
echo Build outputs:
echo   VST3:       %BUILD_DIR%\DX10_artefacts\%BUILD_TYPE%\VST3\DX10.vst3
echo   Standalone: %BUILD_DIR%\DX10_artefacts\%BUILD_TYPE%\Standalone\DX10.exe
echo.

cd ..
exit /b 0
