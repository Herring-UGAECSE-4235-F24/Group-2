#include "E4235.h"
#include "gpiotopin.h"
#include "bcm2835.h"
#include <stdio.h>
#include <unistd.h> // Include for usleep function

// Use GPIO 18 for PWM
#define PIN RPI_GPIO_P1_11
#define PWM_CHANNEL 0
// This controls the max range of the PWM signal
#define RANGE 1024
/*
int main(int argc, char **argv)
{
    if (!bcm2835_init()) {
        fprintf(stderr, "bcm2835_init failed. Are you running as root?\n");
        return 1;
    }
    
    bcm2835_gpio_fsel(PIN, BCM2835_GPIO_FSEL_OUTP);

    // Specify the frequency in Hz (e.g., 10kHz)
    int frequency = 5000;
    int period_us = 1000000 / frequency; // Calculate the period in microseconds
    
    // Generate square wave at the specified frequency
    while (1) {
        bcm2835_gpio_write(PIN, HIGH);
        usleep(period_us / 2); // Half of the period for high state
        bcm2835_gpio_write(PIN, LOW);
        usleep(period_us / 2); // Half of the period for low state
    }
    
    bcm2835_close();
    
    return 0; 
}
*/

int main(int argc, char **argv)
{
    if (!bcm2835_init())
        return 1;
 
    // Set the output pin to Alt Fun 5, to allow PWM channel 0 to be output there
    bcm2835_gpio_fsel(PIN, BCM2835_GPIO_FSEL_ALT5);
 
    // Clock divider is set to 16.
    // With a divider of 16 and a RANGE of 1024, in MARKSPACE mode,
    // the pulse repetition frequency will be
    // 1.2MHz/1024 = 1171.875Hz, suitable for driving a DC motor with PWM
    bcm2835_pwm_set_clock(BCM2835_PWM_CLOCK_DIVIDER_16);
    bcm2835_pwm_set_mode(PWM_CHANNEL, 1, 1);
    bcm2835_pwm_set_range(PWM_CHANNEL, RANGE);
 
    // Vary the PWM m/s ratio between 1/RANGE and (RANGE-1)/RANGE
    // over the course of a a few seconds
    int direction = 1; // 1 is increase, -1 is decrease
    int data = 1;
    while (1)
    {
        if (data == 1)
            direction = 1;   // Switch to increasing
        else if (data == RANGE-1)
            direction = -1;  // Switch to decreasing
        data += direction;
        bcm2835_pwm_set_data(PWM_CHANNEL, data);
        bcm2835_delay(1);
    }
 
    bcm2835_close();
    return 0;
}
