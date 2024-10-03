# Compiler
CC = gcc

# Source file
SRC = test.c

# Executable name
TARGET = test

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) -o $@ $^ -lbcm2835 -lE4235

clean:
	rm -f $(TARGET)
