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

Expected output: two `T` (text/code) symbols — `add_one` and `say_hello`:

```
0000000000001109 T add_one
0000000000001118 T say_hello
```

Check the shared library's runtime dependencies:

```bash
ldd $HOME/local/lib/libsimple-library.so
```

Expected: only `libc.so` (no extra dependencies).

## simple-c-app

**Prerequisite:** `simple-library` must be built and installed first.

```bash
mkdir simple-c-app/build && cd simple-c-app/build
cmake ..
make
```

Note: there is no `make install` — the executable lives in `build/`.

### Running

From the `simple-c-app/` directory:

```bash
cd simple-c-app
./run-app.sh
```

Expected output:

```
Hello, from simple-c-app!
add_one(5) = 6
Hello, from simple-library!
```

## simple-jni (Maven — generates JNI headers)

**Prerequisite:** `simple-library` must be built and installed first.

**Important:** Run this Maven build from inside the `simple-jni/` directory, not from the
repository root with `-f`. The compiler plugin generates JNI C headers to `target/include/`
relative to the working directory, and `jni-library`'s CMake build looks for them at
`../simple-jni/target/include/`.

```bash
cd simple-jni
mvn clean package
```

Verify the headers were generated:

```bash
ls simple-jni/target/include/
# dev_lofthouse_App.h
```

## jni-library

**Prerequisites:**
1. `simple-library` built and installed (`$HOME/local/lib/libsimple-library.so`)
2. `simple-jni` Maven build completed (generates `simple-jni/target/include/dev_lofthouse_App.h`)

```bash
mkdir jni-library/build && cd jni-library/build
cmake ..
make
make install
```

`make install` copies `libjni-library.so` to `$HOME/local/lib/`.

## simple-jni (JVM run)

**Prerequisite:** `jni-library` must be built and installed to `$HOME/local/lib/`.

From the `simple-jni/` directory:

```bash
cd simple-jni
./run-app.sh
```

Expected output:

```
Java says Hello World!
<java.library.path — varies by machine>
addOne(11)= 12
Java says Goodbye World!
Hello, from simple-library!
```

> **Note:** `Hello, from simple-library!` appears after `Java says Goodbye World!` due to
> stdout buffering differences between Java's `PrintStream` and C's `printf`.

## simple-foreign

**Prerequisite:** `simple-library` must be built and installed first.

```bash
cd simple-foreign
mvn clean package
./run-app.sh
```

Expected output:

```
addOne(14) = 15
Hello World!
Hello, from simple-library!
```

> **Note:** `say_hello()` is invoked before `add_one()` in the source, but `Hello, from simple-library!`
> appears last due to stdout buffering differences between Java's `PrintStream` and C's `printf`.

## simple-jni (native image)

**Prerequisite:** `jni-library` must be built and installed to `$HOME/local/lib/`.

GraalVM is required (not included in standard Temurin/OpenJDK distributions).

From the `simple-jni/` directory:

```bash
cd simple-jni
mvn clean package -Dnative
./run-app-native.sh
```

Expected output:

```
Java says Hello World!
<LD_LIBRARY_PATH — varies by machine>
addOne(11)= 12
Java says Goodbye World!
Hello, from simple-library!
```

> **Note:** `Hello, from simple-library!` appears after `Java says Goodbye World!` due to
> stdout buffering differences between Java's `PrintStream` and C's `printf`.

## simple-foreign (native image)

**Prerequisite:** `simple-library` must be built and installed first.

GraalVM is required (not included in standard Temurin/OpenJDK distributions).

From the `simple-foreign/` directory:

```bash
cd simple-foreign
mvn clean package -Dnative
./run-app-native.sh
```

`simple-foreign` includes a `ForeignRegistrationFeature` (in
`src/main/java/dev/lofthouse/graal/`) that registers the two Foreign Function API downcall
stubs (`add_one` and `say_hello`) at build time. GraalVM's Substrate VM cannot discover these
at runtime, so they must be declared explicitly for AOT compilation. The feature is activated
via `META-INF/native-image/native-image.properties`.

Expected output:

```
addOne(14) = 15
Hello World!
Hello, from simple-library!
```

> **Note:** `say_hello()` is invoked before `add_one()` in the source, but `Hello, from simple-library!`
> appears last due to stdout buffering differences between Java's `PrintStream` and C's `printf`.

## Java projects — common notes

```bash
# Build and run tests
mvn clean package

# Build with GraalVM native image
mvn clean package -Dnative

# Run tests only
mvn test
```

Each Java project provides `run-app.sh` (JVM) and `run-app-native.sh` (native image) scripts.

**Prerequisites:** Java 25 is required. GraalVM is required for native image builds (the `-Dnative` profile).
