#!/bin/bash
gcc -o eCalls eCalls.c exponential.o factorial.o -mfpu=vfpv3
./eCalls
