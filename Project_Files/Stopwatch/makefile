OBJS = stopwatch.o
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

%.o : %.s
	as $(DEBUGFLGS) $< -o $@
stopwatch: $(OBJS)
	gcc -o stopwatch $(OBJS)

clean:
	rm *.o stopwatch
