cmake_minimum_required(VERSION 3.18)
set(PROJECT_NAME "native_sdl2")
project(${PROJECT_NAME} LANGUAGES C CXX)

include(FetchContent)

FetchContent_Declare(
  sdl
  URL https://libsdl.org/release/SDL2-devel-2.0.20-VC.zip
)

FetchContent_Declare(
  sdl_cmake
  URL https://raw.githubusercontent.com/trenki2/SDL2Test/master/cmake/FindSDL2.cmake
  DOWNLOAD_NO_EXTRACT true
)

FetchContent_MakeAvailable(sdl)
FetchContent_GetProperties(sdl)

FetchContent_MakeAvailable(sdl_cmake)
FetchContent_GetProperties(sdl_cmake)

set(CMAKE_MODULE_PATH "${sdl_cmake_SOURCE_DIR}")

set(NATIVE_LIB_NAME sdl-wrapper)

add_library(${NATIVE_LIB_NAME} SHARED
  "native_sdl.cpp"
  "AudioRecordingManager.cpp"
)

set(ENV{SDL2DIR} "${sdl_SOURCE_DIR}")
set(SDL2_BUILDING_LIBRARY true)
find_package(SDL2 REQUIRED)
include_directories(${SDL2_INCLUDE_DIR})
target_link_libraries(${NATIVE_LIB_NAME} PRIVATE ${SDL2_LIBRARIES})
message("SDL_LIBRARIES: ${SDL2_LIBRARIES}")

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
add_executable("record" "example/record.cpp"
                        "AudioRecordingManager.cpp")
target_link_libraries("record" PRIVATE ${SDL2_LIBRARIES})