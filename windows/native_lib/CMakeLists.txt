cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "native_sdl")
project(${PROJECT_NAME} LANGUAGES C CXX)

include(FetchContent)

FetchContent_Declare(
  sdl
  URL https://www.libsdl.org/release/SDL-devel-1.2.15-VC.zip
)

FetchContent_MakeAvailable(sdl)
FetchContent_GetProperties(sdl)

message("${sdl_SOURCE_DIR}")

set(NATIVE_LIB_NAME sdl-wrapper)

add_library(${NATIVE_LIB_NAME} SHARED
  "native_sdl.cpp"
)

set(ENV{SDLDIR} "${sdl_SOURCE_DIR}")
set(SDL_BUILDING_LIBRARY true)
message("variable is $ENV{SDLDIR}")
find_package(SDL REQUIRED)
include_directories(${SDL_INCLUDE_DIRS})
target_link_libraries(${NATIVE_LIB_NAME} PRIVATE ${SDL_LIBRARIES})
message("SDL_LIBRARIES: ${SDL_LIBRARIES}")