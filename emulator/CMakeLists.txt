cmake_minimum_required(VERSION 3.15)
project(CasioEmuX CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(SOURCES
    src/casioemu.cpp
    src/Emulator.cpp
    src/Logger.cpp
    src/Chipset/CPU.cpp
    src/Chipset/CPUArithmetic.cpp
    src/Chipset/CPUControl.cpp
    src/Chipset/CPULoadStore.cpp
    src/Chipset/CPUPushPop.cpp
    src/Chipset/Chipset.cpp
    src/Chipset/Coprocessor.cpp
    src/Chipset/InterruptSource.cpp
    src/Chipset/MMU.cpp
    src/Chipset/MMURegion.cpp
    src/Data/ModelInfo.cpp
    src/Peripheral/BCDCalc.cpp
    src/Peripheral/BatteryBackedRAM.cpp
    src/Peripheral/ExternalInterrupts.cpp
    src/Peripheral/Flash.cpp
    src/Peripheral/IOPorts.cpp
    src/Peripheral/Keyboard.cpp
    src/Peripheral/Miscellaneous.cpp
    src/Peripheral/Peripheral.cpp
    src/Peripheral/PowerSupply.cpp
    src/Peripheral/ROMWindow.cpp
    src/Peripheral/RealTimeClock.cpp
    src/Peripheral/Screen.cpp
    src/Peripheral/StandbyControl.cpp
    src/Peripheral/Timer.cpp
    src/Peripheral/TimerBaseCounter.cpp
    src/Peripheral/WatchdogTimer.cpp
    src/Gui/CodeViewer.cpp
    src/Gui/Command.cpp
    src/Gui/imgui/imgui.cpp
    src/Gui/imgui/imgui_draw.cpp
    src/Gui/imgui/imgui_impl_sdl2.cpp
    src/Gui/imgui/imgui_impl_sdlrenderer2.cpp
    src/Gui/imgui/imgui_tables.cpp
    src/Gui/imgui/imgui_widgets.cpp
)

add_executable(casioemu ${SOURCES})

target_compile_options(casioemu PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-pedantic>
    $<$<CXX_COMPILER_ID:MSVC>:/W4>
)

find_package(SDL2 REQUIRED)
find_package(SDL2_image REQUIRED)
find_package(Lua 5.3 EXACT REQUIRED)

target_include_directories(casioemu PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${LUA_INCLUDE_DIR}
)

target_link_libraries(casioemu PRIVATE
    SDL2::SDL2
    SDL2_image::SDL2_image
    ${LUA_LIBRARIES}
)

if(TARGET SDL2::SDL2main)
    target_link_libraries(casioemu PRIVATE SDL2::SDL2main)
endif()

if(WIN32)
    find_package(WinEditLine REQUIRED)
    target_link_libraries(casioemu PRIVATE WinEditLine::WinEditLine)
else()
    find_library(EDITLINE_LIB NAMES edit REQUIRED)
    find_path(EDITLINE_INCLUDE_DIR NAMES editline/readline.h REQUIRED)
    target_include_directories(casioemu PRIVATE ${EDITLINE_INCLUDE_DIR})
    target_link_libraries(casioemu PRIVATE ${EDITLINE_LIB})
endif()
