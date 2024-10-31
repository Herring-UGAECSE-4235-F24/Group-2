# Compiler
#CC = gcc

# Source file
#SRC = LIBRARY_FIX.c

# Executable name
#TARGET = LIBRARY_FIX

#all: $(TARGET)

#$(TARGET): $(SRC)
#	$(CC) -o $@ $^ E4235_Write.s E4235_Delaynano.s -lbcm2835 -lE4235

#clean:
#	rm -f $(TARGET)

NAME = LIBRARY_FIX
FLAGS = -lE4235 -Wall -pedantic -lbcm2835
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

cl: $(NAME).c
	gcc -o $(NAME) $(NAME).c $(FLAGS)

run: cl
	./$(NAME)

clean:
	rm -f $(NAME)
