cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "native_openal_soft")
project(${PROJECT_NAME} LANGUAGES C CXX)

include(FetchContent)

FetchContent_Declare(
  openal-soft
  URL https://openal-soft.org/openal-binaries/openal-soft-1.21.1-bin.zip
)

FetchContent_MakeAvailable(openal-soft)
FetchContent_GetProperties(openal-soft)

message("${openal-soft_SOURCE_DIR}")
message("${openal-soft_BINARY_DIR}")

set(NATIVE_LIB_NAME openal-soft-wrapper)

add_library(${NATIVE_LIB_NAME} SHARED
  "native_openal_soft.cpp"
)

set(ENV{OPENALDIR} "${openal-soft_SOURCE_DIR}")
message("variable is $ENV{OPENALDIR}")
find_package(OpenAL REQUIRED)
include_directories(${OPENAL_INCLUDE_DIR})
target_link_libraries(${NATIVE_LIB_NAME} PRIVATE ${OPENAL_LIBRARY})