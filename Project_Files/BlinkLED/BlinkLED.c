#include "E4235.h"
#include "gpiotopin.h"
#include "bcm2835.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// Blinks on RPi Plug P1 pin 11 (which is GPIO pin 17)
#define PIN RPI_GPIO_P1_11

int convert(int frequency) {
    float time = 1.0 / frequency;
    int delay = ((time / 2) * 1000000);
    return delay;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <frequency>\n", argv[0]);
        return 1;
    }

    int frequency = atoi(argv[1]);

    if (!bcm2835_init())
        return 1;

    bcm2835_gpio_fsel(PIN, BCM2835_GPIO_FSEL_OUTP);

    while (1) {
        bcm2835_gpio_write(PIN, HIGH);
        usleep(convert(frequency));
        bcm2835_gpio_write(PIN, LOW);
        usleep(convert(frequency));
    }

    bcm2835_close();
    return 0;
}
