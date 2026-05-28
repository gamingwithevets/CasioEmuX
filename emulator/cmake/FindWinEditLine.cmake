# FindWinEditLine.cmake — finds wineditline on Windows
#
# Imported target: WinEditLine::WinEditLine
# Result vars:     WinEditLine_FOUND  WinEditLine_INCLUDE_DIR  WinEditLine_LIBRARY

find_path(WinEditLine_INCLUDE_DIR
    NAMES editline/readline.h
)

set(_saved_suffixes ${CMAKE_FIND_LIBRARY_SUFFIXES})
set(CMAKE_FIND_LIBRARY_SUFFIXES .a .dll.a .lib)

find_library(WinEditLine_LIBRARY
    NAMES edit_static edit
)

set(CMAKE_FIND_LIBRARY_SUFFIXES ${_saved_suffixes})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(WinEditLine
    REQUIRED_VARS WinEditLine_LIBRARY WinEditLine_INCLUDE_DIR
)

if(WinEditLine_FOUND AND NOT TARGET WinEditLine::WinEditLine)
    add_library(WinEditLine::WinEditLine UNKNOWN IMPORTED)
    set_target_properties(WinEditLine::WinEditLine PROPERTIES
        IMPORTED_LOCATION "${WinEditLine_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${WinEditLine_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(WinEditLine_INCLUDE_DIR WinEditLine_LIBRARY)
