# Introduction

This repository contains a set of simple projects to experiment with Java
interacting with native code.

A blog post describing this project can be found on my [https://lofthouse.dev](https://lofthouse.dev/2025/03/29/beginning-native-java-development/) site.

# Projects

This repository uses the following projects:

* simple-library - A simple C library installing both a static and a dynamic variant.
* simple-c-app - A simple C app linked to the `simple-library`, the build can be configured to use either the static or the dynamic variant.
* simple-jni - A simple Java project with two defined native methods.
* jni-library - Minimal dynamic library, implementing the generated header from `simple-jni` to call the library from `simple-library`.
* simple-foreign - A simple Java project calling `simple-library` directly using the new foreign functions APIs.

# Building

## simple-library

All other projects depend on `simple-library`, so build it first.

```bash
mkdir simple-library/build && cd simple-library/build
cmake ..
make
make install
```

CMake detects `$HOME/local` as the install prefix; `make install` creates the `lib/` and `include/` subdirectories automatically.

### Verifying the install

Check the installed files exist:

```bash
ls $HOME/local/lib/libsimple-library.so
ls $HOME/local/lib/libsimple-library-static.a
ls $HOME/local/include/simple-library.h
```

Verify the exported symbols in the shared library:

```bash
nm -D $HOME/local/lib/libsimple-library.so | grep -E 'add_one|say_hello'
```

Expected output: two `T` (text/code) symbols — `add_one` and `say_hello`.

Check the shared library's runtime dependencies:

```bash
ldd $HOME/local/lib/libsimple-library.so
```

Expected: only `libc.so` (no extra dependencies).

## Other C projects

`jni-library` and `simple-c-app` both depend on `simple-library` and follow the same CMake pattern (`mkdir build && cd build && cmake .. && make && make install`). Build `simple-library` first.

## Java projects

```bash
# Build and run tests
mvn -f <project>/pom.xml clean package

# Build with GraalVM native image
mvn -f <project>/pom.xml clean package -Dnative

# Run tests only
mvn -f <project>/pom.xml test
```

Each project also provides `run-app.sh` (JVM) and `run-app-native.sh` (native image) scripts.

**Prerequisites:** Java 25 is required. GraalVM is required for native image builds (the `-Dnative` profile).

