# Introduction

This repository contains a set of simple projects to experiment with Java
interacting with native code.

# Projects

This repository uses the following projects:

* simple-library - A simple C library installing both a static and a dynamic variant.
* simple-c-app - A simple C app linked to the `simple-library`, the build can be configured to use either the static or the dynamic variant.
* simple-jni - A simple Java project with two defined native methods.
* jni-library - Minimal dynamic library, implementing the generated header from `simple-jni` to call the library from `simple-library`.


