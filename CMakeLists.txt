cmake_minimum_required(VERSION 3.17)
project(hello-world VERSION 1.0.0 LANGUAGES CXX)

if(UMBRELLA)
  include(ExternalProject)

  macro(setup_variant VARIANT)
    ExternalProject_Add(${PROJECT_NAME}-${VARIANT}
      SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
      CMAKE_ARGS
      -DANDROID_ABI=${VARIANT}
      -DANDROID_NDK=${ANDROID_NDK}
      -DANDROID_STL=c++_static
      -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/${VARIANT}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${CMAKE_BINARY_DIR}/apk/lib/${VARIANT}
      -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake
      )
  endmacro()
  setup_variant(arm64-v8a)
  setup_variant(armeabi-v7a)
  setup_variant(x86)
  setup_variant(x86_64)

  return()
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(hello-world SHARED main.cpp)
target_link_libraries(hello-world PUBLIC log)
install(TARGETS hello-world)
