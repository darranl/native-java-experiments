cmake_minimum_required(VERSION 3.10.0)

if (EXISTS $ENV{HOME}/local)
    set(CMAKE_INSTALL_PREFIX $ENV{HOME}/local)
    message("Setting CMAKE_INSTALL_PREFIX to $ENV{HOME}/local")
endif()

project(simple-library VERSION 0.1.0 LANGUAGES C)

set(SIMPLE_SOURCE
        simple-library.c
)

set (SIMPLE_HEADERS
        simple-library.h
)

# Build the shared library
add_library(simple-library SHARED
            ${SIMPLE_SOURCE})
# Build the static library
add_library(simple-library-static STATIC
            ${SIMPLE_SOURCE})


# Install the shared library
install(TARGETS simple-library
        LIBRARY DESTINATION lib)
# Install the static library
install(TARGETS simple-library-static
        ARCHIVE DESTINATION lib)
# Install the header file
install(FILES ${SIMPLE_HEADERS}
        DESTINATION include)

