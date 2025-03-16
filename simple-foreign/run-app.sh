#!/bin/bash
export LD_LIBRARY_PATH=/home/darranl/local/lib

java --class-path=target/simple-foreign-0.0.1-SNAPSHOT.jar \
     --enable-native-access=ALL-UNNAMED \
    -Djava.library.path=/home/darranl/local/lib \
    dev.lofthouse.App
