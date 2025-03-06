cmake_minimum_required(VERSION 3.10.0)

if (EXISTS $ENV{HOME}/local)
    set(CMAKE_INSTALL_PREFIX $ENV{HOME}/local)
endif()

project(jni-library VERSION 0.1.0 LANGUAGES C)

set(JNI_SOURCE
        jni-library.c
)

add_library(jni-library SHARED ${JNI_SOURCE})

# Include the JNI headers
target_include_directories(jni-library PRIVATE
    $ENV{JAVA_HOME}/include
    $ENV{JAVA_HOME}/include/linux)

# Include the simple-jni headers
target_include_directories(jni-library PRIVATE
    ../simple-jni/target/include)

# Include the simple-library headers
target_include_directories(jni-library PRIVATE
    $ENV{HOME}/local/include) # This one was installed.

# Link the shared library
target_link_directories(jni-library PRIVATE
    $ENV{HOME}/local/lib)

# Link the shared library
target_link_libraries(jni-library PRIVATE
    simple-library)

# Install the shared library
install(TARGETS jni-library
    LIBRARY DESTINATION lib)
