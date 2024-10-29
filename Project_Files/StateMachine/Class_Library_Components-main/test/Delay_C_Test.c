// include the header files needed for examples
#include <stdio.h>
#include "bcm2835.h"

// extern each delay function for the compiler
extern void delaySec(int input);
extern void delayMili(int input);
extern void delayNano(int input);
extern void delayMicro(int input);
extern void delayCenti(int input);
extern void delayMin(int input);

// start of the main code
int main(int argc, char **argv)
{
    // user input for delay paramter
    int input = 500;

    // initialze
    if (!bcm2835_init())
        return 1;

    // set gpio 22 as output
    bcm2835_gpio_fsel(22, BCM2835_GPIO_FSEL_OUTP);

    // set up inifite loop
    while (1)
    {
        // pull gpio high
        bcm2835_gpio_write(22, HIGH);

        // print statement
        printf("This is the start:\n");

        // call sleep function
        // delayMin(input);
        // delaySec(input);
        // delayCenti(input);
        // delayMili(input);
        delayMicro(input);
        // delayNano(input);

        // print statement
        printf("This is the end:\n");

        // pull gpio LOW
        bcm2835_gpio_write(22, LOW);

        // call sleep function
        // delayMin(input);
        // delaySec(input);
        // delayCenti(input);
        // delayMili(input);
        delayMicro(input);
        // delayNano(input);
    }
    bcm2835_close();

} // main function