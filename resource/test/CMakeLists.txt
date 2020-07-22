add_executable(UnitTest main.cpp)

find_package(Catch2)
target_link_libraries(UnitTest Catch2)
