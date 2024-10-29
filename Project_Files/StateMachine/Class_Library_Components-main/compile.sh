#!/bin/bash

# compiles source files into object files
for file in src/*; do
    base=${file##*/} # strips path
    base=${base%.*}  # strips extension
    gcc -c "$file" -o "obj/$base.o"
done

# creates library object
ar rv libE4235.a obj/*
ranlib libE4235.a
