#include "bcm2835.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

// extern stuff
extern int E4235_Read(int GPIO);
extern int E4235_Select ( int GPIO, int state );

// Blinks on RPi Plug P1 pin 8 (which is GPIO pin 17)
#define SDAPIN 17
#define SCLPIN 27

void writeBit(uint8_t b);
uint8_t readBit();

// start of function declarations
// function to swap numbers
int decimal_to_bcd(int dec) {
    return ((dec / 10) * 16) + (dec % 10);
}

// function to set SDA line (1 == HIGH, 0 == LOW)
void setSDA(int var) {
    
    // condtional to change
    if (var == 1) {
	E4235_Select(SDAPIN, BCM2835_GPIO_FSEL_OUTP);
    } else if (var == 0) {
	E4235_Select(SDAPIN, BCM2835_GPIO_FSEL_INPT);
    }
    
}

// function to set SCL line (1 == HIGH, 0 == LOW)
void setSCL(int var) {
    
    // condtional to change
    if (var == 0) {
	E4235_Select(SCLPIN, BCM2835_GPIO_FSEL_OUTP);
    } else if (var == 1) {
	E4235_Select(SCLPIN, BCM2835_GPIO_FSEL_INPT);
    }
    
}

void delay_time() {
    for ( int i = 0; i < 1200; i++){
		asm volatile ("nop");
    }
}

void stretch_delay() {
    for ( int i = 0; i < 1800; i++){
		asm volatile ("nop");
    }
}

// function to run a dummy clock cycle
void clk() {
    delay_time();
    setSCL(1);
    delay_time();
    setSCL(0);
}

// function to run a stretched clock cycle
void stretch_clock() {
    stretch_delay();
    setSCL(1);
    stretch_delay();
    setSCL(0);
}

// transmission to send before sending bits of data
void startSeq() {
    
    // SDA ON, SLC ON, SDA OFF, SCL OFF
    //writeBit(1);writeBit(0);
    setSDA(1);
    setSCL(1);
    delay_time();
    setSDA(0);
    delay_time();
    setSCL(0);
    delay_time();

}

// transmission to send after sending data
void stopSeq() {
    
    // SDA OFF, SLC ON, SDA ON
    setSDA(0);
    delay_time();
    setSCL(1);
    delay_time();
    setSDA(1);
    delay_time();
}

// write a bit in i2c
void writeBit(uint8_t b) {
    
    // if 1 write 1, is 0 write 0
    if (b > 0) {
	setSDA(1);
    } else {
	setSDA(0);
    }
    
    // clock the bit on the SCL line
    clk();
}

void writeValue(uint8_t v) {
    for (int i = 7; i >= 0; i--){
		uint8_t bit = ((v >> i) & 0x01);
		writeBit(bit);
    }
    setSDA(1);
    
    // STRETCH CLOCK
    stretch_clock();
    setSDA(1);
    setSDA(0);
}

// read a bit in i2c
uint8_t readBit() {
    
    // bit to store data
    uint8_t b;
    
    // set SDA to read mode (0) and clock SCL
    setSDA(1); // THIS SETS IT TO READ MODE
    delay_time();
    setSCL(1); // was 1
    delay_time();
    
    // read whats on the SDA bit and store
    b = E4235_Read(SDAPIN);
    
    // set SCL to low again
    setSCL(0); // was 0
    delay_time();
    printf("%d ",b);
    return b;
}

void setup(int r_w) {
    // START
    startSeq();
    
    // ADDRESS
    writeBit(1);
    writeBit(1);
    writeBit(0);
    writeBit(1);
    writeBit(0);
    writeBit(0);
    writeBit(0);
    
    // READ/WRITE
    writeBit(r_w);
    
    //pull it back up
    setSDA(1);
        
    // STRETCH CLOCK
    clk();
    setSDA(0);
}

uint8_t readValue(uint8_t ack) {
	uint8_t value = 0x00;
	for (int i = 0; i < 8; i ++){
		uint8_t bit = readBit();
		value = (value << 1) | bit;
		//printf("%c", value);
	}
	setSDA(!ack);
	clk();
	return value;
}

// start of main code
// this is the main function loop
int main() {
    time_t now = time(NULL);  // Get current time
    struct tm *currentTime = localtime(&now); // Convert to local time
    printf("read(r) or write(w): ");
    char log;
    scanf("%c",&log);
    // START
    setup(0);
    
    // WRITE
    writeValue(0x00); 
    
    if (log == 'w'){
	    writeValue(decimal_to_bcd(currentTime->tm_sec));   // Write seconds
	    writeValue(decimal_to_bcd(currentTime->tm_min));   // Write minutes
	    writeValue(decimal_to_bcd(currentTime->tm_hour));  // Write hours
	    writeValue(decimal_to_bcd(currentTime->tm_wday));
	    writeValue(decimal_to_bcd(currentTime->tm_mday));  // Write day of the month
	    writeValue(decimal_to_bcd(currentTime->tm_mon + 1)); // Write month (tm_mon is 0-based)
	    writeValue(decimal_to_bcd(currentTime->tm_year - 100));
	    stopSeq();
    } else {
	    // READ
	    setup(1);
	    readValue(1);
	    for( int i = 0; i < 5; i++){
		    readValue(1);
	    }
	    readValue(0);
	    // STOP
	    stopSeq();
    }
	
    return 0;
}
