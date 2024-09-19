LIBOBJS = upper.o

ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif
LSTFLGS =

all: 0_AddressMap

%.o : %.s
	as -g $(LSTFLGS) $< -o $@

0_AddressMap: 0_AddressMap.s debug.s
	gcc -o 0_AddressMap 0_AddressMap.s