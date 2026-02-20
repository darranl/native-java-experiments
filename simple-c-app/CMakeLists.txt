cmake_minimum_required(VERSION 3.10.0)
project(simple-c-app VERSION 0.1.0 LANGUAGES C)

add_executable(simple-c-app main.c)

target_include_directories(simple-c-app PRIVATE
    $ENV{HOME}/local/include)

# Using target_link_directories with a known install prefix is simpler than
# find_library() and sufficient here since simple-library is always installed
# to $HOME/local by its own CMake build.
target_link_directories(simple-c-app PRIVATE
    $ENV{HOME}/local/lib)

# Link the shared library
target_link_libraries(simple-c-app PRIVATE
    simple-library)

# Link the static library
#target_link_libraries(simple-c-app PRIVATE
#    simple-library-static)
