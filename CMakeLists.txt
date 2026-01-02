cmake_minimum_required(VERSION 3.22)

# Project name and version
project(DX10
    VERSION 2.0.0
    DESCRIPTION "DX10 FM Synthesizer"
    LANGUAGES C CXX
)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Default to Release build if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# macOS: Build Universal Binary (Intel x86_64 + Apple Silicon arm64)
if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "Build architectures for macOS" FORCE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum macOS deployment version" FORCE)
endif()

# =============================================================================
# JUCE Configuration
# =============================================================================

# Option to specify JUCE path (can be overridden via -DJUCE_PATH=/path/to/JUCE)
set(JUCE_PATH "" CACHE PATH "Path to JUCE framework")

# Set platform-specific default JUCE paths
if(APPLE)
    set(DEFAULT_JUCE_PATH "/Applications/JUCE")
elseif(WIN32)
    set(DEFAULT_JUCE_PATH "C:/JUCE")
else()
    set(DEFAULT_JUCE_PATH "")
endif()

# Try to find JUCE
if(JUCE_PATH AND EXISTS "${JUCE_PATH}")
    # Use user-specified JUCE path
    message(STATUS "Using user-specified JUCE path: ${JUCE_PATH}")
    add_subdirectory(${JUCE_PATH} ${CMAKE_BINARY_DIR}/JUCE)
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/JUCE")
    # JUCE folder in project root
    message(STATUS "Using JUCE from project root: ${CMAKE_CURRENT_SOURCE_DIR}/JUCE")
    add_subdirectory(JUCE)
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/libs/JUCE")
    # JUCE in libs folder
    message(STATUS "Using JUCE from libs folder: ${CMAKE_CURRENT_SOURCE_DIR}/libs/JUCE")
    add_subdirectory(libs/JUCE)
elseif(EXISTS "${DEFAULT_JUCE_PATH}")
    # Use platform-specific default path
    message(STATUS "Using default JUCE path: ${DEFAULT_JUCE_PATH}")
    add_subdirectory(${DEFAULT_JUCE_PATH} ${CMAKE_BINARY_DIR}/JUCE)
else()
    # Fetch JUCE from GitHub (JUCE 8)
    message(STATUS "JUCE not found locally, downloading from GitHub...")
    include(FetchContent)
    
    FetchContent_Declare(
        JUCE
        GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
        GIT_TAG        8.0.4  # JUCE 8.0.4 - update as needed
        GIT_SHALLOW    TRUE
    )
    
    FetchContent_MakeAvailable(JUCE)
endif()

# =============================================================================
# Plugin Configuration
# =============================================================================

# Company and plugin identifiers
#rename defaults here
set(COMPANY_NAME "jebjosh")
set(COMPANY_CODE "JEBJ")
set(PLUGIN_CODE "DX10")
set(BUNDLE_ID "com.jebjosh.dx10")

# Plugin formats based on platform
if(APPLE)
    set(PLUGIN_FORMATS AU VST3 Standalone)
elseif(WIN32)
    set(PLUGIN_FORMATS VST3 Standalone)
else()
    # Linux
    set(PLUGIN_FORMATS VST3 Standalone)
endif()

# =============================================================================
# Plugin Target
# =============================================================================
#put correct email
juce_add_plugin(DX10
    # Basic plugin info
    PRODUCT_NAME "DX10"
    COMPANY_NAME "${COMPANY_NAME}"
    COMPANY_COPYRIGHT "Copyright (c) 2025 ${COMPANY_NAME}"
    COMPANY_WEBSITE "https://jebjosh.com"
    COMPANY_EMAIL "contact@jebjosh.com"
    
    # Plugin identifiers
    PLUGIN_MANUFACTURER_CODE ${COMPANY_CODE}
    PLUGIN_CODE ${PLUGIN_CODE}
    BUNDLE_ID ${BUNDLE_ID}
    
    # Plugin type
    IS_SYNTH TRUE
    NEEDS_MIDI_INPUT TRUE
    NEEDS_MIDI_OUTPUT FALSE
    IS_MIDI_EFFECT FALSE
    EDITOR_WANTS_KEYBOARD_FOCUS FALSE
    
    # Plugin formats to build
    FORMATS ${PLUGIN_FORMATS}
    
    # VST3 specific settings
    VST3_CATEGORIES "Instrument" "Synth"
    
    # AU specific settings (macOS only)
    AU_MAIN_TYPE "kAudioUnitType_MusicDevice"
    AU_SANDBOX_SAFE TRUE
    
    # Standalone specific settings
    MICROPHONE_PERMISSION_ENABLED FALSE
    BLUETOOTH_PERMISSION_ENABLED FALSE
    
    # Copy plugin to system folder after build (optional - uncomment if desired)
    # COPY_PLUGIN_AFTER_BUILD TRUE
)

