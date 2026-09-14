cmake_minimum_required(VERSION 3.16)
project(LuminusAutomotiveOS LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Multimedia)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

include_directories(include)

add_executable(LuminusOS
    src/main.cpp
    src/telemetry_core.cpp
    include/telemetry_core.hpp
    include/can_definitions.hpp
    ui/resources.qrc
)

target_link_libraries(LuminusOS PRIVATE
    Qt6::Quick
    Qt6::Multimedia
)