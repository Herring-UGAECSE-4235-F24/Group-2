//
// C program to call Assembly delays
//

#include <stdio.h>
#include "../bcm2835.h"
#include "../gpiopinmap.h"
extern void E4235_Delaynano(int);
extern void E4235_Delaymicro(int);
extern void E4235_Delaymilli(int);
extern void E4235_Delaycenti(int);
extern void E4235_Delaysec(int);
extern void E4235_Delaymin(int);

#define TEST PIN7

// Test function for delayNS
// Takes an input value for the delay desired. Created to ouput at a given frequency (1 Hz in testing)
// in order to test accuracy. 
void NS_TEST(int val)
{
	while(1)
	{
		bcm2835_gpio_write(TEST, HIGH);
		E4235_Delaynano(val); 		// CHECKED
		bcm2835_gpio_write(TEST, LOW);
		E4235_Delaynano(val);
	}
}

int main()
{
	// Test values
	int ns = 500000000;		// Nanoseconds/.5 sec 
	int mcs = 60000000;		// Microseconds/min
	int mis = 60000;		// Milliseconds/min
	int cs = 6000;			// Centiseconds/min
	int sec = 60;			// Seconds/min
	int min = 1;			// Minutes/min
	
	if (!bcm2835_init())
      return 1;
      
    bcm2835_gpio_fsel(TEST, BCM2835_GPIO_FSEL_OUTP);
	
	NS_TEST(ns);				// CHECKED
	// E4235_Delaymicro(mcs);	// CHECKED
	// E4235_Delaymilli(mis); 	// CHECKED
	// E4235_Delaycenti(cs); 	// CHECKED
	// E4235_Delaysec(sec);	// CHECKED
	// E4235_Delaymin(min); 	// CHECKED
	
	return(0);
}
