#include <bcm2835.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <E4235.h>
#include <time.h>

#define NUM_ROWS 4
#define NUM_COLS 4
const int ROWS[NUM_ROWS] = {20, 21, 22, 23};
const int COLS[NUM_COLS] = {24, 25, 26, 27};
#define CH_START 10
#define CH_END 17
#define PAD "                     "

const char *matrix[2][NUM_ROWS][NUM_COLS] = {
    {{"1", "2", "3", "A"}, {"4", "5", "6", "B"}, {"7", "8", "9", "C"}, {"*", "0", "#", "D"}},
    {{"31", "32", "33", "41"}, {"34", "35", "36", "42"}, {"37", "38", "39", "43"}, {"*", "30", "#", "44"}}
};

// {{"E", "F", "G", "N"}, {"H", "I", "J", "O"}, {"K", "L", "M", "P"}, {"*", "R", "#", "Q"}}

void debounce() {
    usleep(500000);
}

void initialize() {
    for (int i = 0; i < NUM_ROWS; i++) {
        bcm2835_gpio_fsel(ROWS[i], BCM2835_GPIO_FSEL_OUTP);
        bcm2835_gpio_write(ROWS[i], LOW);
        // E4235_Select(ROWS[i], 1);
        // E4235_Write(ROWS[i], 0);
    }
    for (int i = 0; i < NUM_COLS; i++) {
        bcm2835_gpio_set_pud(COLS[i], BCM2835_GPIO_PUD_DOWN);
        // E4235_Select(COLS[i], 0);
    }
    for (int ch = CH_START; ch < CH_END; ch++) {
        bcm2835_gpio_fsel(ch, BCM2835_GPIO_FSEL_OUTP);
        bcm2835_gpio_write(ch, LOW);
        // E4235_Select(ch, 1);
    }
    bcm2835_gpio_fsel(3, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_write(3, LOW);
    bcm2835_gpio_fsel(5, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_write(5, LOW);
}

/*void setBinary(uint8_t value) {
    if (value < sizeof(binary_values)) {
        uint8_t binary = binary_values[value];
        for (int ch = CH_START; ch < CH_END; ch++) {
            bcm2835_gpio_write(ch, (binary >> (ch - CH_START)) & 1);
            // E4235_Write(ch, (binary >> (ch - CH_START)) & 1);
        }
    }
}*/

void setBinary(char ascii) {
    uint8_t bitVal;
    
    bitVal = (ascii >> (0)) & 1;
    bcm2835_gpio_write(3, bitVal);
        
    bitVal = (ascii >> (1)) & 1;
    bcm2835_gpio_write(5, bitVal);
        
    bitVal = (ascii >> (2)) & 1;
    bcm2835_gpio_write(12, bitVal);
        
    bitVal = (ascii >> (3)) & 1;
    bcm2835_gpio_write(13, bitVal);
        
    bitVal = (ascii >> (4)) & 1;
    bcm2835_gpio_write(14, bitVal);
        
    bitVal = (ascii >> (5)) & 1;
    bcm2835_gpio_write(15, bitVal);
        
    bitVal = (ascii >> (6)) & 1;
    bcm2835_gpio_write(16, bitVal);

}


int main() {
    if (!bcm2835_init()) return 1;

    initialize();
    double elapTime;
    char current_matrix = 0; // 0 for normal, 1 for alternate
    const char *key_pressed;
    int firstAT = 1;
    int toggleVar = 1;
    
    // code for tiaming
    time_t curTime;
    curTime = time(NULL);
    struct timespec lastToggleTime;
    clock_gettime(CLOCK_MONOTONIC, &lastToggleTime);
    const double toggleInterval = 0.001; // 1 ms for 1 kHz (500 µs HIGH, 500 µs LOW)
    
    printf("\nDecode mode is %s\n", current_matrix ? "ON" : "OFF");

    while (1) {
        if (key_pressed != "*" && key_pressed != "#") {
            if(!toggleVar) {
                setBinary('%');
            } else {
                setBinary(*key_pressed);
            }
        }
            
        usleep(500);
        bcm2835_gpio_write(9, HIGH);
        
        for (int row = 0; row < NUM_ROWS; row++) {
            bcm2835_gpio_write(ROWS[row], HIGH);
            // E4235_Write(ROWS[row], HIGH);
            for (int col = 0; col < NUM_COLS; col++) {
                if (bcm2835_gpio_lev(COLS[col])) { // E4235_Read(COLS[col])
                    key_pressed = matrix[current_matrix][row][col];
                    if (*key_pressed == '#') {
                        current_matrix = !current_matrix;
                        printf("\n\nDecode mode is %s\n", current_matrix ? "ON" : "OFF");
                    } else if (*key_pressed == '*') {
                        
                        // reset all booleans or variables and clear screen and return to wait loop
                        system("clear");
                        current_matrix = 0;
                        printf("\nDecode mode is %s\n", current_matrix ? "ON" : "OFF");
                        
                    } else {
                        printf("%s                          \r", key_pressed);
                        fflush(stdout);
                        //setBinary(*key_pressed);
                        //setBinary((*key_pressed >= '0' && *key_pressed <= '9') ? *key_pressed - '0' : *key_pressed - 'A' + 10);
                        
                        // set boolean to true since key was pressed and set char to the keypressed
                        curTime = time(NULL);
                    }
                    debounce();
                } else {
                    
                    // find the time passed
                    elapTime = difftime(time(NULL), curTime);
                    
                    if (elapTime >= 2.0 && toggleVar) {
                        
                        // only print 40@ once
                        printf("%s\r", current_matrix ? "40" : "@");
                        //setBinary('@');
                        fflush(stdout);
                        
                        // logic of conditional
                        curTime = time(NULL);
                        toggleVar = 0;
                        
                    } else if (elapTime >= 0.5 && !toggleVar) {
                        
                        // only print keypad once
                        printf("%s                          \r", key_pressed);
                        //setBinary(*key_pressed);
                        fflush(stdout);
                        
                        // logic of conditional
                        curTime = time(NULL);
                        toggleVar = 1;
                    }
                    
                }
            }
            bcm2835_gpio_write(ROWS[row], LOW);
            // E4235_Write(ROWS[row], LOW);
        }
        usleep(500);
        bcm2835_gpio_write(9, LOW);
    }

    //bcm2835_close();
    return 0;
}
