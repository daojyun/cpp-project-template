cmake_minimum_required(VERSION 3.12)

project(":::PROJECT_NAME_TAG:::" LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
set(CMAKE_MODULE_PATH
    "${CMAKE_SOURCE_DIR}/extern/cpp-project-template/resource/cmake")
set(CMAKE_BUILD_TYPE Release)

add_compile_options(-Werror -Wall -Wextra)
add_compile_options(-fmax-errors=2)

#[[
add_subdirectory(src)
add_subdirectory(lib)
add_subdirectory(app)
#]]
add_subdirectory(test)
