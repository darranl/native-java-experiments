#!/bin/bash
export LD_LIBRARY_PATH=/home/darranl/local/lib

java --class-path=target/simple-jni-0.0.1-SNAPSHOT.jar \
    -Djava.library.path=/home/darranl/local/lib \
    dev.lofthouse.App
