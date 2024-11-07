#!/bin/bash
as -o factorial.o factorial.s -mfpu=vfpv3
as -o exponential.o exponential.s -mfpu=vfpv3
gcc -o eCalls eCalls.c exponential.o factorial.o -mfpu=vfpv3
