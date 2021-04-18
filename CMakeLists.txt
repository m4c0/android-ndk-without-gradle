cmake_minimum_required(VERSION 3.17)
project(hello-world VERSION 1.0.0 LANGUAGES CXX)

if(UMBRELLA)
  include(apk_build.cmake)
  return()
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(hello-world SHARED main.cpp)
target_link_libraries(hello-world PUBLIC log)
install(TARGETS hello-world)