# =============================================================================
# Source Files
# =============================================================================

# Collect all source files from the Source directory
#manually list all the files in your source folder

target_sources(DX10
    PRIVATE
        Source/JuceHeader.h
        Source/PluginProcessor.cpp
        Source/PluginProcessor.h
        Source/PluginEditor.cpp
        Source/PluginEditor.h
        Source/CustomLookAndFeel.h
        Source/RotaryKnobWithLabel.h
        Source/PresetManager.h
        Source/SpectrumAnalyzer.h
)

# =============================================================================
# JUCE Module Dependencies
# =============================================================================

target_link_libraries(DX10
    PRIVATE
        # Core JUCE modules
        juce::juce_core
        juce::juce_data_structures
        juce::juce_events
        juce::juce_graphics
        juce::juce_gui_basics
        juce::juce_gui_extra
        
        # Audio modules
        juce::juce_audio_basics
        juce::juce_audio_devices
        juce::juce_audio_formats
        juce::juce_audio_plugin_client
        juce::juce_audio_processors
        juce::juce_audio_processors_headless
        juce::juce_audio_utils
        juce::juce_dsp
        
    PUBLIC
        # Recommended flags for plugin development
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags
)

# =============================================================================
# Compile Definitions
# =============================================================================

target_compile_definitions(DX10
    PUBLIC
        # JUCE global settings
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0
        JUCE_REPORT_APP_USAGE=0
        
    PRIVATE
        # Version info
        JUCE_APPLICATION_NAME_STRING="$<TARGET_PROPERTY:DX10,JUCE_PRODUCT_NAME>"
        JUCE_APPLICATION_VERSION_STRING="$<TARGET_PROPERTY:DX10,JUCE_VERSION>"
)

# =============================================================================
# Compiler Flags
# =============================================================================

# Set optimization flags for Release builds
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    if(MSVC)
        target_compile_options(DX10 PRIVATE /O2)
    else()
        target_compile_options(DX10 PRIVATE -O3)
    endif()
endif()

# Suppress common warnings
if(MSVC)
    target_compile_options(DX10 PRIVATE /W4)
else()
    target_compile_options(DX10 PRIVATE -Wall -Wextra -Wpedantic)
endif()

# =============================================================================
# Platform-Specific Settings
# =============================================================================

