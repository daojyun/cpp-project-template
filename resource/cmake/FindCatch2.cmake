set(PACKAGE_NAME Catch2)
set(PACKAGE_DIRECTORY "${CMAKE_BINARY_DIR}/extern/${PACKAGE_NAME}")
set(PACKAGE_INCLUDE_DIRECTORY "${PACKAGE_DIRECTORY}/include")
set(PACKAGE_URL
    "https://raw.githubusercontent.com/catchorg/Catch2/master/single_include/catch2/catch.hpp"
)

#[[
# CMake issue: https://gitlab.kitware.com/cmake/cmake/-/issues/20526
include(FetchContent)
FetchContent_Declare(
  "${PACKAGE_NAME}"
  SOURCE_DIR
  "${PACKAGE_INCLUDE_DIRECTORY}/catch2"
  URL ${PACKAGE_URL}
  )
FetchContent_MakeAvailable("${PACKAGE_NAME}")
#]]

set(PACKAGE_HEADER_FILE_PATH "${PACKAGE_INCLUDE_DIRECTORY}/catch2/catch.hpp")
if(NOT EXISTS ${PACKAGE_HEADER_FILE_PATH})
  message("download ${PACKAGE_URL}")
  file(DOWNLOAD "${PACKAGE_URL}" "${PACKAGE_HEADER_FILE_PATH}")
endif()

add_library(${PACKAGE_NAME} INTERFACE IMPORTED)
target_include_directories(${PACKAGE_NAME}
                           INTERFACE "${PACKAGE_INCLUDE_DIRECTORY}")

set(${PACKAGE_NAME}_INCLUDE_DIR "${PACKAGE_DIRECTORY}")
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args("${PACKAGE_NAME}" DEFAULT_MSG
                                  "${PACKAGE_NAME}_INCLUDE_DIR")
