# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Experimental projects demonstrating Java interacting with native C code through multiple approaches: traditional JNI, the modern Foreign Function API (Java 24), and GraalVM native image compilation. Associated blog post: https://lofthouse.dev/2025/03/29/beginning-native-java-development/

## Architecture

All approaches share a common C library (`simple-library`) providing `add_one(int)` and `say_hello()` functions:

- **simple-library** — C library (CMake), installs shared (.so) and static (.a) variants to `$HOME/local`
- **simple-c-app** — Pure C app linked to simple-library (CMake)
- **simple-jni** — Java app using JNI native methods (Maven)
- **jni-library** — C library implementing JNI stubs that delegate to simple-library (CMake)
- **simple-foreign** — Java app using Foreign Function API to call simple-library directly (Maven), includes `ForeignRegistrationFeature` for GraalVM native image compatibility

## Build Commands

### C projects (simple-library, jni-library, simple-c-app)

```bash
# Each C project follows the same pattern:
mkdir <project>/build && cd <project>/build
cmake ..
make
make install   # installs to $HOME/local
```

Build simple-library first — jni-library and simple-c-app depend on it.

### Java projects (simple-jni, simple-foreign)

```bash
# Build and test
mvn -f <project>/pom.xml clean package

# Build with GraalVM native image
mvn -f <project>/pom.xml clean package -Dnative

# Run tests only
mvn -f <project>/pom.xml test
```

### Running applications

Each Java project has `run-app.sh` (JVM) and `run-app-native.sh` (native image) scripts in its directory.

## Key Technical Details

- Java 24 required (maven.compiler.release=24)
- GraalVM needed for native image builds (activated via `-Dnative` profile)
- Native builds use `--enable-native-access ALL-UNNAMED`
- simple-jni's Maven build generates JNI headers to `target/include` (used by jni-library's CMake)
- The `.gitignore` ignores `build/` directories (CMake output)
