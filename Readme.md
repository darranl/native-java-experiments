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