if(APPLE)
    # AudioUnit SDK path for AU plugin builds
    # JUCE 8 requires Apple's AudioUnitSDK which can be downloaded from:
    # https://github.com/apple/AudioUnitSDK
    # Set this to the path where you cloned/downloaded the AudioUnitSDK
    set(AUDIOUNIT_SDK_PATH "" CACHE PATH "Path to Apple's AudioUnitSDK")
    
    # Try to find AudioUnitSDK in common locations
    if(NOT AUDIOUNIT_SDK_PATH OR NOT EXISTS "${AUDIOUNIT_SDK_PATH}")
        # Check common locations
        set(POSSIBLE_AU_SDK_PATHS
            "${CMAKE_CURRENT_SOURCE_DIR}/AudioUnitSDK"
            "${CMAKE_CURRENT_SOURCE_DIR}/libs/AudioUnitSDK"
            "$ENV{HOME}/AudioUnitSDK"
            "/Applications/JUCE/AudioUnitSDK"
        )
        
        foreach(AU_PATH ${POSSIBLE_AU_SDK_PATHS})
            if(EXISTS "${AU_PATH}/include/AudioUnitSDK/AUBase.h")
                set(AUDIOUNIT_SDK_PATH "${AU_PATH}")
                message(STATUS "Found AudioUnitSDK at: ${AUDIOUNIT_SDK_PATH}")
                break()
            endif()
        endforeach()
    endif()
    
    if(AUDIOUNIT_SDK_PATH AND EXISTS "${AUDIOUNIT_SDK_PATH}")
        target_include_directories(DX10 PRIVATE "${AUDIOUNIT_SDK_PATH}/include")
        message(STATUS "Using AudioUnitSDK from: ${AUDIOUNIT_SDK_PATH}")
    else()
        message(WARNING "AudioUnitSDK not found. AU plugin may fail to build.")
        message(WARNING "Download from: https://github.com/apple/AudioUnitSDK")
        message(WARNING "Then set -DAUDIOUNIT_SDK_PATH=/path/to/AudioUnitSDK")
    endif()
    
    # macOS/iOS frameworks
    find_library(COCOA_FRAMEWORK Cocoa)
    find_library(IOKIT_FRAMEWORK IOKit)
    find_library(COREAUDIO_FRAMEWORK CoreAudio)
    find_library(COREMIDI_FRAMEWORK CoreMIDI)
    find_library(ACCELERATE_FRAMEWORK Accelerate)
    find_library(AUDIOTOOLBOX_FRAMEWORK AudioToolbox)
    find_library(AUDIOUNIT_FRAMEWORK AudioUnit)
    
    target_link_libraries(DX10
        PRIVATE
            ${COCOA_FRAMEWORK}
            ${IOKIT_FRAMEWORK}
            ${COREAUDIO_FRAMEWORK}
            ${COREMIDI_FRAMEWORK}
            ${ACCELERATE_FRAMEWORK}
            ${AUDIOTOOLBOX_FRAMEWORK}
            ${AUDIOUNIT_FRAMEWORK}
    )
    
    # Code signing for AU validation (set to - for ad-hoc signing)
    set_target_properties(DX10 PROPERTIES
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "-"
        XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
        XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ""
    )
    
elseif(WIN32)
    # Windows specific settings
    target_compile_definitions(DX10 PRIVATE _USE_MATH_DEFINES)
    
    # Link Windows libraries
    target_link_libraries(DX10
        PRIVATE
            winmm
            ole32
            oleaut32
            uuid
    )
endif()

# =============================================================================
# Install Rules (Optional)
# =============================================================================

# Install targets for deployment
install(TARGETS DX10_VST3
    LIBRARY DESTINATION lib/vst3
    RUNTIME DESTINATION lib/vst3
)

install(TARGETS DX10_Standalone
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION bin
)

if(APPLE)
    install(TARGETS DX10_AU
        LIBRARY DESTINATION lib/au
        BUNDLE DESTINATION lib/au
    )
endif()

# =============================================================================
# Print Configuration Summary
# =============================================================================

message(STATUS "")
message(STATUS "========================================")
message(STATUS "  DX10 FM Synthesizer - Build Config")
message(STATUS "========================================")
message(STATUS "  Version:          ${PROJECT_VERSION}")
message(STATUS "  Company:          ${COMPANY_NAME}")
message(STATUS "  Build Type:       ${CMAKE_BUILD_TYPE}")
message(STATUS "  C++ Standard:     ${CMAKE_CXX_STANDARD}")
message(STATUS "  Plugin Formats:   ${PLUGIN_FORMATS}")
if(APPLE)
    message(STATUS "  macOS Archs:      ${CMAKE_OSX_ARCHITECTURES}")
    message(STATUS "  Deployment:       ${CMAKE_OSX_DEPLOYMENT_TARGET}")
endif()
message(STATUS "========================================")
message(STATUS "")
