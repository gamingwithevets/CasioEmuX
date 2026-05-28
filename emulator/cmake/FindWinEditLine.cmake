# FindWinEditLine.cmake — finds wineditline on Windows
#
# Imported target: WinEditLine::WinEditLine
# Result vars:     WinEditLine_FOUND  WinEditLine_INCLUDE_DIR  WinEditLine_LIBRARY

find_path(WinEditLine_INCLUDE_DIR
    NAMES editline/readline.h
)

if(WIN32)
    # Prefer static archive (.a) over import lib (.dll.a) on MinGW
    set(_saved_suffixes ${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(CMAKE_FIND_LIBRARY_SUFFIXES .a .dll.a .lib)
endif()

# edit_static: standalone wineditline install; edit: MSYS2 package name
find_library(WinEditLine_LIBRARY
    NAMES edit_static edit
)

if(WIN32)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${_saved_suffixes})
    unset(_saved_suffixes)
endif()

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
