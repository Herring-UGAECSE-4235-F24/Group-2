#include <E4235.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <bcm2835.h>

int main() {
	
	if(!bcm2835_init()) {
		printf("you suck");
		return 1;
	}
	
	bcm2835_gpio_fsel(16, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(15, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(14, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(13, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(12, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(5, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(10, BCM2835_GPIO_FSEL_OUTP);
	
	int inverse(int i) {
		if (i == 1) {
			return 0;
		} else {
			return 1;
		}
	}
	
	//bcm2835_gpio_write(17, inverse(1));
	bcm2835_gpio_write(16, 1);
	bcm2835_gpio_write(15, 0);
	bcm2835_gpio_write(14, 0);
	bcm2835_gpio_write(13, 0);
	bcm2835_gpio_write(12, 0);
	bcm2835_gpio_write(5, 0);
	bcm2835_gpio_write(10, 0);
	/*bcm2835_gpio_fsel(9, BCM2835_GPIO_FSEL_OUTP);
	while(1) {
		bcm2835_gpio_write(9, 0);
		usleep(500);
		bcm2835_gpio_write(9, 1);
		usleep(500);
	}*/	

	
	bcm2835_close();
	return 0;

}
