cmake_minimum_required(VERSION 3.20)
project(MyDesktopVideo LANGUAGES OBJCXX)

# Create a macOS application bundle
set(CMAKE_OSX_DEPLOYMENT_TARGET "13.0")

<<<<<<< HEAD
=======
# Set output directory to project root (source directory)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}")

>>>>>>> 0a4aa0d (feat: Add CMake build system, update README with build and formatting instructions, and refine Info.plist for the macOS application.)
# Set the source files
set(SOURCES main.mm)

# Create the executable bundle
add_executable(MyDesktopVideo MACOSX_BUNDLE ${SOURCES})

# Configure Automatic Reference Counting (ARC)
target_compile_options(MyDesktopVideo PRIVATE -fobjc-arc)

# Use C++20 for code modern code support
set_target_properties(MyDesktopVideo PROPERTIES 
    CXX_STANDARD 20
    CXX_STANDARD_REQUIRED ON
)

# Link required macOS Frameworks
target_link_libraries(MyDesktopVideo PRIVATE
    "-framework Cocoa"
    "-framework AVFoundation"
    "-framework AVKit"
    "-framework ServiceManagement"
    "-framework QuartzCore"
    "-framework UniformTypeIdentifiers"
)

# Output directory adjustment for the bundle
set_target_properties(MyDesktopVideo PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.johndiniz.MyDesktopVideo"
    MACOSX_BUNDLE_BUNDLE_NAME "MyDesktopVideo"
)
