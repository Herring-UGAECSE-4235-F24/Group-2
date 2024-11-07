LIBOBJS = upper.o

ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif
LSTFLGS =

all: test

%.o : %.s
	as -g $(LSTFLGS) $< -o $@

test: test.s
	gcc -o test test.s -mfpu=vfpv3
