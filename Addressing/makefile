LIBOBJS = upper.o

ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif
LSTFLGS =

all: Function6_14

%.o : %.s
	as -g $(LSTFLGS) $< -o $@

Function6_14: Function6_14.s debug.s
	gcc -o Function6_14 Function6_14.s