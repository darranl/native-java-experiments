#!/bin/bash
export LD_LIBRARY_PATH=$HOME/local/lib

java --class-path=target/simple-foreign-0.0.1-SNAPSHOT.jar \
     --enable-native-access=ALL-UNNAMED \
    dev.lofthouse.App
