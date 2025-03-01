cmake_minimum_required(VERSION 3.10.0)
project(simple-c-app VERSION 0.1.0 LANGUAGES C)

add_executable(simple-c-app main.c)

target_include_directories(simple-c-app PRIVATE
    $ENV{HOME}/local/include)

target_link_directories(simple-c-app PRIVATE
    $ENV{HOME}/local/lib)

target_link_libraries(simple-c-app PRIVATE
    simple-library)
