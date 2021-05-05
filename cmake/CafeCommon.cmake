set(CAFE_INCLUDE_TESTS OFF CACHE BOOL "Include tests")

list(APPEND CAFE_OPTIONS CAFE_INCLUDE_TESTS)

if(CAFE_INCLUDE_TESTS)
    set(CAFE_INCLUDE_TESTS True)
else()
    set(CAFE_INCLUDE_TESTS False)
endif()

set(BUILD_TESTING ${CAFE_INCLUDE_TESTS} CACHE BOOL "Build testing" FORCE)

if(CONAN_EXPORTED)
    include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    conan_basic_setup(TARGETS)
else()
    if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
        message(STATUS "Downloading conan.cmake")
        file(DOWNLOAD "https://raw.githubusercontent.com/akemimadoka/cmake-conan/develop/conan.cmake"
                      "${CMAKE_BINARY_DIR}/conan.cmake" SHOW_PROGRESS
                      STATUS _download_status)
        list(GET _download_status 0 _download_status_code)
        list(GET _download_status 1 _download_status_msg)
        if(NOT _download_status_code EQUAL 0)
            file(REMOVE "${CMAKE_BINARY_DIR}/conan.cmake")
            message(FATAL_ERROR "Failed to download conan.cmake, status code is ${_download_status_code}, msg is ${_download_status_msg}")
        endif()
    endif()

    include(${CMAKE_BINARY_DIR}/conan.cmake)

    foreach(_cafe_option ${CAFE_OPTIONS})
        set(_cafe_option_value ${${_cafe_option}})
        list(JOIN _cafe_option_value "," _cafe_option_value)
        string(REPLACE "ON" "True" _cafe_option_value ${_cafe_option_value})
        string(REPLACE "OFF" "False" _cafe_option_value ${_cafe_option_value})
        list(APPEND _cafe_conan_options "${_cafe_option}=${_cafe_option_value}")
    endforeach()
    message(STATUS "_cafe_conan_options is ${_cafe_conan_options}")
    conan_cmake_run(CONANFILE conanfile.py
                    BASIC_SETUP CMAKE_TARGETS
                    BUILD missing
                    OPTIONS "${_cafe_conan_options}"
    )
endif()

if(CAFE_INCLUDE_TESTS)
    include(CTest)
    list(APPEND CMAKE_MODULE_PATH ${CONAN_LIB_DIRS_CATCH2}/cmake/Catch2)
    include(ParseAndAddCatchTests)
endif()

add_compile_definitions(CAFE_BUILDING)
if(BUILD_SHARED_LIBS)
    add_compile_definitions(CAFE_BUILDING_DLL)
    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(CMAKE_SHARED_LIBRARY_PREFIX "")
    endif()
endif()
