#include "E4235.h"
#include "gpiotopin.h"
#include "bcm2835.h"
#include <stdio.h>

// Use GPIO 18 for PWM
#define PIN RPI_GPIO_P1_12

int main(int argc, char **argv)
{
    if (!bcm2835_init()) {
        fprintf(stderr, "doesnt work\n");
        return 1;
    }
    
    bcm2835_gpio_fsel(PIN, BCM2835_GPIO_FSEL_ALT5);
    bcm2835_pwm_set_clock(BCM2835_PWM_CLOCK_DIVIDER_16);
    bcm2835_pwm_set_mode(0, 0, 1);
    bcm2835_pwm_set_range(0, 1024);
    bcm2835_pwm_set_data(0, 512);
    
    while (1) {
            bcm2835_delay(100);
    }
    
    bcm2835_close();
    return 0;
    
    /*
    if (!bcm2835_init())
        return 1;

    // Set the pin to use PWM mode
    bcm2835_gpio_fsel(PIN, BCM2835_GPIO_FSEL_ALT5);

    // Initialize PWM
    bcm2835_pwm_set_clock(BCM2835_PWM_CLOCK_DIVIDER_16); // set 19.2 MHz clock divider
    bcm2835_pwm_set_range(0, 1000); // Set PWM range to 1000
    bcm2835_pwm_set_data(0, 500); // Set PWM channel 0 and set duty?
    bcm2835_pwm_set_mode(0, 0, 1); // Set PWM channel 0 to mark-space mode
    
    // Run without actions in the while loop
    bcm2835_delay(10000); // Run for 5 seconds

    bcm2835_close();
    return 0;
    * */
}
