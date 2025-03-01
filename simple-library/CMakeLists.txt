cmake_minimum_required(VERSION 3.10.0)
project(simple-library VERSION 0.1.0 LANGUAGES C)

# Build the shared library

add_library(simple-library SHARED
            simple-library.c)


# Install the shared library
install(TARGETS simple-library
        LIBRARY DESTINATION lib)
# Install the header file
install(FILES simple-library.h
        DESTINATION include)

