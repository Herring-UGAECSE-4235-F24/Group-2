#include <bcm2835.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include "E4235.h"
#include <time.h>


void debounce() {
    usleep(500000);
}

int main() {

    int i = 0;
    while (1) {
        
        // step
        i = i +1;
        
        // blink code
        E4235_Write(5, 1);
        printf("TURNING ON - %d\n", i);
        E4235_delayMili(500);
        E4235_Write(5, 0);
        printf("TURNING OFF\n");
        E4235_delayMili(500);
        
    }
        
    
}
