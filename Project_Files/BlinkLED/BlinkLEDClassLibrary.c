#include <stdio.h>
#include <stdlib.h>
#include <E4235.h>

int main(int argc, char *argv[]) {
    int frequency = 100 //atoi(argv[1]);
    if (frequency > -1) {
    	E4235_PWM_Set(12, frequency, 50);
    	E4235_PWM_Enable(12, 1);
    } else {
	E4235_PWM_Enable(12, 0);
    }

    return 0;
}
