//
// C program to call Assembly delays
//

#include <stdio.h>
#include "../bcm2835.h"
#include "../gpiopinmap.h"
extern void E4235_gpio_set_pud(int, int);

int main()
{
	int gpio_in = 24;
	E4235_gpio_set_pud(gpio_in, 1);
	return(0);
}
